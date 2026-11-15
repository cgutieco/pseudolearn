use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{Function, IrSpan, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::collection_model::{
    CollectionAction, CollectionExpression, HirCollection,
};
use pseudolearn_semantic::{ExpressionId, HirExpression, HirModule, Type};

fn name(call: &CollectionExpression, module: &HirModule) -> String {
    let action = if call.action == CollectionAction::Contains {
        CollectionAction::IndexOf
    } else {
        call.action
    };
    let signature = signature(call, module).map_or(String::new(), |record| format!(".{record}"));
    format!("@__collection.{}.{action:?}{signature}", call.class.0)
}

fn signature(call: &CollectionExpression, module: &HirModule) -> Option<u32> {
    if call.action != CollectionAction::Sort {
        return None;
    }
    let expression = usize::try_from(call.arguments.first()?.0).ok()?;
    let Type::Record(record) = module
        .types
        .representation(*module.expressions.types.get(expression)?)
    else {
        return None;
    };
    Some(record.0)
}

pub(crate) fn append(module: &HirModule, functions: &mut Vec<Function>) {
    let mut seen = std::collections::BTreeSet::new();
    let span = functions
        .first()
        .and_then(|function| function.declaration_span);
    for (index, expression) in module.expressions.kinds.iter().enumerate() {
        let HirExpression::Collection(call) = expression else {
            continue;
        };
        if !matches!(
            call.action,
            CollectionAction::Sort
                | CollectionAction::Contains
                | CollectionAction::IndexOf
                | CollectionAction::Keys
        ) {
            continue;
        }
        let name = name(call, module);
        if !seen.insert(name.clone()) {
            continue;
        }
        let function = build(module, (index, call), span);
        functions.push(function);
    }
}

pub(crate) fn lower(
    call: &CollectionExpression,
    model: &HirCollection,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = invoke(call, span, state);
    if call.action == CollectionAction::Contains {
        let zero = crate::collections::emit(
            Operation::ConstI64,
            vec![Operand::LiteralI64(0)],
            span,
            state,
        );
        return crate::collections::emit(
            Operation::IntCmp,
            vec![
                Operand::Predicate(PredicateKind::GreaterEqual),
                Operand::Value(result),
                Operand::Value(zero),
            ],
            span,
            state,
        );
    }
    let _ = model;
    result
}

pub(crate) fn invoke(
    call: &CollectionExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let receiver = call
        .receiver
        .map(|receiver| lower_expression_with_state(receiver, state))
        .unwrap_or_else(|| state.builder.next_value());
    if call.action == CollectionAction::Reverse {
        state.builder.emit_void(
            Operation::CollectionReverse,
            vec![Operand::Value(receiver)],
            span,
        );
        return state.builder.next_value();
    }
    let mut arguments = vec![receiver];
    for argument in &call.arguments {
        arguments.extend(crate::variant_values::values(*argument, state));
    }
    let target = Operand::FunctionTarget {
        function_name: name(call, state.context.module),
        arguments,
    };
    if call.action == CollectionAction::Sort {
        state.builder.emit_void(Operation::Call, vec![target], span);
        state.builder.next_value()
    } else {
        crate::collections::emit(Operation::Call, vec![target], span, state)
    }
}

pub(crate) fn index_optional(
    expression: ExpressionId,
    call: &CollectionExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let position = invoke(call, span, state);
    let Some(variant) = optional_variant(expression, state.context.module) else {
        return Vec::new();
    };
    let zero = crate::collections::emit(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        span,
        state,
    );
    let present = crate::collections::emit(
        Operation::IntCmp,
        vec![
            Operand::Predicate(PredicateKind::GreaterEqual),
            Operand::Value(position),
            Operand::Value(zero),
        ],
        span,
        state,
    );
    let found = state.builder.create_block();
    let absent = state.builder.create_block();
    let merged = state.builder.create_block();
    crate::enum_output::branch(present, (found, absent), state.builder);
    state.builder.set_current_block(found);
    let values = crate::variant_values::pack(&variant, 1, &[position], state);
    crate::collection_optional::jump(merged, values, state);
    state.builder.set_current_block(absent);
    let values = crate::variant_values::pack(&variant, 0, &[], state);
    crate::collection_optional::jump(merged, values, state);
    state.builder.set_current_block(merged);
    crate::collection_optional::merge_values(&variant, merged, state)
}

fn build(
    module: &HirModule,
    (index, call): (usize, &CollectionExpression),
    span: Option<IrSpan>,
) -> Function {
    let name = name(call, module);
    let Some(model) = module.collections.get(&call.class) else {
        return Function::new(name, pseudolearn_ir::IrType::Unit);
    };
    let kind = crate::types::lower_type(
        module
            .expressions
            .types
            .get(index)
            .copied()
            .unwrap_or(model.value),
        module,
    );
    let source = source_type(module, model);
    match call.action {
        CollectionAction::Sort => build_sort(name, module, (model, signature(call, module)), span),
        CollectionAction::Keys => crate::collection_queries::keys(name, (source, kind), span),
        _ => crate::collection_queries::index(
            name,
            (source, crate::types::lower_type(model.value, module)),
            span,
        ),
    }
}

fn optional_variant(
    expression: ExpressionId,
    module: &HirModule,
) -> Option<pseudolearn_semantic::variant_model::HirVariant> {
    let kind = usize::try_from(expression.0)
        .ok()
        .and_then(|index| module.expressions.types.get(index))?;
    let Type::Record(record) = module.types.representation(*kind) else {
        return None;
    };
    module.variants.get(&record).cloned()
}

fn build_sort(
    name: String,
    module: &HirModule,
    (model, signature): (&HirCollection, Option<u32>),
    span: Option<IrSpan>,
) -> Function {
    crate::collection_sort::build(
        name,
        &crate::collection_sort::SortPlan {
            kind: source_type(module, model),
            leaves: model
                .canonical
                .iter()
                .filter_map(|index| model.leaves.get(*index))
                .map(|kind| crate::types::lower_type(*kind, module))
                .collect(),
            canonical: model.canonical.clone(),
            signature,
        },
        span,
    )
}

fn source_type(module: &HirModule, model: &HirCollection) -> pseudolearn_ir::IrType {
    pseudolearn_ir::IrType::Object(
        module
            .classes
            .get(usize::try_from(model.class.0).unwrap_or(usize::MAX))
            .map(|class| class.name.clone())
            .unwrap_or_default(),
    )
}
