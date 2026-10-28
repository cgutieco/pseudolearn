use crate::builder::FunctionBuilder;
use crate::expressions::{ExpressionState, lower_expression_with_state};
use crate::spans::resolve_span;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::{Literal, UnaryOperator};
use pseudolearn_semantic::identities::{ExpressionId, LocalId};

pub(crate) fn lower_literal(
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

pub(crate) fn lower_local(
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
        let value = state
            .environment
            .get_value(local_id)
            .unwrap_or_else(|| state.builder.next_value());
        if state.environment.is_assigned(local_id) {
            value
        } else {
            let result = state.builder.next_value();
            state.builder.emit_with_target(
                Operation::ValueRequire,
                vec![Operand::Value(value)],
                (Some(result), span),
            );
            result
        }
    }
}

pub(crate) fn lower_widen(
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

pub(crate) fn lower_unary(
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

pub(crate) fn lower_negative_unary(
    operand: ExpressionId,
    operand_value: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    let operand_type = usize::try_from(operand.0)
        .ok()
        .and_then(|index| state.context.module.expressions.types.get(index))
        .map(|type_id| state.context.module.types.representation(*type_id))
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
