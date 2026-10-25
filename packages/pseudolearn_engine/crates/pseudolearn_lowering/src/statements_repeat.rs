#![forbid(unsafe_code)]

use crate::environment::VariableEnvironment;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use crate::statements_while::{bind_loop_parameters, collect_modified_locals, jump_to_loop_header};
use pseudolearn_ir::{BlockId, IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::{ExpressionId, LocalId, StatementId};
use pseudolearn_source::Span;

pub fn lower_repeat(
    body: &[StatementId],
    condition: ExpressionId,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    let mut loop_locals = collect_modified_locals(body, context.expression_context.module);
    loop_locals.retain(|local_id| {
        context.environment.get_cell(*local_id).is_none()
            && context.environment.get_value(*local_id).is_some()
    });

    let body_header = context.builder.create_block();
    jump_to_loop_header(body_header, &loop_locals, context);

    context.builder.set_current_block(body_header);
    let mut body_environment = context.environment.clone();
    bind_loop_parameters(body_header, &loop_locals, &mut body_environment, context);

    execute_repeat_body(body, &mut body_environment, context);

    let condition_span = repeat_condition_span(condition, context);
    let condition_value =
        evaluate_repeat_condition(condition, condition_span, &mut body_environment, context);
    let exit_block = context.builder.create_block();
    emit_repeat_branch(
        condition_value,
        (exit_block, body_header),
        (&loop_locals, &body_environment),
        context,
    );

    context.builder.set_current_block(exit_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
    *context.environment = body_environment;
}

fn evaluate_repeat_condition(
    condition: ExpressionId,
    span: Option<IrSpan>,
    environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let condition_value = lower_expression(
        condition,
        context.expression_context,
        environment,
        context.builder,
    );
    context.builder.emit_void(
        Operation::DecideBool,
        vec![Operand::Value(condition_value)],
        span,
    );
    condition_value
}

fn execute_repeat_body(
    body: &[StatementId],
    body_environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) {
    let mut body_context = StatementContext {
        expression_context: context.expression_context,
        environment: body_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(body, &mut body_context);
}

fn emit_repeat_branch(
    condition_value: ValueId,
    blocks: (BlockId, BlockId),
    locals_and_environment: (&[LocalId], &VariableEnvironment),
    context: &mut StatementContext<'_, '_>,
) {
    let (exit_block, body_header) = blocks;
    let (loop_locals, body_environment) = locals_and_environment;
    let mut repeat_arguments = Vec::new();
    for &local_id in loop_locals {
        let next_value = body_environment
            .get_value(local_id)
            .unwrap_or_else(|| context.builder.next_value());
        repeat_arguments.push(next_value);
    }

    context.builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition_value),
            Operand::BlockTarget {
                target_block: exit_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: body_header,
                arguments: repeat_arguments,
            },
        ],
        None,
    );
}

fn repeat_condition_span(
    condition: ExpressionId,
    context: &StatementContext<'_, '_>,
) -> Option<IrSpan> {
    usize::try_from(condition.0)
        .ok()
        .and_then(|index| {
            context
                .expression_context
                .module
                .expressions
                .spans
                .get(index)
        })
        .and_then(|span| resolve_span(*span, context.expression_context.source))
}
