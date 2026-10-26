use crate::collections::emit;
use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::collection_model::{CollectionAction, CollectionExpression};
use pseudolearn_semantic::{ExpressionId, Type};

pub(crate) fn lower(
    expression: ExpressionId,
    call: &CollectionExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let Some(model) = state.context.module.collections.get(&call.class).cloned() else {
        return Vec::new();
    };
    let Some(variant) = variant(expression, state) else {
        return Vec::new();
    };
    let (receiver, key, position, present) = lookup(call, span, state);
    let found = state.builder.create_block();
    let absent = state.builder.create_block();
    let merge = state.builder.create_block();
    crate::enum_output::branch(present, (found, absent), state.builder);
    state.builder.set_current_block(found);
    let payload = crate::collections::load(&model, (receiver, position), span, state);
    let values = crate::variant_values::pack(&variant, 1, &payload, state);
    if call.action == CollectionAction::Remove {
        state.builder.emit_void(
            Operation::CollectionRemove,
            vec![Operand::Value(receiver), Operand::Value(key)],
            span,
        );
    }
    jump(merge, values, state);
    state.builder.set_current_block(absent);
    let empty = crate::variant_values::pack(&variant, 0, &[], state);
    jump(merge, empty, state);
    state.builder.set_current_block(merge);
    merge_values(&variant, merge, state)
}

fn variant(
    expression: ExpressionId,
    state: &ExpressionState<'_, '_>,
) -> Option<pseudolearn_semantic::variant_model::HirVariant> {
    let kind = *state
        .context
        .module
        .expressions
        .types
        .get(usize::try_from(expression.0).ok()?)?;
    let Type::Record(record) = state.context.module.types.get(kind) else {
        return None;
    };
    state.context.module.variants.get(&record).cloned()
}

fn jump(
    target: pseudolearn_ir::BlockId,
    arguments: Vec<ValueId>,
    state: &mut ExpressionState<'_, '_>,
) {
    state.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: target,
            arguments,
        }],
        None,
    );
}

fn merge_values(
    variant: &pseudolearn_semantic::variant_model::HirVariant,
    merge: pseudolearn_ir::BlockId,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut values = Vec::new();
    for reference in std::iter::repeat_n(
        false,
        usize::try_from(variant.layout.scalar_words()).unwrap_or(0),
    )
    .chain(std::iter::repeat_n(
        true,
        usize::try_from(variant.layout.reference_words()).unwrap_or(0),
    )) {
        let value = state.builder.next_value();
        state.builder.add_block_parameter(
            merge,
            value,
            if reference { IrType::Str } else { IrType::I64 },
        );
        values.push(value);
    }
    values
}

fn lookup(
    call: &CollectionExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> (ValueId, ValueId, ValueId, ValueId) {
    let receiver = call
        .receiver
        .map(|receiver| lower_expression_with_state(receiver, state))
        .unwrap_or_else(|| state.builder.next_value());
    let key = call
        .arguments
        .first()
        .map(|key| lower_expression_with_state(*key, state))
        .unwrap_or_else(|| state.builder.next_value());
    let position = emit(
        Operation::CollectionLookup,
        vec![Operand::Value(receiver), Operand::Value(key)],
        span,
        state,
    );
    let zero = emit(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        None,
        state,
    );
    let present = emit(
        Operation::IntCmp,
        vec![
            Operand::Predicate(PredicateKind::GreaterEqual),
            Operand::Value(position),
            Operand::Value(zero),
        ],
        span,
        state,
    );
    (receiver, key, position, present)
}
