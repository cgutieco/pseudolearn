#![forbid(unsafe_code)]

use crate::environment::get_local_ir_type;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{IrSpan, Operand, Operation, OriginEntry, ValueId, VariableId};
use pseudolearn_semantic::expression_model::HirPlace;
use pseudolearn_semantic::identities::{ExpressionId, LocalId};
use pseudolearn_semantic::statement_model::HirDimension;
use pseudolearn_source::Span;

pub fn lower_assign(
    destination: &HirPlace,
    value_expression: ExpressionId,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    if crate::collections::store(destination, value_expression, span, context) {
        context.builder.emit_void(Operation::StmtExit, vec![], span);
        return;
    }
    if crate::records::expression_width(value_expression, context.expression_context.module)
        .is_some()
    {
        crate::records::lower_record_assignment(destination, value_expression, span, context);
        context.builder.emit_void(Operation::StmtExit, vec![], span);
        return;
    }
    let value = lower_expression(
        value_expression,
        context.expression_context,
        context.environment,
        context.builder,
    );
    store_value(destination, (value, span), context);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn store_value(
    destination: &HirPlace,
    target: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) {
    let (value, span) = target;
    match destination {
        HirPlace::Local(local_id) => lower_assign_local(*local_id, value, span, context),
        HirPlace::Field { receiver, field } => {
            lower_assign_field(*receiver, field.0, (value, span), context);
        }
        HirPlace::Element { array, indices } => {
            lower_assign_element(*array, indices, (value, span), context);
        }
        HirPlace::WholeArray(local_id) => lower_assign_whole_array(*local_id, value, context),
        HirPlace::RecordField { .. } => {
            let module = context.expression_context.module;
            for local_id in crate::records::destination_targets(destination, module) {
                lower_assign_local(local_id, value, span, context);
            }
        }
    }
}

pub(crate) fn lower_assign_local(
    local_id: LocalId,
    value: ValueId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    initialize_addressed_local(local_id, span, context);
    if let Some(cell) = context.environment.get_cell(local_id) {
        context.builder.emit_void(
            Operation::CellStore,
            vec![Operand::Value(cell), Operand::Value(value)],
            span,
        );
    } else {
        context.environment.bind_value(local_id, value);
        context.environment.mark_assigned(local_id);
        record_origin_entry(local_id, value, context);
    }
}

fn lower_assign_field(
    receiver: ExpressionId,
    field_number: u32,
    target: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) {
    let (value, span) = target;
    let receiver_value = lower_expression(
        receiver,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let field_name = resolve_field_name(field_number, context);
    context.builder.emit_void(
        Operation::ObjectStore,
        vec![
            Operand::Value(receiver_value),
            Operand::Identifier(field_name),
            Operand::Value(value),
        ],
        span,
    );
}

fn lower_assign_element(
    array: ExpressionId,
    indices: &[ExpressionId],
    target: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) {
    let (value, span) = target;
    let array_value = lower_expression(
        array,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let mut operands = vec![Operand::Value(array_value)];
    for &index_expression in indices {
        operands.push(Operand::Value(lower_expression(
            index_expression,
            context.expression_context,
            context.environment,
            context.builder,
        )));
    }
    operands.push(Operand::Value(value));
    context
        .builder
        .emit_void(Operation::ArrayStore, operands, span);
}

fn lower_assign_whole_array(
    local_id: LocalId,
    value: ValueId,
    context: &mut StatementContext<'_, '_>,
) {
    context.environment.bind_value(local_id, value);
    context.environment.mark_assigned(local_id);
    record_origin_entry(local_id, value, context);
}
pub use crate::statements_read::lower_read;

pub fn lower_dimension(
    dimensions: &[HirDimension],
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    for dimension in dimensions {
        lower_single_dimension(dimension, span, context);
    }
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_single_dimension(
    dimension: &HirDimension,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let mut operands = Vec::new();
    let element_type = get_local_ir_type(dimension.local, context.expression_context.module);
    operands.push(Operand::Type(element_type));
    for &dimension_expression in &dimension.dimensions {
        operands.push(Operand::Value(lower_expression(
            dimension_expression,
            context.expression_context,
            context.environment,
            context.builder,
        )));
    }
    let array_value = context.builder.next_value();
    context
        .builder
        .emit_with_target(Operation::ArrayNew, operands, (Some(array_value), span));
    let origin = bind_dimension(dimension.local, array_value, (span, context));
    context.environment.mark_assigned(dimension.local);
    record_origin_entry(dimension.local, origin, context);
}

pub(crate) fn record_origin_entry(
    local_id: LocalId,
    value: ValueId,
    context: &mut StatementContext<'_, '_>,
) {
    let local_name = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index))
        .map(|local| local.name.clone())
        .unwrap_or_else(|| format!("v{}", local_id.0));
    context.origins.push(OriginEntry {
        visibility: None,
        function: context.builder.name.clone(),
        value,
        variable: VariableId(local_id.0),
        name: local_name,
    });
}

pub(crate) fn resolve_field_name(field_number: u32, context: &StatementContext<'_, '_>) -> String {
    usize::try_from(field_number)
        .ok()
        .and_then(|_field_position| {
            context
                .expression_context
                .module
                .classes
                .iter()
                .flat_map(|class_declaration| &class_declaration.fields)
                .find(|candidate_field| candidate_field.id.0 == field_number)
        })
        .map(|candidate_field| candidate_field.name.clone())
        .unwrap_or_else(|| "field".to_owned())
}

fn bind_dimension(
    local: LocalId,
    array_value: ValueId,
    (span, context): (Option<IrSpan>, &mut StatementContext<'_, '_>),
) -> ValueId {
    if crate::address_taken::contains(local, context.expression_context.module) {
        let cell = context.builder.next_value();
        let kind = get_local_ir_type(local, context.expression_context.module);
        context.builder.emit_with_target(
            Operation::CellLocal,
            vec![Operand::Type(kind)],
            (Some(cell), span),
        );
        context.builder.emit_void(
            Operation::CellStore,
            vec![Operand::Value(cell), Operand::Value(array_value)],
            span,
        );
        context.environment.bind_cell(local, cell);
        cell
    } else {
        context.environment.bind_value(local, array_value);
        array_value
    }
}

fn initialize_addressed_local(
    local: LocalId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    if context.environment.get_cell(local).is_none()
        && context.environment.get_value(local).is_none()
        && crate::address_taken::contains(local, context.expression_context.module)
    {
        crate::statements_declare::lower_single_declare(local, span, context);
    }
}
