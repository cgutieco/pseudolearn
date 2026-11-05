#![forbid(unsafe_code)]

use crate::expressions::{ExpressionState, lower_expression_with_state};
use crate::records::record_width;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::HirPlace;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ExpressionId, FieldId, TypeId};

pub(crate) fn leaves(module: &HirModule, field: FieldId) -> Option<&[FieldId]> {
    module
        .class_record_fields
        .iter()
        .find(|entry| entry.field.id == field)
        .map(|entry| entry.leaves.as_slice())
}

fn leaf_name(module: &HirModule, field: FieldId) -> String {
    module
        .classes
        .iter()
        .flat_map(|class| &class.fields)
        .find(|candidate| candidate.id == field)
        .map(|candidate| candidate.name.clone())
        .unwrap_or_default()
}

pub(crate) fn load_range(
    access: (ExpressionId, FieldId),
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let (receiver, field) = access;
    let (offset, count) = range;
    let selected: Vec<FieldId> = leaves(state.context.module, field)?
        .iter()
        .skip(offset)
        .take(count)
        .copied()
        .collect();
    let receiver_value = lower_expression_with_state(receiver, state);
    let mut values = Vec::new();
    for leaf in selected {
        let name = leaf_name(state.context.module, leaf);
        let loaded = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::ObjectLoad,
            vec![Operand::Value(receiver_value), Operand::Identifier(name)],
            (Some(loaded), span),
        );
        values.push(loaded);
    }
    Some(values)
}

pub(crate) fn cell_range(
    access: (ExpressionId, FieldId),
    range: (usize, usize),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let (receiver, field) = access;
    let (offset, count) = range;
    let selected: Vec<FieldId> = leaves(state.context.module, field)?
        .iter()
        .skip(offset)
        .take(count)
        .copied()
        .collect();
    let receiver_value = lower_expression_with_state(receiver, state);
    let mut cells = Vec::new();
    for leaf in selected {
        let name = leaf_name(state.context.module, leaf);
        let cell = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellField,
            vec![Operand::Value(receiver_value), Operand::Identifier(name)],
            (Some(cell), span),
        );
        cells.push(cell);
    }
    Some(cells)
}

pub(crate) fn destination(
    place: &HirPlace,
    module: &HirModule,
) -> Option<(ExpressionId, Vec<FieldId>)> {
    match place {
        HirPlace::Field { receiver, field } => {
            leaves(module, *field).map(|selected| (*receiver, selected.to_vec()))
        }
        HirPlace::FieldRange {
            receiver,
            field,
            offset,
            type_id,
        } => Some((
            *receiver,
            range_leaves(module, (*field, *offset, *type_id))?,
        )),
        _ => None,
    }
}

fn range_leaves(module: &HirModule, range: (FieldId, u32, TypeId)) -> Option<Vec<FieldId>> {
    let (field, offset, type_id) = range;
    let width = record_width(type_id, module)?;
    Some(
        leaves(module, field)?
            .iter()
            .skip(usize::try_from(offset).unwrap_or(usize::MAX))
            .take(width)
            .copied()
            .collect(),
    )
}

pub(crate) fn store(
    target: (ExpressionId, &[FieldId]),
    values: Vec<ValueId>,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let (receiver, selected) = target;
    let receiver_value = crate::expressions::lower_expression(
        receiver,
        context.expression_context,
        context.environment,
        context.builder,
    );
    for (leaf, value) in selected.iter().zip(values) {
        let name = leaf_name(context.expression_context.module, *leaf);
        context.builder.emit_void(
            Operation::ObjectStore,
            vec![
                Operand::Value(receiver_value),
                Operand::Identifier(name),
                Operand::Value(value),
            ],
            span,
        );
    }
}
