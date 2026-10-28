use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::{BuiltinKind, ExpressionId, HirExpression, Type};

pub(crate) fn values(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let index = usize::try_from(expression.0).ok()?;
    let HirExpression::Builtin {
        function: BuiltinKind::Snapshot,
        arguments,
    } = state.context.module.expressions.kinds.get(index)?.clone()
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
    Some(copy(*arguments.first()?, span, state))
}

pub(crate) fn copy(
    expression: ExpressionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let index = usize::try_from(expression.0).unwrap_or(usize::MAX);
    let Some(kind) = state.context.module.expressions.types.get(index).copied() else {
        return Vec::new();
    };
    let leaves = match state.context.module.types.representation(kind) {
        Type::Record(record) => usize::try_from(record.0)
            .ok()
            .and_then(|index| state.context.module.records.get(index))
            .map(|record| record.leaf_types.clone())
            .unwrap_or_default(),
        _ => vec![kind],
    };
    let mut values =
        if let Some(width) = crate::records::expression_width(expression, state.context.module) {
            crate::record_values::lower_range(expression, (0, width), state)
        } else {
            vec![lower_expression_with_state(expression, state)]
        };
    if matches!(state.context.module.types.get(kind), Type::Immutable(_)) {
        return values;
    }
    let (sources, destinations) = prepare(&values, leaves, span, state);
    emit(&mut values, (sources, destinations), span, state);
    values
}

fn emit(
    values: &mut [ValueId],
    parts: (Vec<Operand>, Vec<(usize, ValueId)>),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) {
    let (sources, destinations) = parts;
    if sources.is_empty() {
        return;
    }
    let mut operands = vec![Operand::LiteralI64(
        i64::try_from(sources.len()).unwrap_or(i64::MAX),
    )];
    operands.extend(sources);
    operands.extend(destinations.iter().map(|(_, cell)| Operand::Value(*cell)));
    state
        .builder
        .emit_void(Operation::SnapshotCopy, operands, span);
    for (index, cell) in destinations {
        let loaded = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLoad,
            vec![Operand::Value(cell)],
            (Some(loaded), span),
        );
        if let Some(value) = values.get_mut(index) {
            *value = loaded;
        }
    }
}

fn prepare(
    values: &[ValueId],
    leaves: Vec<pseudolearn_semantic::TypeId>,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> (Vec<Operand>, Vec<(usize, ValueId)>) {
    let mut sources = Vec::new();
    let mut destinations = Vec::new();
    for (index, kind) in leaves.into_iter().enumerate() {
        let kind = crate::types::lower_type(kind, state.context.module);
        if kind.value_class() != pseudolearn_ir::ValueClass::Reference {
            continue;
        }
        let Some(value) = values.get(index).copied() else {
            continue;
        };
        let cell = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLocal,
            vec![Operand::Type(kind)],
            (Some(cell), span),
        );
        sources.push(Operand::Value(value));
        destinations.push((index, cell));
    }
    (sources, destinations)
}
