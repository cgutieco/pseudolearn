#![forbid(unsafe_code)]

use crate::expression_values::lower_local;
use crate::expressions::{ExpressionState, lower_expression_with_state};
use crate::records::expression_width;
use crate::spans::resolve_span;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::identities::{ExpressionId, LocalId};

pub(crate) fn lower_range(
    expression: ExpressionId,
    range: (usize, usize),
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    if let Some(values) = crate::collections::values(expression, state) {
        return slice(values, range);
    }
    if let Some(values) = crate::indirect_calls::aggregate(expression, state) {
        return slice(values, range);
    }
    if let Some(values) = crate::variant_values::lower(expression, state) {
        return slice(values, range);
    }
    let (offset, count) = range;
    let module = state.context.module;
    let slot = usize::try_from(expression.0).unwrap_or(usize::MAX);
    let span = module
        .expressions
        .spans
        .get(slot)
        .copied()
        .and_then(|raw| resolve_span(raw, state.context.source));
    match module.expressions.kinds.get(slot).cloned() {
        Some(HirExpression::Local(local)) => local_values(local, range, span, state),
        Some(HirExpression::RecordField {
            record,
            offset: inner,
        }) => {
            let shifted = offset.saturating_add(usize::try_from(inner).unwrap_or(usize::MAX));
            lower_range(record, (shifted, count), state)
        }
        Some(HirExpression::RecordNew { fields, .. }) => {
            slice(lower_construction(&fields, state), range)
        }
        other => lower_invocation(other, range, span, state),
    }
}

fn local_values(
    local: LocalId,
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    crate::records::targets(local, state.context.module)
        .into_iter()
        .skip(range.0)
        .take(range.1)
        .map(|component| lower_local(component, span, state))
        .collect()
}

fn slice(values: Vec<ValueId>, range: (usize, usize)) -> Vec<ValueId> {
    values.into_iter().skip(range.0).take(range.1).collect()
}

fn lower_construction(
    fields: &[ExpressionId],
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut values = Vec::new();
    for field in fields {
        match expression_width(*field, state.context.module) {
            Some(width) => values.extend(lower_range(*field, (0, width), state)),
            None => values.push(lower_expression_with_state(*field, state)),
        }
    }
    values
}

pub(crate) fn lower_field(
    record: ExpressionId,
    offset: u32,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let shifted = usize::try_from(offset).unwrap_or(usize::MAX);
    lower_range(record, (shifted, 1), state)
        .into_iter()
        .next()
        .unwrap_or_else(|| state.builder.next_value())
}

pub(crate) fn lower_record_call(
    function: u32,
    arguments: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let (_, cells) =
        crate::expressions_complex::emit_function_call(arguments, function, span, state);
    load_cells(&cells, span, state)
}

pub(crate) fn load_cells(
    cells: &[ValueId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut values = Vec::new();
    for cell in cells {
        let loaded = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLoadRaw,
            vec![Operand::Value(*cell)],
            (Some(loaded), span),
        );
        values.push(loaded);
    }
    values
}

fn lower_invocation(
    kind: Option<HirExpression>,
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    match kind {
        Some(HirExpression::VirtualCall {
            receiver,
            function,
            arguments,
        }) => slice(
            crate::expressions_objects::method_values(
                receiver,
                function.0,
                &arguments,
                (span, state),
            ),
            range,
        ),
        Some(HirExpression::SuperCall {
            function: Some(function),
            arguments,
            ..
        }) => slice(
            crate::expressions_objects::super_values(function.0, &arguments, span, state),
            range,
        ),
        Some(HirExpression::Call {
            function,
            arguments,
        }) => slice(
            lower_record_call(function.0, &arguments, span, state),
            range,
        ),
        _ => Vec::new(),
    }
}
