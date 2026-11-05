#![forbid(unsafe_code)]

use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, ValueId};
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::identities::ExpressionId;

pub(crate) fn lower_range(
    expression: ExpressionId,
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let (offset, count) = range;
    let slot = usize::try_from(expression.0).unwrap_or(usize::MAX);
    let kind = state.context.module.expressions.kinds.get(slot).cloned();
    match kind {
        Some(HirExpression::Local(local)) => {
            crate::records::targets(local, state.context.module)
                .into_iter()
                .skip(offset)
                .take(count)
                .map(|leaf| crate::expressions_complex::lower_local_cell(leaf, span, state))
                .collect()
        }
        Some(HirExpression::RecordField {
            record,
            offset: inner,
        }) => {
            let shifted = offset.saturating_add(usize::try_from(inner).unwrap_or(usize::MAX));
            lower_range(record, (shifted, count), span, state)
        }
        Some(HirExpression::Element { array, indices }) => {
            crate::record_arrays::cell_range((array, &indices), range, span, state)
                .unwrap_or_default()
        }
        Some(HirExpression::Field { receiver, field }) => {
            crate::class_record_values::cell_range((receiver, field), range, span, state)
                .unwrap_or_default()
        }
        _ => Vec::new(),
    }
}
