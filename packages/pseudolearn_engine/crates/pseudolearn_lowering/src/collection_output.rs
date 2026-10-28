use crate::collections::emit;
use crate::expressions::ExpressionState;
use pseudolearn_ir::{BlockId, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::collection_model::HirCollection;
use pseudolearn_semantic::{ExpressionId, Type, TypeId};

pub(crate) fn lower(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    let model = crate::collections::model(expression, state.context.module)?;
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(usize::try_from(expression.0).ok()?)
        .copied()
        .and_then(|span| crate::spans::resolve_span(span, state.context.source));
    let handle = crate::expressions::lower_expression_with_state(expression, state);
    Some(collection(&model, handle, span, state))
}

fn collection(
    model: &HirCollection,
    handle: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let initial = text(if model.key.is_some() { "{" } else { "[" }, span, state);
    let zero = emit(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        None,
        state,
    );
    let header = state.builder.create_block();
    let body = state.builder.create_block();
    let exit = state.builder.create_block();
    jump(header, vec![zero, initial], state);
    state.builder.set_current_block(header);
    let cursor = state.builder.next_value();
    let accumulated = state.builder.next_value();
    state
        .builder
        .add_block_parameter(header, cursor, IrType::I64);
    state
        .builder
        .add_block_parameter(header, accumulated, IrType::Str);
    let (position, present) = next_position(model, handle, (cursor, zero, span), state);
    crate::enum_output::branch(present, (body, exit), state.builder);
    state.builder.set_current_block(body);
    let prefix = separator(accumulated, (cursor, zero), span, state);
    let prefix = key(model, (handle, position, prefix), span, state);
    let values = crate::collections::load(model, (handle, position), span, state);
    let formatted = value(model.value, &values, span, state);
    let next_text = concatenate(prefix, formatted, span, state);
    advance(header, (position, next_text), span, state);
    state.builder.set_current_block(exit);
    let closing = text(if model.key.is_some() { "}" } else { "]" }, span, state);
    concatenate(accumulated, closing, span, state)
}

fn key(
    model: &HirCollection,
    location: (ValueId, ValueId, ValueId),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let Some(kind) = model.key else {
        return location.2;
    };
    let key = emit(
        Operation::CollectionKey,
        vec![Operand::Value(location.0), Operand::Value(location.1)],
        span,
        state,
    );
    let formatted = value(kind, &[key], span, state);
    let prefix = concatenate(location.2, formatted, span, state);
    let separator = text(": ", span, state);
    concatenate(prefix, separator, span, state)
}

fn value(
    kind: TypeId,
    values: &[ValueId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let first = values
        .first()
        .copied()
        .unwrap_or_else(|| state.builder.next_value());
    match state.context.module.types.representation(kind) {
        Type::Object(class) => {
            let model = state.context.module.collections.get(&class).cloned();
            model
                .map(|model| collection(&model, first, span, state))
                .unwrap_or(first)
        }
        Type::Enum(enumeration) => {
            crate::enum_output::member_name(first, enumeration, state.context, state.builder)
        }
        Type::Record(record) if state.context.module.function_types.contains_key(&record) => {
            let english = span
                .and_then(|span| state.context.module.source_profiles.get(&span.source_id))
                .is_some_and(|profile| *profile == pseudolearn_semantic::Profile::English);
            text(
                if english {
                    "<subroutine>"
                } else {
                    "<subprograma>"
                },
                span,
                state,
            )
        }
        kind => primitive(kind, first, span, state),
    }
}

fn separator(
    accumulated: ValueId,
    cursor: (ValueId, ValueId),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let first = compare(PredicateKind::Equal, cursor.0, cursor.1, state);
    let unchanged = state.builder.create_block();
    let separated = state.builder.create_block();
    let merge = state.builder.create_block();
    crate::enum_output::branch(first, (unchanged, separated), state.builder);
    state.builder.set_current_block(unchanged);
    jump(merge, vec![accumulated], state);
    state.builder.set_current_block(separated);
    let comma = text(", ", span, state);
    let prefixed = concatenate(accumulated, comma, span, state);
    jump(merge, vec![prefixed], state);
    state.builder.set_current_block(merge);
    let result = state.builder.next_value();
    state
        .builder
        .add_block_parameter(merge, result, IrType::Str);
    result
}

fn text(content: &str, span: Option<IrSpan>, state: &mut ExpressionState<'_, '_>) -> ValueId {
    emit(
        Operation::ConstStr,
        vec![Operand::LiteralStr(content.to_owned())],
        span,
        state,
    )
}

fn compare(
    predicate: PredicateKind,
    left: ValueId,
    right: ValueId,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    emit(
        Operation::IntCmp,
        vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ],
        None,
        state,
    )
}

fn concatenate(
    left: ValueId,
    right: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    emit(
        Operation::TextConcat,
        vec![Operand::Value(left), Operand::Value(right)],
        span,
        state,
    )
}

fn jump(target_block: BlockId, arguments: Vec<ValueId>, state: &mut ExpressionState<'_, '_>) {
    state.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block,
            arguments,
        }],
        None,
    );
}

fn next_position(
    model: &HirCollection,
    handle: ValueId,
    location: (ValueId, ValueId, Option<IrSpan>),
    state: &mut ExpressionState<'_, '_>,
) -> (ValueId, ValueId) {
    let (cursor, zero, span) = location;
    let position = if model.key.is_some() {
        emit(
            Operation::CollectionNext,
            vec![Operand::Value(handle), Operand::Value(cursor)],
            span,
            state,
        )
    } else {
        cursor
    };
    let (predicate, right) = if model.key.is_some() {
        (PredicateKind::GreaterEqual, zero)
    } else {
        (
            PredicateKind::LessThan,
            emit(
                Operation::CollectionLength,
                vec![Operand::Value(handle)],
                span,
                state,
            ),
        )
    };
    let present = compare(predicate, position, right, state);
    (position, present)
}

fn advance(
    header: BlockId,
    values: (ValueId, ValueId),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) {
    let (position, next_text) = values;
    let one = emit(
        Operation::ConstI64,
        vec![Operand::LiteralI64(1)],
        None,
        state,
    );
    let next = emit(
        Operation::IntAdd,
        vec![Operand::Value(position), Operand::Value(one)],
        span,
        state,
    );
    jump(header, vec![next, next_text], state);
}

fn primitive(
    kind: Type,
    first: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let formatted = if kind == Type::String {
        first
    } else {
        emit(
            Operation::TextFormat,
            vec![Operand::Value(first)],
            span,
            state,
        )
    };
    if matches!(kind, Type::String | Type::Character) {
        emit(
            Operation::TextQuote,
            vec![Operand::Value(formatted)],
            span,
            state,
        )
    } else {
        formatted
    }
}
