#![forbid(unsafe_code)]

use crate::builder::is_current_block_terminated;
use crate::environment::VariableEnvironment;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{BlockId, Operand, Operation};
use pseudolearn_semantic::identities::{ExpressionId, StatementId};
use pseudolearn_semantic::statement_model::HirCase;
use pseudolearn_source::Span;

pub struct SwitchStatementDescriptor<'context_lifetime> {
    pub selector: ExpressionId,
    pub cases: &'context_lifetime [HirCase],
    pub default_body: &'context_lifetime [StatementId],
    pub statement_span: Span,
}

pub fn lower_switch(
    descriptor: &SwitchStatementDescriptor<'_>,
    context: &mut StatementContext<'_, '_>,
) {
    let span =
        crate::spans::resolve_span(descriptor.statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, Vec::new(), span);
    lower_after_entry(descriptor, context);
}

pub(crate) fn lower_after_entry(
    descriptor: &SwitchStatementDescriptor<'_>,
    context: &mut StatementContext<'_, '_>,
) {
    let (exit, default, blocks) = select_blocks(descriptor, context);
    let mut exits = lower_cases(
        descriptor.cases,
        &blocks,
        descriptor.statement_span,
        context,
    );
    context.builder.set_current_block(default);
    let span =
        crate::spans::resolve_span(descriptor.statement_span, context.expression_context.source);
    let decision = if descriptor.default_body.is_empty() {
        Operation::DecideNone
    } else {
        Operation::DecideDefault
    };
    context.builder.emit_void(decision, Vec::new(), span);
    if let Some(exit) = body(descriptor.default_body, context) {
        exits.push(exit);
    }
    crate::switch_join::finish(&exits, exit, context);
    let span =
        crate::spans::resolve_span(descriptor.statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtExit, Vec::new(), span);
}

fn decide(ordinal: Option<usize>, statement_span: Span, context: &mut StatementContext<'_, '_>) {
    let span = crate::spans::resolve_span(statement_span, context.expression_context.source);
    if let Some(ordinal) = ordinal {
        let value = context.builder.next_value();
        context.builder.emit_with_target(
            Operation::ConstI64,
            vec![Operand::LiteralI64(i64::try_from(ordinal).unwrap_or(0))],
            (Some(value), None),
        );
        context
            .builder
            .emit_void(Operation::DecideCase, vec![Operand::Value(value)], span);
    } else {
        context
            .builder
            .emit_void(Operation::DecideDefault, Vec::new(), span);
    }
}

fn body(
    body: &[StatementId],
    context: &mut StatementContext<'_, '_>,
) -> Option<(BlockId, VariableEnvironment)> {
    let mut environment = context.environment.clone();
    let mut branch = StatementContext {
        expression_context: context.expression_context,
        environment: &mut environment,
        builder: context.builder,
        origins: context.origins,
    };
    crate::statements::lower_statement_list(body, &mut branch);
    if is_current_block_terminated(context.builder) {
        None
    } else {
        context
            .builder
            .current_block
            .map(|block| (block, environment))
    }
}

fn lower_cases(
    cases: &[HirCase],
    blocks: &[BlockId],
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> Vec<(BlockId, VariableEnvironment)> {
    let mut exits = Vec::new();
    for (ordinal, (case, block)) in cases.iter().zip(blocks).enumerate() {
        context.builder.set_current_block(*block);
        decide(Some(ordinal), span, context);
        if let Some(exit) = body(&case.body, context) {
            exits.push(exit);
        }
    }
    exits
}

fn select_blocks(
    descriptor: &SwitchStatementDescriptor<'_>,
    context: &mut StatementContext<'_, '_>,
) -> (BlockId, BlockId, Vec<BlockId>) {
    let selector = crate::expressions::lower_expression(
        descriptor.selector,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let exit = context.builder.create_block();
    let default = context.builder.create_block();
    let blocks: Vec<_> = descriptor
        .cases
        .iter()
        .map(|_| context.builder.create_block())
        .collect();
    crate::switch_dispatch::dispatch(
        descriptor.cases,
        (selector, descriptor.selector),
        (&blocks, default),
        context,
    );
    (exit, default, blocks)
}
