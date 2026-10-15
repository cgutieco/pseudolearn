#![forbid(unsafe_code)]

use crate::builder::is_current_block_terminated;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use pseudolearn_ir::{BlockId, IrSpan, Operand, Operation, PredicateKind, ValueId};
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
    let span = resolve_span(descriptor.statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);

    let (exit_block, mut check_block, selector_value) =
        initialize_switch(descriptor, span, context);

    for case in descriptor.cases {
        check_block = lower_switch_case(
            case,
            (check_block, exit_block),
            (selector_value, span),
            context,
        );
    }

    lower_switch_default(descriptor.default_body, (check_block, exit_block), context);

    context.builder.set_current_block(exit_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn initialize_switch(
    descriptor: &SwitchStatementDescriptor<'_>,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) -> (BlockId, BlockId, ValueId) {
    let selector_value = lower_expression(
        descriptor.selector,
        context.expression_context,
        context.environment,
        context.builder,
    );
    context.builder.emit_void(
        Operation::DecideCase,
        vec![Operand::Value(selector_value)],
        span,
    );

    let exit_block = context.builder.create_block();
    let check_block = context.builder.create_block();
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: check_block,
            arguments: vec![],
        }],
        None,
    );
    (exit_block, check_block, selector_value)
}

fn lower_switch_case(
    case: &HirCase,
    blocks: (BlockId, BlockId),
    selector: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) -> BlockId {
    let (check_block, exit_block) = blocks;
    context.builder.set_current_block(check_block);
    let case_body_block = context.builder.create_block();
    let following_check_block = context.builder.create_block();

    let condition = evaluate_case_labels(&case.labels, selector, context);
    emit_case_branch(condition, (case_body_block, following_check_block), context);

    execute_case_body(&case.body, (case_body_block, exit_block), context);

    following_check_block
}

fn emit_case_branch(
    condition: ValueId,
    targets: (BlockId, BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    let (case_body_block, following_check_block) = targets;
    context.builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition),
            Operand::BlockTarget {
                target_block: case_body_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: following_check_block,
                arguments: vec![],
            },
        ],
        None,
    );
}

fn execute_case_body(
    body: &[StatementId],
    blocks: (BlockId, BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    let (case_body_block, exit_block) = blocks;
    context.builder.set_current_block(case_body_block);
    let mut case_environment = context.environment.clone();
    let mut case_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut case_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(body, &mut case_context);

    if !is_current_block_terminated(context.builder) {
        context.builder.emit_void(
            Operation::Jump,
            vec![Operand::BlockTarget {
                target_block: exit_block,
                arguments: vec![],
            }],
            None,
        );
    }
}

fn evaluate_case_labels(
    labels: &[ExpressionId],
    selector: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let (selector_value, span) = selector;
    let mut matched_condition = None;
    for &label in labels {
        let label_value = lower_expression(
            label,
            context.expression_context,
            context.environment,
            context.builder,
        );
        let match_value = context.builder.next_value();
        context.builder.emit_with_target(
            Operation::IntCmp,
            vec![
                Operand::Predicate(PredicateKind::Equal),
                Operand::Value(selector_value),
                Operand::Value(label_value),
            ],
            (Some(match_value), span),
        );
        matched_condition = Some(match_value);
    }
    matched_condition.unwrap_or_else(|| {
        let fallback = context.builder.next_value();
        context.builder.emit_with_target(
            Operation::ConstBool,
            vec![Operand::LiteralBool(false)],
            (Some(fallback), None),
        );
        fallback
    })
}

fn lower_switch_default(
    default_body: &[StatementId],
    blocks: (BlockId, BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    let (check_block, exit_block) = blocks;
    context.builder.set_current_block(check_block);
    let mut default_environment = context.environment.clone();
    let mut default_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut default_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(default_body, &mut default_context);
    if !is_current_block_terminated(context.builder) {
        context.builder.emit_void(
            Operation::Jump,
            vec![Operand::BlockTarget {
                target_block: exit_block,
                arguments: vec![],
            }],
            None,
        );
    }
}
