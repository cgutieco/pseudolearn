#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::environment::VariableEnvironment;
use crate::expression_values::{lower_literal, lower_local, lower_unary, lower_widen};
use crate::expressions_binary::lower_binary_operation;
use crate::expressions_complex::{lower_builtin, lower_call, lower_element, lower_field};
use crate::expressions_logical::{
    LogicalExpressionState, lower_short_circuit_and, lower_short_circuit_or,
};
use crate::spans::resolve_span;
use pseudolearn_ir::{IrSpan, ValueId};
use pseudolearn_semantic::expression_model::{BinaryOperator, HirExpression};
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::ExpressionId;
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

fn lower_non_collection(
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

    if let Some(value) = lower_projection(&kind, span, state) {
        return value;
    }
    if let Some(values) = crate::variant_values::lower(expression_id, state) {
        return values
            .first()
            .copied()
            .unwrap_or_else(|| state.builder.next_value());
    }
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
        HirExpression::TaskSpawn {
            function,
            arguments,
        } => crate::expressions_complex::lower_task_spawn(arguments, function.0, span, state),
        HirExpression::AwaitTask(value) => lower_task_await(*value, span, state),
        HirExpression::Builtin {
            function,
            arguments,
        } => lower_builtin(arguments, *function, span, state),
        HirExpression::New { .. }
        | HirExpression::This(_)
        | HirExpression::VirtualCall { .. }
        | HirExpression::SuperCall { .. } => crate::expressions_objects::lower(kind, span, state),
        HirExpression::Uninitialized(local) => lower_local(*local, span, state),
        HirExpression::Field { receiver, field } => lower_field(*receiver, field.0, span, state),
        HirExpression::Element { array, indices } => lower_element(*array, indices, span, state),
        _ => state.builder.next_value(),
    }
}

fn lower_task_await(
    expression: ExpressionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    crate::suspension_points::prepare(state, span);
    let task = lower_expression_with_state(expression, state);
    let task_type = usize::try_from(expression.0)
        .ok()
        .and_then(|index| state.context.module.expressions.types.get(index))
        .copied();
    let result_type = task_type
        .and_then(
            |type_id| match state.context.module.types.representation(type_id) {
                pseudolearn_semantic::Type::Task(result) => Some(result),
                _ => None,
            },
        )
        .map(|type_id| crate::types::lower_type(type_id, state.context.module))
        .unwrap_or(pseudolearn_ir::IrType::Unit);
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        pseudolearn_ir::Operation::TaskAwait,
        vec![
            pseudolearn_ir::Operand::Value(task),
            pseudolearn_ir::Operand::Type(result_type),
        ],
        (Some(result), span),
    );
    result
}

fn lower_logical(
    operator: BinaryOperator,
    operands: (ExpressionId, ExpressionId),
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    let mut logical_state = LogicalExpressionState {
        context: state.context,
        environment: state.environment,
        builder: state.builder,
    };
    match operator {
        BinaryOperator::LogicalAnd => Some(lower_short_circuit_and(operands, &mut logical_state)),
        BinaryOperator::LogicalOr => Some(lower_short_circuit_or(operands, &mut logical_state)),
        _ => None,
    }
}

fn lower_binary(
    operator: BinaryOperator,
    operands: (ExpressionId, ExpressionId),
    operator_span: pseudolearn_source::Span,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let (left, right) = operands;
    if let Some(value) = lower_logical(operator, operands, state) {
        return value;
    }
    if crate::records::expression_width(left, state.context.module).is_some() {
        return crate::records::lower_equality(operator, (left, right), operator_span, state);
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

fn lower_projection(
    kind: &HirExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    match kind {
        HirExpression::IndirectCall { callee, arguments } => {
            Some(crate::indirect_calls::lower(*callee, arguments, span, state).0)
        }
        HirExpression::Captured { function, capture } => Some(
            crate::closure_values::captured(*function, *capture, span, state)
                .first()
                .copied()
                .unwrap_or_else(|| state.builder.next_value()),
        ),
        HirExpression::VariantTag(value) => Some(crate::variant_values::tag(*value, state)),
        HirExpression::RecordField { record, offset } => {
            Some(crate::record_values::lower_field(*record, *offset, state))
        }
        _ => None,
    }
}

pub fn lower_expression_with_state(
    expression_id: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    if let Some(values) = crate::channel_operations::values(expression_id, state) {
        return values
            .first()
            .copied()
            .unwrap_or_else(|| state.builder.next_value());
    }
    if let Some(values) = crate::effect_values::values(expression_id, state) {
        return values
            .first()
            .copied()
            .unwrap_or_else(|| state.builder.next_value());
    }
    if let Some(values) = crate::collections::values(expression_id, state) {
        return values
            .first()
            .copied()
            .unwrap_or_else(|| state.builder.next_value());
    }
    lower_non_collection(expression_id, state)
}
