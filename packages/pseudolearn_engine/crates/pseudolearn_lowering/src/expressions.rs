#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::environment::VariableEnvironment;
use crate::expressions_binary::lower_binary_operation;
use crate::expressions_complex::{
    lower_builtin, lower_call, lower_element, lower_field, lower_new,
};
use crate::expressions_logical::{
    LogicalExpressionState, lower_short_circuit_and, lower_short_circuit_or,
};
use crate::spans::resolve_span;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::{
    BinaryOperator, HirExpression, Literal, UnaryOperator,
};
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ExpressionId, LocalId};
use pseudolearn_source::SourceText;

pub struct ExpressionContext<'context> {
    pub module: &'context HirModule,
    pub source: &'context SourceText,
}

pub struct ExpressionState<'state, 'context> {
    pub context: &'state ExpressionContext<'context>,
    pub environment: &'state mut VariableEnvironment,
    pub builder: &'state mut FunctionBuilder,
}

pub fn lower_expression(
    expression_id: ExpressionId,
    context: &ExpressionContext<'_>,
    environment: &mut VariableEnvironment,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let mut state = ExpressionState {
        context,
        environment,
        builder,
    };
    lower_expression_with_state(expression_id, &mut state)
}

pub fn lower_expression_with_state(
    expression_id: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let index = usize::try_from(expression_id.0).unwrap_or(0);
    let kind = state
        .context
        .module
        .expressions
        .kinds
        .get(index)
        .cloned()
        .unwrap_or(HirExpression::Invalid);
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(index)
        .copied()
        .and_then(|raw_span| resolve_span(raw_span, state.context.source));

    if let Some(primitive_value) = lower_primitive_expression(&kind, span, state) {
        primitive_value
    } else {
        lower_complex_expression(&kind, span, state)
    }
}

fn lower_primitive_expression(
    kind: &HirExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    match kind {
        HirExpression::Literal(literal) => Some(lower_literal(literal, span, state.builder)),
        HirExpression::Local(local_id) => Some(lower_local(*local_id, span, state)),
        HirExpression::Binary {
            operator,
            left,
            right,
            operator_span,
        } => Some(lower_binary(
            *operator,
            (*left, *right),
            *operator_span,
            state,
        )),
        HirExpression::Unary {
            operator,
            operand,
            operator_span,
        } => Some(lower_unary(*operator, *operand, *operator_span, state)),
        HirExpression::Widen(inner) => Some(lower_widen(*inner, span, state)),
        _ => None,
    }
}

fn lower_complex_expression(
    kind: &HirExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    match kind {
        HirExpression::Call {
            function,
            arguments,
        } => lower_call(arguments, function.0, span, state),
        HirExpression::Builtin {
            function,
            arguments,
        } => lower_builtin(arguments, *function, span, state),
        HirExpression::New { class, .. } => lower_new(class.0, span, state),
        HirExpression::Field { receiver, field } => lower_field(*receiver, field.0, span, state),
        HirExpression::Element { array, indices } => lower_element(*array, indices, span, state),
        _ => state.builder.next_value(),
    }
}

fn lower_literal(
    literal: &Literal,
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let result = builder.next_value();
    match literal {
        Literal::Integer(value) => {
            let operand = Operand::LiteralI64(*value);
            builder.emit_with_target(Operation::ConstI64, vec![operand], (Some(result), span));
        }
        Literal::Real(value) => {
            let operand = Operand::LiteralF64(*value);
            builder.emit_with_target(Operation::ConstF64, vec![operand], (Some(result), span));
        }
        Literal::Boolean(value) => {
            let operand = Operand::LiteralBool(*value);
            builder.emit_with_target(Operation::ConstBool, vec![operand], (Some(result), span));
        }
        Literal::Character(value) => {
            let operand = Operand::LiteralChar(*value);
            builder.emit_with_target(Operation::ConstChar, vec![operand], (Some(result), span));
        }
        Literal::String(value) => {
            let operand = Operand::LiteralStr(value.clone());
            builder.emit_with_target(Operation::ConstStr, vec![operand], (Some(result), span));
        }
    }
    result
}

fn lower_local(
    local_id: LocalId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    if let Some(cell) = state.environment.get_cell(local_id) {
        let loaded_value = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLoad,
            vec![Operand::Value(cell)],
            (Some(loaded_value), span),
        );
        loaded_value
    } else {
        state
            .environment
            .get_value(local_id)
            .unwrap_or_else(|| state.builder.next_value())
    }
}

fn lower_widen(
    inner: ExpressionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let inner_value = lower_expression_with_state(inner, state);
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::IntToReal,
        vec![Operand::Value(inner_value)],
        (Some(result), span),
    );
    result
}

fn lower_binary(
    operator: BinaryOperator,
    operands: (ExpressionId, ExpressionId),
    operator_span: pseudolearn_source::Span,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let (left, right) = operands;
    if operator == BinaryOperator::LogicalAnd {
        let mut logical_state = LogicalExpressionState {
            context: state.context,
            environment: state.environment,
            builder: state.builder,
        };
        return lower_short_circuit_and((left, right), &mut logical_state);
    }
    if operator == BinaryOperator::LogicalOr {
        let mut logical_state = LogicalExpressionState {
            context: state.context,
            environment: state.environment,
            builder: state.builder,
        };
        return lower_short_circuit_or((left, right), &mut logical_state);
    }
    let left_value = lower_expression_with_state(left, state);
    let right_value = lower_expression_with_state(right, state);
    let span = resolve_span(operator_span, state.context.source);
    let left_type = usize::try_from(left.0)
        .ok()
        .and_then(|index| state.context.module.expressions.types.get(index))
        .copied()
        .unwrap_or(pseudolearn_semantic::identities::TypeId(0));
    lower_binary_operation(
        operator,
        (left_value, right_value),
        (left_type, span),
        (state.context.module, state.builder),
    )
}

fn lower_unary(
    operator: UnaryOperator,
    operand: ExpressionId,
    operator_span: pseudolearn_source::Span,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let operand_value = lower_expression_with_state(operand, state);
    let span = resolve_span(operator_span, state.context.source);
    match operator {
        UnaryOperator::Positive => operand_value,
        UnaryOperator::Negative => lower_negative_unary(operand, operand_value, span, state),
        UnaryOperator::Not => {
            let result = state.builder.next_value();
            state.builder.emit_with_target(
                Operation::BoolNot,
                vec![Operand::Value(operand_value)],
                (Some(result), span),
            );
            result
        }
    }
}

fn lower_negative_unary(
    operand: ExpressionId,
    operand_value: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    let operand_type = usize::try_from(operand.0)
        .ok()
        .and_then(|index| state.context.module.expressions.types.get(index))
        .map(|type_id| state.context.module.types.get(*type_id))
        .unwrap_or(pseudolearn_semantic::types::Type::Integer);
    let operation = if operand_type == pseudolearn_semantic::types::Type::Real {
        Operation::RealNeg
    } else {
        Operation::IntNeg
    };
    state.builder.emit_with_target(
        operation,
        vec![Operand::Value(operand_value)],
        (Some(result), span),
    );
    result
}
