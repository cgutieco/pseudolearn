use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::{ExpressionId, HirExpression};

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let index = usize::try_from(expression.0).ok()?;
    let HirExpression::Effect {
        operation,
        receiver,
        arguments,
        source_node_id,
    } = state.context.module.expressions.kinds.get(index)?.clone()
    else {
        return None;
    };
    let descriptor = pseudolearn_semantic::EFFECT_OPERATIONS
        .iter()
        .find(|candidate| candidate.id == operation)?;
    let span = expression_span(index, state);
    let capability = receiver
        .map(|receiver| lower_expression_with_state(receiver, state))
        .unwrap_or_else(|| absent(span, state));
    let mut arguments: Vec<_> = arguments
        .into_iter()
        .map(|argument| lower_expression_with_state(argument, state))
        .collect();
    let kind = *state.context.module.expressions.types.get(index)?;
    let cells = result_cells(descriptor.fallible, kind, span, state);
    let result_type = result_type(expression, kind, state);
    arguments.extend(cells.iter().copied());
    crate::effect_calls::emit_effect_call(
        (capability, descriptor.identity, result_type, source_node_id),
        arguments,
        span,
        state,
    );
    Some(crate::record_values::load_cells(&cells, span, state))
}

fn expression_span(index: usize, state: &ExpressionState<'_, '_>) -> Option<IrSpan> {
    state
        .context
        .module
        .expressions
        .spans
        .get(index)
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source))
}

fn result_cells(
    fallible: bool,
    kind: pseudolearn_semantic::TypeId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    if fallible {
        return crate::expressions_complex::allocate_result_cells(kind, span, state);
    }
    let lowered = crate::types::lower_type(kind, state.context.module);
    vec![cell(lowered, span, state)]
}

fn result_type(
    expression: ExpressionId,
    kind: pseudolearn_semantic::TypeId,
    state: &ExpressionState<'_, '_>,
) -> IrType {
    let payload = crate::variant_values::model(expression, state.context.module)
        .and_then(|variant| variant.payloads.first().copied().flatten())
        .unwrap_or(kind);
    crate::types::lower_type(payload, state.context.module)
}

fn cell(kind: IrType, span: Option<IrSpan>, state: &mut ExpressionState<'_, '_>) -> ValueId {
    let cell = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::CellLocal,
        vec![Operand::Type(kind)],
        (Some(cell), span),
    );
    cell
}

fn absent(span: Option<IrSpan>, state: &mut ExpressionState<'_, '_>) -> ValueId {
    let value = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ValueUndefined,
        vec![Operand::Type(IrType::Str)],
        (Some(value), span),
    );
    value
}
