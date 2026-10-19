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

    let (exit_block, mut check_block, selector_value) = initialize_switch(descriptor, context);

    for (ordinal, case) in descriptor.cases.iter().enumerate() {
        check_block = lower_switch_case(
            case,
            (check_block, exit_block),
            (selector_value, span, ordinal),
            context,
        );
    }

    lower_switch_default(
        descriptor.default_body,
        (check_block, exit_block),
        span,
        context,
    );

    context.builder.set_current_block(exit_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn initialize_switch(
    descriptor: &SwitchStatementDescriptor<'_>,
    context: &mut StatementContext<'_, '_>,
) -> (BlockId, BlockId, ValueId) {
    let selector_value = lower_expression(
        descriptor.selector,
        context.expression_context,
        context.environment,
        context.builder,
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
    selector: (ValueId, Option<IrSpan>, usize),
    context: &mut StatementContext<'_, '_>,
) -> BlockId {
    let (check_block, exit_block) = blocks;
    let case_body_block = context.builder.create_block();
    let following_check_block = context.builder.create_block();

    lower_case_labels(
        &case.labels,
        (selector.0, selector.1),
        (check_block, case_body_block, following_check_block),
        context,
    );

    context.builder.set_current_block(case_body_block);
    let ordinal = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(
            i64::try_from(selector.2).unwrap_or(i64::MAX),
        )],
        (Some(ordinal), None),
    );
    context.builder.emit_void(
        Operation::DecideCase,
        vec![Operand::Value(ordinal)],
        selector.1,
    );
    execute_case_body(&case.body, (case_body_block, exit_block), context);

    following_check_block
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

fn lower_case_labels(
    labels: &[ExpressionId],
    selector: (ValueId, Option<IrSpan>),
    targets: (BlockId, BlockId, BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    let (initial_check, case_body, following_check) = targets;
    if labels.is_empty() {
        emit_no_case_match(initial_check, following_check, context);
        return;
    }
    let mut check_block = initial_check;
    for (index, label) in labels.iter().copied().enumerate() {
        context.builder.set_current_block(check_block);
        let next_check = if index.saturating_add(1) < labels.len() {
            context.builder.create_block()
        } else {
            following_check
        };
        let condition = compare_case_label(label, selector, context);
        emit_case_branch(condition, (case_body, next_check), context);
        check_block = next_check;
    }
}

fn compare_case_label(
    label: ExpressionId,
    selector: (ValueId, Option<IrSpan>),
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let (selector_value, span) = selector;
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
    match_value
}

fn emit_no_case_match(
    check_block: BlockId,
    following_check: BlockId,
    context: &mut StatementContext<'_, '_>,
) {
    context.builder.set_current_block(check_block);
    let condition = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::ConstBool,
        vec![Operand::LiteralBool(false)],
        (Some(condition), None),
    );
    emit_case_branch(condition, (following_check, following_check), context);
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

fn lower_switch_default(
    default_body: &[StatementId],
    blocks: (BlockId, BlockId),
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let (check_block, exit_block) = blocks;
    context.builder.set_current_block(check_block);
    let decision = if default_body.is_empty() {
        Operation::DecideNone
    } else {
        Operation::DecideDefault
    };
    context.builder.emit_void(decision, vec![], span);
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
