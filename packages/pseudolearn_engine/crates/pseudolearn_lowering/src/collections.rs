use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::collection_model::{
    CollectionAction, CollectionExpression, HirCollection,
};
use pseudolearn_semantic::{ExpressionId, HirExpression, HirModule, Type};

pub(crate) fn model(expression: ExpressionId, module: &HirModule) -> Option<HirCollection> {
    let kind = *module
        .expressions
        .types
        .get(usize::try_from(expression.0).ok()?)?;
    let Type::Object(class) = module.types.get(kind) else {
        return None;
    };
    module.collections.get(&class).cloned()
}

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let kind = state
        .context
        .module
        .expressions
        .kinds
        .get(usize::try_from(expression.0).ok()?)?
        .clone();
    let span = location(expression, state)?;
    match kind {
        HirExpression::Element { array, indices } => element(array, &indices, span, state),
        HirExpression::Collection(call) => {
            let model = state.context.module.collections.get(&call.class)?.clone();
            if model.key.is_some()
                && matches!(
                    call.action,
                    CollectionAction::Find | CollectionAction::Remove
                )
            {
                Some(crate::collection_optional::lower(
                    expression, &call, span, state,
                ))
            } else {
                Some(vec![call_value(&call, &model, span, state)])
            }
        }
        _ => None,
    }
}

fn call_value(
    call: &CollectionExpression,
    model: &HirCollection,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    if call.action == CollectionAction::New {
        let name = state
            .context
            .module
            .classes
            .get(usize::try_from(call.class.0).unwrap_or(usize::MAX))
            .map(|class| class.name.clone())
            .unwrap_or_default();
        return emit(
            Operation::CollectionNew,
            vec![Operand::Type(pseudolearn_ir::IrType::Object(name))],
            span,
            state,
        );
    }
    let receiver = call
        .receiver
        .map(|receiver| lower_expression_with_state(receiver, state))
        .unwrap_or_else(|| state.builder.next_value());
    if call.action == CollectionAction::Length {
        return emit(
            Operation::CollectionLength,
            vec![Operand::Value(receiver)],
            span,
            state,
        );
    }
    mutate(call, model, (receiver, span), state)
}

pub(crate) fn load(
    model: &HirCollection,
    location: (ValueId, ValueId),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut values = vec![None; model.leaves.len()];
    for (canonical, source) in model.canonical.iter().enumerate() {
        let kind = model
            .leaves
            .get(*source)
            .map(|kind| crate::types::lower_type(*kind, state.context.module))
            .unwrap_or(pseudolearn_ir::IrType::Unit);
        let value = emit(
            Operation::CollectionLoad,
            vec![
                Operand::Type(kind),
                Operand::Value(location.0),
                Operand::Value(location.1),
                Operand::LiteralI64(i64::try_from(canonical).unwrap_or(0)),
            ],
            span,
            state,
        );
        if let Some(slot) = values.get_mut(*source) {
            *slot = Some(value);
        }
    }
    values.into_iter().flatten().collect()
}

fn payload(
    expression: ExpressionId,
    model: &HirCollection,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let values = crate::variant_values::values(expression, state);
    model
        .canonical
        .iter()
        .filter_map(|index| values.get(*index).copied())
        .collect()
}

pub(crate) fn store(
    destination: &pseudolearn_semantic::HirPlace,
    value: ExpressionId,
    span: Option<IrSpan>,
    context: &mut crate::statement_context::StatementContext<'_, '_>,
) -> bool {
    let pseudolearn_semantic::HirPlace::Element { array, indices } = destination else {
        return false;
    };
    let Some(model) = model(*array, context.expression_context.module) else {
        return false;
    };
    let Some(key) = indices.first() else {
        return true;
    };
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    let receiver = lower_expression_with_state(*array, &mut state);
    let key = lower_expression_with_state(*key, &mut state);
    let values = payload(value, &model, &mut state);
    let mut operands = vec![Operand::Value(receiver), Operand::Value(key)];
    operands.extend(values.into_iter().map(Operand::Value));
    state
        .builder
        .emit_void(Operation::CollectionStore, operands, span);
    true
}

pub(crate) fn emit(
    operation: Operation,
    operands: Vec<Operand>,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    state
        .builder
        .emit_with_target(operation, operands, (Some(result), span));
    result
}

fn location(expression: ExpressionId, state: &ExpressionState<'_, '_>) -> Option<Option<IrSpan>> {
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(usize::try_from(expression.0).ok()?)
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source));
    Some(span)
}

fn mutate(
    call: &CollectionExpression,
    model: &HirCollection,
    receiver: (ValueId, Option<IrSpan>),
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let (receiver, span) = receiver;
    let mut arguments = call.arguments.iter();
    let key = if call.action == CollectionAction::Append {
        None
    } else {
        arguments
            .next()
            .map(|value| lower_expression_with_state(*value, state))
    };
    let payload = arguments
        .next()
        .map(|value| payload(*value, model, state))
        .unwrap_or_default();
    let key = key.unwrap_or_else(|| {
        emit(
            Operation::CollectionLength,
            vec![Operand::Value(receiver)],
            span,
            state,
        )
    });
    let mut operands = vec![Operand::Value(receiver), Operand::Value(key)];
    operands.extend(payload.into_iter().map(Operand::Value));
    let operation = if call.action == CollectionAction::Remove {
        Operation::CollectionRemove
    } else {
        Operation::CollectionInsert
    };
    state.builder.emit_void(operation, operands, span);
    state.builder.next_value()
}

fn element(
    array: ExpressionId,
    indices: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let model = model(array, state.context.module)?;
    let receiver = lower_expression_with_state(array, state);
    let key = lower_expression_with_state(*indices.first()?, state);
    let position = if model.key.is_some() {
        emit(
            Operation::CollectionLookup,
            vec![Operand::Value(receiver), Operand::Value(key)],
            span,
            state,
        )
    } else {
        key
    };
    Some(load(&model, (receiver, position), span, state))
}
