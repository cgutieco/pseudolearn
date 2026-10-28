#![forbid(unsafe_code)]

use crate::environment::get_local_ir_type;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements_assignment::{record_origin_entry, resolve_field_name};
use crate::types::lower_type;
use pseudolearn_ir::{IrSpan, IrType, Operand, Operation};
use pseudolearn_semantic::expression_model::HirPlace;
use pseudolearn_semantic::identities::{ExpressionId, LocalId};
use pseudolearn_semantic::types::Type;
use pseudolearn_source::Span;

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
        match place {
            HirPlace::Local(local_id) => lower_read_local(*local_id, span, context),
            HirPlace::Field { receiver, field } => {
                lower_read_field(*receiver, field.0, span, context);
            }
            HirPlace::Element { array, indices } => {
                lower_read_element(*array, indices, span, context);
            }
            HirPlace::WholeArray(_) => {}
            HirPlace::RecordField { .. } => {
                let module = context.expression_context.module;
                for local_id in crate::records::destination_targets(place, module) {
                    lower_read_local(local_id, span, context);
                }
            }
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

fn lower_read_field(
    receiver: ExpressionId,
    field_number: u32,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
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
    let target_type = field_type(field_number, context);
    let read_value = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::InRead,
        vec![Operand::Type(target_type)],
        (Some(read_value), span),
    );
    context.builder.emit_void(
        Operation::CellStore,
        vec![Operand::Value(cell), Operand::Value(read_value)],
        span,
    );
}

fn lower_read_element(
    array: ExpressionId,
    indices: &[ExpressionId],
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
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
    let cell = context.builder.next_value();
    context
        .builder
        .emit_with_target(Operation::CellElement, operands, (Some(cell), span));
    let target_type = element_type(array, context);
    let read_value = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::InRead,
        vec![Operand::Type(target_type)],
        (Some(read_value), span),
    );
    context.builder.emit_void(
        Operation::CellStore,
        vec![Operand::Value(cell), Operand::Value(read_value)],
        span,
    );
}

fn field_type(field_number: u32, context: &StatementContext<'_, '_>) -> IrType {
    usize::try_from(field_number)
        .ok()
        .and_then(|_| {
            context
                .expression_context
                .module
                .classes
                .iter()
                .flat_map(|class| &class.fields)
                .find(|candidate| candidate.id.0 == field_number)
        })
        .map(|field| lower_type(field.type_id, context.expression_context.module))
        .unwrap_or(IrType::Unit)
}

fn element_type(array: ExpressionId, context: &StatementContext<'_, '_>) -> IrType {
    let index = usize::try_from(array.0).unwrap_or(0);
    context
        .expression_context
        .module
        .expressions
        .types
        .get(index)
        .and_then(|type_id| {
            match context
                .expression_context
                .module
                .types
                .representation(*type_id)
            {
                Type::Array { element, .. } => {
                    Some(lower_type(element, context.expression_context.module))
                }
                _ => None,
            }
        })
        .unwrap_or(IrType::Unit)
}
