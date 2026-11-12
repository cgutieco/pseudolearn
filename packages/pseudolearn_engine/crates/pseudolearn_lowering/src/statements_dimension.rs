#![forbid(unsafe_code)]

use crate::environment::get_local_ir_type;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements_assignment::record_origin_entry;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::{ExpressionId, LocalId};
use pseudolearn_semantic::statement_model::HirDimension;
use pseudolearn_source::Span;

pub fn lower_dimension(
    dimensions: &[HirDimension],
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    let mut evaluated: Vec<(ExpressionId, ValueId)> = Vec::new();
    for dimension in dimensions {
        lower_single_dimension(dimension, (span, &mut evaluated), context);
    }
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_single_dimension(
    dimension: &HirDimension,
    (span, evaluated): (Option<IrSpan>, &mut Vec<(ExpressionId, ValueId)>),
    context: &mut StatementContext<'_, '_>,
) {
    let mut operands = Vec::new();
    let element_type = get_local_ir_type(dimension.local, context.expression_context.module);
    operands.push(Operand::Type(element_type));
    for &dimension_expression in &dimension.dimensions {
        let cached = evaluated
            .iter()
            .find(|(expression, _)| *expression == dimension_expression)
            .map(|(_, value)| *value);
        let value = cached.unwrap_or_else(|| {
            let lowered = lower_expression(
                dimension_expression,
                context.expression_context,
                context.environment,
                context.builder,
            );
            evaluated.push((dimension_expression, lowered));
            lowered
        });
        operands.push(Operand::Value(value));
    }
    let array_value = context.builder.next_value();
    context
        .builder
        .emit_with_target(Operation::ArrayNew, operands, (Some(array_value), span));
    let origin = bind_dimension(dimension.local, array_value, (span, context));
    context.environment.mark_assigned(dimension.local);
    record_origin_entry(dimension.local, origin, context);
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
