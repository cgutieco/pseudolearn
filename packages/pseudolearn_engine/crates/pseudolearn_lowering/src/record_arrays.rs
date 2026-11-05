#![forbid(unsafe_code)]

use crate::expressions::{ExpressionState, lower_expression_with_state};
use crate::statement_context::StatementContext;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ExpressionId, LocalId};

pub(crate) fn leaf_arrays(array: ExpressionId, module: &HirModule) -> Option<Vec<LocalId>> {
    let index = usize::try_from(array.0).ok()?;
    match module.expressions.kinds.get(index)? {
        HirExpression::Local(local) => module.record_locals.get(local).cloned(),
        _ => None,
    }
}

fn selected(leaves: Vec<LocalId>, range: (usize, usize)) -> Vec<LocalId> {
    leaves.into_iter().skip(range.0).take(range.1).collect()
}

fn lower_indices(
    indices: &[ExpressionId],
    state: &mut ExpressionState<'_, '_>,
) -> Vec<Operand> {
    indices
        .iter()
        .map(|index| Operand::Value(lower_expression_with_state(*index, state)))
        .collect()
}

pub(crate) fn array_values(
    argument: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let leaves = leaf_arrays(argument, state.context.module)?;
    Some(
        leaves
            .into_iter()
            .map(|leaf| crate::expression_values::lower_local(leaf, None, state))
            .collect(),
    )
}

pub(crate) fn load_range(
    access: (ExpressionId, &[ExpressionId]),
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let (array, indices) = access;
    let leaves = selected(leaf_arrays(array, state.context.module)?, range);
    let index_operands = lower_indices(indices, state);
    let mut values = Vec::new();
    for leaf in leaves {
        let array_value = crate::expression_values::lower_local(leaf, span, state);
        let mut operands = vec![Operand::Value(array_value)];
        operands.extend(index_operands.clone());
        let loaded = state.builder.next_value();
        state
            .builder
            .emit_with_target(Operation::ArrayLoad, operands, (Some(loaded), span));
        values.push(loaded);
    }
    Some(values)
}

pub(crate) fn cell_range(
    access: (ExpressionId, &[ExpressionId]),
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let (array, indices) = access;
    let leaves = selected(leaf_arrays(array, state.context.module)?, range);
    let index_operands = lower_indices(indices, state);
    let mut cells = Vec::new();
    for leaf in leaves {
        let array_value = crate::expression_values::lower_local(leaf, span, state);
        let mut operands = vec![Operand::Value(array_value)];
        operands.extend(index_operands.clone());
        let cell = state.builder.next_value();
        state
            .builder
            .emit_with_target(Operation::CellElement, operands, (Some(cell), span));
        cells.push(cell);
    }
    Some(cells)
}

pub(crate) fn store_range(
    access: (ExpressionId, &[ExpressionId]),
    range: (usize, usize),
    payload: (Vec<ValueId>, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) -> bool {
    let (values, span) = payload;
    let (array, indices) = access;
    let Some(all) = leaf_arrays(array, context.expression_context.module) else {
        return false;
    };
    let leaves = selected(all, range);
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: &mut *context.environment,
        builder: &mut *context.builder,
    };
    let index_operands = lower_indices(indices, &mut state);
    for (leaf, value) in leaves.into_iter().zip(values) {
        let array_value = crate::expression_values::lower_local(leaf, span, &mut state);
        let mut operands = vec![Operand::Value(array_value)];
        operands.extend(index_operands.clone());
        operands.push(Operand::Value(value));
        state
            .builder
            .emit_void(Operation::ArrayStore, operands, span);
    }
    true
}
