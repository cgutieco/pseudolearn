use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::{FunctionId, LocalId};

pub(crate) fn create(
    function: FunctionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let code = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(i64::from(function.0))],
        (Some(code), span),
    );
    let environment = environment(function, span, state);
    vec![code, environment]
}

fn environment(
    function: FunctionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let Some(closure) = state.context.module.closures.get(&function).cloned() else {
        return empty_environment(span, state);
    };
    let Some(class) = closure.class else {
        return empty_environment(span, state);
    };
    let values = closure
        .captures
        .iter()
        .flat_map(|(original, _)| local_values(*original, span, state))
        .collect::<Vec<_>>();
    let object = crate::expressions_complex::lower_new(class.0, span, state);
    for (index, value) in values.into_iter().enumerate() {
        if let Some(field) = closure
            .layout
            .as_ref()
            .and_then(|layout| layout.field(index))
        {
            state.builder.emit_void(
                Operation::ObjectStore,
                vec![
                    Operand::Value(object),
                    Operand::Identifier(format!("capture{field}")),
                    Operand::Value(value),
                ],
                span,
            );
        }
    }
    reinterpret(object, IrType::Str, span, state)
}

fn empty_environment(span: Option<IrSpan>, state: &mut ExpressionState<'_, '_>) -> ValueId {
    let empty = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ValueUndefined,
        vec![Operand::Type(IrType::Str)],
        (Some(empty), span),
    );
    empty
}

pub(crate) fn captured(
    function: FunctionId,
    capture: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let Some(closure) = state.context.module.closures.get(&function).cloned() else {
        return Vec::new();
    };
    let Some(receiver) = captured_receiver(&closure, span, state) else {
        return Vec::new();
    };
    let Some(index) = usize::try_from(capture).ok() else {
        return Vec::new();
    };
    let Some(start) = closure
        .offsets
        .get(index)
        .and_then(|start| usize::try_from(*start).ok())
    else {
        return Vec::new();
    };
    let width = closure
        .captures
        .get(index)
        .map(|(_, proxy)| crate::records::targets(*proxy, state.context.module).len())
        .unwrap_or(0);
    load_fields(
        receiver,
        (&closure, start..start.saturating_add(width)),
        span,
        state,
    )
}

fn load_fields(
    receiver: ValueId,
    (closure, range): (
        &pseudolearn_semantic::function_model::HirClosure,
        std::ops::Range<usize>,
    ),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut values = Vec::new();
    for leaf in range {
        if let Some(field) = closure
            .layout
            .as_ref()
            .and_then(|layout| layout.field(leaf))
        {
            let value = state.builder.next_value();
            state.builder.emit_with_target(
                Operation::ObjectLoadRaw,
                vec![
                    Operand::Value(receiver),
                    Operand::Identifier(format!("capture{field}")),
                ],
                (Some(value), span),
            );
            values.push(value);
        }
    }
    values
}

fn local_values(
    local: LocalId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    crate::records::targets(local, state.context.module)
        .into_iter()
        .map(|local| crate::expression_values::lower_local(local, span, state))
        .collect()
}

fn reinterpret(
    value: ValueId,
    kind: IrType,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ValueReinterpret,
        vec![Operand::Type(kind), Operand::Value(value)],
        (Some(result), span),
    );
    result
}

fn captured_receiver(
    closure: &pseudolearn_semantic::function_model::HirClosure,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    let class = closure
        .class
        .and_then(|class| usize::try_from(class.0).ok())
        .and_then(|index| state.context.module.classes.get(index))?;
    let class_name = class.name.clone();
    let environment = state
        .environment
        .get_value(closure.environment)
        .unwrap_or_else(|| state.builder.next_value());
    Some(reinterpret(
        environment,
        IrType::Object(class_name),
        span,
        state,
    ))
}
