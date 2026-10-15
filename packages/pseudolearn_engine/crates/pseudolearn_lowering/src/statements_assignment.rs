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
    let value = lower_expression(
        value_expression,
        context.expression_context,
        context.environment,
        context.builder,
    );

    match destination {
        HirPlace::Local(local_id) => lower_assign_local(*local_id, value, span, context),
        HirPlace::Field { receiver, field } => {
            lower_assign_field(*receiver, field.0, (value, span), context);
        }
        HirPlace::Element { array, indices } => {
            lower_assign_element(*array, indices, (value, span), context);
        }
        HirPlace::WholeArray(local_id) => lower_assign_whole_array(*local_id, value, context),
    }
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_assign_local(
    local_id: LocalId,
    value: ValueId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
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
    let cell = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::CellField,
        vec![
            Operand::Value(receiver_value),
            Operand::Identifier(field_name),
        ],
        (Some(cell), span),
    );
    context.builder.emit_void(
        Operation::CellStore,
        vec![Operand::Value(cell), Operand::Value(value)],
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

pub fn lower_read(
    places: &[HirPlace],
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    for place in places {
        if let HirPlace::Local(local_id) = place {
            lower_read_local(*local_id, span, context);
        }
    }
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_read_local(
    local_id: LocalId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let local_type = get_local_ir_type(local_id, context.expression_context.module);
    let read_value = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::InRead,
        vec![Operand::Type(local_type)],
        (Some(read_value), span),
    );
    if let Some(cell) = context.environment.get_cell(local_id) {
        context.builder.emit_void(
            Operation::CellStore,
            vec![Operand::Value(cell), Operand::Value(read_value)],
            span,
        );
    } else {
        context.environment.bind_value(local_id, read_value);
        context.environment.mark_assigned(local_id);
        record_origin_entry(local_id, read_value, context);
    }
}

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
    context.environment.bind_value(dimension.local, array_value);
    context.environment.mark_assigned(dimension.local);
    record_origin_entry(dimension.local, array_value, context);
}

fn record_origin_entry(local_id: LocalId, value: ValueId, context: &mut StatementContext<'_, '_>) {
    let local_name = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index))
        .map(|local| local.name.clone())
        .unwrap_or_else(|| format!("v{}", local_id.0));
    context.origins.push(OriginEntry {
        value,
        variable: VariableId(local_id.0),
        name: local_name,
    });
}

fn resolve_field_name(field_number: u32, context: &StatementContext<'_, '_>) -> String {
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
