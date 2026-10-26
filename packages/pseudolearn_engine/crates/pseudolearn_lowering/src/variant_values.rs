use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ExpressionId, RecordId, TypeId};
use pseudolearn_semantic::types::Type;
use pseudolearn_semantic::variant_model::HirVariant;

pub(crate) fn model(expression: ExpressionId, module: &HirModule) -> Option<HirVariant> {
    let kind = *module
        .expressions
        .types
        .get(usize::try_from(expression.0).ok()?)?;
    let Type::Record(record) = module.types.get(kind) else {
        return None;
    };
    module.variants.get(&record).cloned()
}

pub(crate) fn lower(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let location = location(expression, state);
    let expression = state
        .context
        .module
        .expressions
        .kinds
        .get(usize::try_from(expression.0).ok()?)?
        .clone();
    match expression {
        HirExpression::VariantNew {
            record,
            alternative,
            payload,
        } => construction(record, alternative, payload, state),
        HirExpression::VariantPayload { value, alternative } => {
            let variant = model(value, state.context.module)?;
            let values = values(value, state);
            Some(project(
                &variant,
                usize::try_from(alternative).ok()?,
                &values,
                state,
            ))
        }
        HirExpression::Propagate { value, target } => Some(crate::variant_propagation::lower(
            value, target, location, state,
        )),
        _ => None,
    }
}

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    match crate::records::expression_width(expression, state.context.module) {
        Some(width) => crate::record_values::lower_range(expression, (0, width), state),
        None => vec![lower_expression_with_state(expression, state)],
    }
}

pub(crate) fn tag(expression: ExpressionId, state: &mut ExpressionState<'_, '_>) -> ValueId {
    let variant = model(expression, state.context.module);
    let values = values(expression, state);
    match variant {
        Some(variant) => tag_values(&variant, &values, state),
        None => state.builder.next_value(),
    }
}

pub(crate) fn tag_values(
    variant: &HirVariant,
    values: &[ValueId],
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    if !variant.layout.uses_reference_niche() {
        return values
            .first()
            .copied()
            .unwrap_or_else(|| state.builder.next_value());
    }
    let absent = undefined_reference(state);
    let present = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::RefCmp,
        vec![
            Operand::Predicate(pseudolearn_ir::PredicateKind::NotEqual),
            Operand::Value(values.first().copied().unwrap_or(absent)),
            Operand::Value(absent),
        ],
        (Some(present), None),
    );
    reinterpret(present, pseudolearn_ir::IrType::I64, state)
}

pub(crate) fn pack(
    variant: &HirVariant,
    alternative: usize,
    payload: &[ValueId],
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let scalar_count = usize::try_from(variant.layout.scalar_words()).unwrap_or(0);
    let mut values = empty_values(variant, state);
    if !variant.layout.uses_reference_niche() {
        let tag = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::ConstI64,
            vec![Operand::LiteralI64(i64::try_from(alternative).unwrap_or(0))],
            (Some(tag), None),
        );
        if let Some(slot) = values.first_mut() {
            *slot = tag;
        }
    }
    for (offset, value) in variant
        .offsets
        .get(alternative)
        .into_iter()
        .flatten()
        .zip(payload)
    {
        let index = usize::try_from(*offset).unwrap_or(usize::MAX);
        let target = if index < scalar_count {
            pseudolearn_ir::IrType::I64
        } else {
            pseudolearn_ir::IrType::Str
        };
        if let Some(slot) = values.get_mut(index) {
            *slot = reinterpret(*value, target, state);
        }
    }
    values
}

pub(crate) fn project(
    variant: &HirVariant,
    alternative: usize,
    values: &[ValueId],
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let kind = variant.payloads.get(alternative).copied().flatten();
    let leaves = kind
        .map(|kind| leaves(kind, state.context.module))
        .unwrap_or_default();
    variant
        .offsets
        .get(alternative)
        .into_iter()
        .flatten()
        .zip(leaves)
        .filter_map(|(offset, kind)| {
            let value = *values.get(usize::try_from(*offset).ok()?)?;
            Some(reinterpret(
                value,
                crate::types::lower_type(kind, state.context.module),
                state,
            ))
        })
        .collect()
}

fn leaves(kind: TypeId, module: &HirModule) -> Vec<TypeId> {
    match module.types.get(kind) {
        Type::Record(record) => usize::try_from(record.0)
            .ok()
            .and_then(|index| module.records.get(index))
            .map(|record| record.leaf_types.clone())
            .unwrap_or_default(),
        _ => vec![kind],
    }
}

fn reinterpret(
    value: ValueId,
    kind: pseudolearn_ir::IrType,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ValueReinterpret,
        vec![Operand::Type(kind), Operand::Value(value)],
        (Some(result), None),
    );
    result
}

fn undefined_reference(state: &mut ExpressionState<'_, '_>) -> ValueId {
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ValueUndefined,
        vec![Operand::Type(pseudolearn_ir::IrType::Str)],
        (Some(result), None),
    );
    result
}

pub(crate) fn return_values(
    values: &[ValueId],
    span: Option<pseudolearn_ir::IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) {
    for (cell, value) in state.builder.result_cells.clone().into_iter().zip(values) {
        state.builder.emit_void(
            Operation::CellStore,
            vec![Operand::Value(cell), Operand::Value(*value)],
            None,
        );
    }
    crate::cleanup_edges::emit(state.context, state.environment, state.builder, 0);
    state
        .builder
        .emit_void(Operation::StmtExit, Vec::new(), span);
    state.builder.emit_void(Operation::Return, Vec::new(), span);
}

pub(crate) fn target(record: RecordId, module: &HirModule) -> Option<HirVariant> {
    module.variants.get(&record).cloned()
}

fn location(
    expression: ExpressionId,
    state: &ExpressionState<'_, '_>,
) -> Option<pseudolearn_ir::IrSpan> {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| state.context.module.expressions.spans.get(index))
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source))
}

fn construction(
    record: RecordId,
    alternative: u32,
    payload: Option<ExpressionId>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let values = payload
        .map(|payload| values(payload, state))
        .unwrap_or_default();
    let variant = state.context.module.variants.get(&record)?.clone();
    Some(pack(
        &variant,
        usize::try_from(alternative).ok()?,
        &values,
        state,
    ))
}

fn empty_values(variant: &HirVariant, state: &mut ExpressionState<'_, '_>) -> Vec<ValueId> {
    let reference_count = usize::try_from(variant.layout.reference_words()).unwrap_or(0);
    let zero = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        (Some(zero), None),
    );
    let mut values = vec![zero; usize::try_from(variant.layout.scalar_words()).unwrap_or(0)];
    if reference_count > 0 {
        values.extend(vec![undefined_reference(state); reference_count]);
    }
    values
}
