use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::{ExpressionId, HirExpression, Type};

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let index = usize::try_from(expression.0).ok()?;
    let HirExpression::AwaitTask(task) = *state.context.module.expressions.kinds.get(index)? else {
        return None;
    };
    let leaves = payload_leaves(index, state)?;
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(index)
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source));
    crate::suspension_points::prepare(state, span);
    let task = lower_expression_with_state(task, state);
    let status = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::TaskAwait,
        vec![Operand::Value(task), Operand::Type(IrType::Unit)],
        (Some(status), span),
    );
    Some(load(&leaves, span, state))
}

pub(crate) fn load(
    leaves: &[pseudolearn_semantic::TypeId],
    span: Option<pseudolearn_ir::IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    leaves
        .iter()
        .enumerate()
        .map(|(index, kind)| {
            let result = state.builder.next_value();
            state.builder.emit_with_target(
                Operation::TaskValueLoad,
                vec![
                    Operand::Type(crate::types::lower_type(*kind, state.context.module)),
                    Operand::LiteralI64(i64::try_from(index).unwrap_or(i64::MAX)),
                ],
                (Some(result), span),
            );
            result
        })
        .collect()
}

fn payload_leaves(
    index: usize,
    state: &ExpressionState<'_, '_>,
) -> Option<Vec<pseudolearn_semantic::TypeId>> {
    let Type::Record(record) = state
        .context
        .module
        .types
        .get(*state.context.module.expressions.types.get(index)?)
    else {
        return None;
    };
    let leaves = state
        .context
        .module
        .records
        .get(usize::try_from(record.0).ok()?)?
        .leaf_types
        .clone();
    Some(leaves)
}
