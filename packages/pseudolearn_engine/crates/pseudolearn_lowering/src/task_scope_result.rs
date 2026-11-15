use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::{HirModule, LocalId, Type};

pub(crate) fn bind(
    failure: LocalId,
    scope: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) {
    let module = state.context.module;
    let Some((variant, payload, associated)) = descriptor(failure, module) else {
        return;
    };
    let present = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::TaskScopeResult,
        vec![Operand::Value(scope), Operand::Type(associated)],
        (Some(present), span),
    );
    let values = crate::task_values::load(&payload, span, state);
    let mut packed = crate::variant_values::pack(&variant, 1, &values, state);
    if let Some(tag) = packed.first_mut() {
        *tag = present;
    }
    for (local, value) in crate::records::targets(failure, module)
        .into_iter()
        .zip(packed)
    {
        state.environment.bind_value(local, value);
        state.environment.mark_assigned(local);
    }
}

fn descriptor(
    failure: LocalId,
    module: &HirModule,
) -> Option<(
    pseudolearn_semantic::variant_model::HirVariant,
    Vec<pseudolearn_semantic::TypeId>,
    IrType,
)> {
    let local = module.locals.get(usize::try_from(failure.0).ok()?)?;
    let Type::Record(record) = module.types.representation(local.type_id) else {
        return None;
    };
    let variant = module.variants.get(&record)?.clone();
    let Type::Record(payload) = module
        .types
        .get(variant.payloads.get(1).copied().flatten()?)
    else {
        return None;
    };
    let payload = module.records.get(usize::try_from(payload.0).ok()?)?;
    let associated = crate::types::lower_type(payload.fields.get(1)?.type_id, module);
    Some((variant, payload.leaf_types.clone(), associated))
}
