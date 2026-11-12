use crate::expressions::ExpressionState;
use pseudolearn_ir::{Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::identities::{ExpressionId, RecordId};

pub(crate) fn lower(
    value: ExpressionId,
    target: RecordId,
    span: Option<pseudolearn_ir::IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let Some(source) = crate::variant_values::model(value, state.context.module) else {
        return Vec::new();
    };
    let Some(target) = crate::variant_values::target(target, state.context.module) else {
        return Vec::new();
    };
    let values = crate::variant_values::values(value, state);
    let tag = crate::variant_values::tag_values(&source, &values, state);
    let success = source.success_alternative();
    let (continued, failed) = branch(success, tag, state);
    state.builder.set_current_block(failed);
    let error = 1_usize.saturating_sub(success);
    let payload = crate::variant_values::project(&source, error, &values, state);
    let failure = 1_usize.saturating_sub(target.success_alternative());
    let returned = crate::variant_values::pack(&target, failure, &payload, state);
    crate::variant_values::return_values(&returned, span, state);
    state.builder.set_current_block(continued);
    crate::variant_values::project(&source, success, &values, state)
}

fn branch(
    success: usize,
    tag: ValueId,
    state: &mut ExpressionState<'_, '_>,
) -> (pseudolearn_ir::BlockId, pseudolearn_ir::BlockId) {
    let expected = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(i64::try_from(success).unwrap_or(0))],
        (Some(expected), None),
    );
    let condition = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(PredicateKind::Equal),
            Operand::Value(tag),
            Operand::Value(expected),
        ],
        (Some(condition), None),
    );
    let continued = state.builder.create_block();
    let failed = state.builder.create_block();
    crate::enum_output::branch(condition, (continued, failed), state.builder);
    (continued, failed)
}
