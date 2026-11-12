#![forbid(unsafe_code)]

use crate::environment::get_local_ir_type;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{Operand, Operation, OriginEntry, VariableId};
use pseudolearn_semantic::identities::LocalId;
use pseudolearn_source::Span;

pub fn lower_declare(
    locals: &[LocalId],
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    for &local_id in locals {
        for target in crate::records::targets(local_id, context.expression_context.module) {
            lower_single_declare(target, span, context);
        }
    }
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

pub(crate) fn lower_single_declare(
    local_id: LocalId,
    span: Option<pseudolearn_ir::IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let is_reference = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index))
        .is_some_and(|local| {
            crate::parameter_passing::requires_cell(local, context.expression_context.module)
        });
    let local_type = get_local_ir_type(local_id, context.expression_context.module);

    if is_reference || crate::address_taken::contains(local_id, context.expression_context.module) {
        lower_reference_declare(local_id, local_type, span, context);
    } else {
        lower_value_declare(local_id, local_type, span, context);
    }
}

fn lower_reference_declare(
    local_id: LocalId,
    local_type: pseudolearn_ir::IrType,
    span: Option<pseudolearn_ir::IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let cell = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::CellLocal,
        vec![Operand::Type(local_type)],
        (Some(cell), span),
    );
    context.environment.bind_cell(local_id, cell);
    let local = usize::try_from(local_id.0)
        .ok()
        .and_then(|index| context.expression_context.module.locals.get(index));
    context.origins.push(OriginEntry {
        visibility: None,
        function: context.builder.name.clone(),
        value: cell,
        variable: VariableId(local_id.0),
        name: local.map(|local| local.name.clone()).unwrap_or_default(),
    });
}

fn lower_value_declare(
    local_id: LocalId,
    local_type: pseudolearn_ir::IrType,
    span: Option<pseudolearn_ir::IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let undefined_value = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::ValueUndefined,
        vec![Operand::Type(local_type)],
        (Some(undefined_value), span),
    );
    context.environment.bind_value(local_id, undefined_value);
    let local_name = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index))
        .map(|local| local.name.clone())
        .unwrap_or_else(|| format!("v{}", local_id.0));
    context.origins.push(OriginEntry {
        visibility: None,
        function: context.builder.name.clone(),
        value: undefined_value,
        variable: VariableId(local_id.0),
        name: local_name,
    });
}
