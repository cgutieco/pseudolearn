use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::ExpressionId;

pub(crate) fn construct(
    class: u32,
    arguments: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let constructor = crate::constructor_flow::find(class, state.context.module);
    let arguments = lower_arguments(constructor, arguments, state);
    let receiver = crate::expressions_complex::lower_new(class, span, state);
    if let Some(constructor) = constructor {
        emit_call(constructor, receiver, arguments, (false, span, state));
    }
    receiver
}

pub(crate) fn method(
    receiver: ExpressionId,
    function: u32,
    arguments: &[ExpressionId],
    (span, state): (Option<IrSpan>, &mut ExpressionState<'_, '_>),
) -> ValueId {
    let receiver = lower_expression_with_state(receiver, state);
    let arguments = lower_arguments(Some(function), arguments, state);
    let virtual_call = crate::dispatch_targets::polymorphic(function, state.context.module);
    emit_call(function, receiver, arguments, (virtual_call, span, state))
}

pub(crate) fn super_call(
    function: Option<u32>,
    arguments: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let arguments = lower_arguments(function, arguments, state);
    let receiver = state
        .builder
        .receiver
        .unwrap_or_else(|| state.builder.next_value());
    if let Some(function) = function {
        emit_call(function, receiver, arguments, (false, span, state))
    } else {
        receiver
    }
}

fn lower_arguments(
    function: Option<u32>,
    arguments: &[ExpressionId],
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    arguments
        .iter()
        .enumerate()
        .map(|(position, argument)| {
            let parameter = function
                .and_then(|function| usize::try_from(function).ok())
                .and_then(|index| state.context.module.functions.get(index))
                .and_then(|function| function.parameters.get(position))
                .and_then(|parameter| usize::try_from(parameter.0).ok())
                .and_then(|index| state.context.module.locals.get(index));
            if parameter.is_some_and(|parameter| {
                crate::parameter_passing::requires_cell(parameter, state.context.module)
            }) {
                let span = usize::try_from(argument.0)
                    .ok()
                    .and_then(|index| state.context.module.expressions.spans.get(index))
                    .and_then(|span| crate::spans::resolve_span(*span, state.context.source));
                crate::expressions_complex::lower_cell_argument(*argument, span, state)
            } else {
                lower_expression_with_state(*argument, state)
            }
        })
        .collect()
}

pub(crate) fn emit_call(
    function: u32,
    receiver: ValueId,
    arguments: Vec<ValueId>,
    (virtual_call, span, state): (bool, Option<IrSpan>, &mut ExpressionState<'_, '_>),
) -> ValueId {
    let name = usize::try_from(function)
        .ok()
        .and_then(|index| state.context.module.functions.get(index))
        .map(|function| crate::functions::function_name(function, state.context.module))
        .unwrap_or_default();
    let mut passed = vec![receiver];
    passed.extend(arguments);
    let mut operands = Vec::new();
    if virtual_call {
        operands.push(Operand::Value(receiver));
    }
    operands.push(Operand::FunctionTarget {
        function_name: name,
        arguments: passed,
    });
    let result = state.builder.next_value();
    let operation = if virtual_call {
        Operation::CallVirtual
    } else {
        Operation::Call
    };
    state
        .builder
        .emit_with_target(operation, operands, (Some(result), span));
    result
}

pub(crate) fn lower(
    kind: &pseudolearn_semantic::expression_model::HirExpression,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    use pseudolearn_semantic::expression_model::HirExpression;
    match kind {
        HirExpression::New { class, arguments } => construct(class.0, arguments, span, state),
        HirExpression::This(_) => state
            .builder
            .receiver
            .unwrap_or_else(|| state.builder.next_value()),
        HirExpression::VirtualCall {
            receiver,
            function,
            arguments,
        } => method(*receiver, function.0, arguments, (span, state)),
        HirExpression::SuperCall {
            function,
            arguments,
            ..
        } => super_call(function.map(|function| function.0), arguments, span, state),
        _ => state.builder.next_value(),
    }
}
