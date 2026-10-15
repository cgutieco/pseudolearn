#![forbid(unsafe_code)]

use crate::environment::{BranchMergeInputs, VariableEnvironment, merge_branch_environments};
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use pseudolearn_ir::{BlockId, Operand, Operation};
use pseudolearn_semantic::identities::{ExpressionId, StatementId};
use pseudolearn_source::Span;

pub struct ConditionalBranch<'context_lifetime> {
    pub condition: ExpressionId,
    pub affirmative: &'context_lifetime [StatementId],
    pub negative: &'context_lifetime [StatementId],
    pub statement_span: Span,
}

pub fn lower_conditional(branch: &ConditionalBranch<'_>, context: &mut StatementContext<'_, '_>) {
    let span = resolve_span(branch.statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);

    let condition_value = lower_expression(
        branch.condition,
        context.expression_context,
        context.environment,
        context.builder,
    );
    context.builder.emit_void(
        Operation::DecideBool,
        vec![Operand::Value(condition_value)],
        span,
    );

    let then_block = context.builder.create_block();
    let else_block = context.builder.create_block();
    let join_block = context.builder.create_block();

    emit_conditional_branch(condition_value, (then_block, else_block), context);
    let (then_environment, then_end_block) =
        execute_branch(branch.affirmative, then_block, context);
    let (else_environment, else_end_block) = execute_branch(branch.negative, else_block, context);

    finalize_conditional(
        BranchMergeInputs {
            then_environment: &then_environment,
            else_environment: &else_environment,
            join_block,
            then_block: then_end_block,
            else_block: else_end_block,
        },
        span,
        context,
    );
}

fn emit_conditional_branch(
    condition_value: pseudolearn_ir::ValueId,
    target_blocks: (BlockId, BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    let (then_block, else_block) = target_blocks;
    context.builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition_value),
            Operand::BlockTarget {
                target_block: then_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: else_block,
                arguments: vec![],
            },
        ],
        None,
    );
}

fn execute_branch(
    statements: &[StatementId],
    start_block: BlockId,
    context: &mut StatementContext<'_, '_>,
) -> (VariableEnvironment, BlockId) {
    context.builder.set_current_block(start_block);
    let mut branch_environment = context.environment.clone();
    let mut branch_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut branch_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(statements, &mut branch_context);
    let end_block = context.builder.current_block.unwrap_or(start_block);
    (branch_environment, end_block)
}

fn finalize_conditional(
    inputs: BranchMergeInputs<'_>,
    span: Option<pseudolearn_ir::IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let join_block = inputs.join_block;
    *context.environment = merge_branch_environments(
        inputs,
        context.builder,
        context.origins,
        context.expression_context.module,
    );
    context.builder.set_current_block(join_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}
