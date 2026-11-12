use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::channel_model::{ChannelAction, ChannelExpression};
use pseudolearn_semantic::{ExpressionId, HirExpression};

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let index = usize::try_from(expression.0).ok()?;
    let HirExpression::Channel(call) = state.context.module.expressions.kinds.get(index)?.clone()
    else {
        return None;
    };
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(index)
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source));
    if matches!(call.action, ChannelAction::Send | ChannelAction::Receive) {
        crate::suspension_points::prepare(state, span);
    }
    if matches!(
        call.action,
        ChannelAction::Receive | ChannelAction::Selected
    ) {
        return Some(receive(expression, &call, span, state));
    }
    Some(command_values(&call, span, state))
}

fn command_values(
    call: &ChannelExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut arguments = Vec::new();
    if let Some(receiver) = call.receiver {
        arguments.extend(crate::variant_values::values(receiver, state));
    }
    for argument in &call.arguments {
        arguments.extend(crate::variant_values::values(*argument, state));
    }
    let command = match call.action {
        ChannelAction::New => {
            let width =
                crate::records::record_width(call.element, state.context.module).unwrap_or(1);
            arguments.push(integer(i64::try_from(width).unwrap_or(i64::MAX), state));
            "new"
        }
        ChannelAction::Send => "send",
        _ => "close",
    };
    let kind = if call.action == ChannelAction::New {
        IrType::Str
    } else if call.action == ChannelAction::Send {
        IrType::Bool
    } else {
        IrType::I64
    };
    vec![emit((command, kind), &arguments, span, state)]
}

pub(crate) fn emit(
    (command, result): (&str, IrType),
    arguments: &[ValueId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let mut operands = vec![
        Operand::Identifier(command.to_owned()),
        Operand::Type(result),
    ];
    operands.extend(arguments.iter().copied().map(Operand::Value));
    let result = state.builder.next_value();
    state
        .builder
        .emit_with_target(Operation::TaskChannel, operands, (Some(result), span));
    result
}

fn receive(
    expression: ExpressionId,
    call: &ChannelExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let arguments = call
        .receiver
        .map(|receiver| crate::variant_values::values(receiver, state))
        .unwrap_or_default();
    let command = if call.action == ChannelAction::Selected {
        "selected_present"
    } else {
        "receive"
    };
    let presence = emit((command, IrType::I64), &arguments, span, state);
    let payload = receive_payload(call.element, span, state);
    let Some(model) = crate::variant_values::model(expression, state.context.module) else {
        return Vec::new();
    };
    let mut values = crate::variant_values::pack(&model, 1, &payload, state);
    if !model.layout.uses_reference_niche()
        && let Some(tag) = values.first_mut()
    {
        *tag = presence;
    }
    values
}

fn integer(value: i64, state: &mut ExpressionState<'_, '_>) -> ValueId {
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(value)],
        (Some(result), None),
    );
    result
}

fn receive_payload(
    element: pseudolearn_semantic::TypeId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let leaves = match state.context.module.types.representation(element) {
        pseudolearn_semantic::Type::Record(record) => state
            .context
            .module
            .records
            .get(usize::try_from(record.0).unwrap_or(usize::MAX))
            .map(|record| record.leaf_types.clone())
            .unwrap_or_default(),
        _ => vec![element],
    };
    crate::task_values::load(&leaves, span, state)
}
