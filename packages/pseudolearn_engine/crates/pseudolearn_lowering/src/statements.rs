#![forbid(unsafe_code)]

use crate::builder::is_current_block_terminated;
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements_assignment::{lower_assign, lower_dimension, lower_read};
use crate::statements_conditional::{ConditionalBranch, lower_conditional};
use crate::statements_declare::lower_declare;
use crate::statements_for::{ForLoopDescriptor, lower_for};
use crate::statements_repeat::lower_repeat;
use crate::statements_switch::{SwitchStatementDescriptor, lower_switch};
use crate::statements_while::lower_while;
use pseudolearn_ir::{Operand, Operation};
use pseudolearn_semantic::identities::{ExpressionId, StatementId};
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_source::Span;

pub fn lower_statement_list(statements: &[StatementId], context: &mut StatementContext<'_, '_>) {
    for &statement_id in statements {
        if is_current_block_terminated(context.builder) {
            break;
        }
        lower_single_statement(statement_id, context);
    }
}

pub fn lower_single_statement(statement_id: StatementId, context: &mut StatementContext<'_, '_>) {
    let index = usize::try_from(statement_id.0).unwrap_or(0);
    let Some(kind) = context
        .expression_context
        .module
        .statements
        .kinds
        .get(index)
        .cloned()
    else {
        return;
    };
    let statement_span = context
        .expression_context
        .module
        .statements
        .spans
        .get(index)
        .copied()
        .unwrap_or_default();

    dispatch_statement(&kind, statement_span, context);
}

fn dispatch_statement(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    if dispatch_simple_statement(statement, span, context) {
        return;
    }
    dispatch_control_statement(statement, span, context);
}

fn dispatch_simple_statement(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    match statement {
        HirStatement::Declare(locals) => {
            lower_declare(locals, span, context);
            true
        }
        HirStatement::Assign { destination, value } => {
            lower_assign(destination, *value, span, context);
            true
        }
        HirStatement::Write { values, newline } => {
            lower_write(values, *newline, span, context);
            true
        }
        HirStatement::Read(places) => {
            lower_read(places, span, context);
            true
        }
        HirStatement::Call(expression_id) => {
            lower_statement_call(*expression_id, span, context);
            true
        }
        HirStatement::Dimension(dimensions) => {
            lower_dimension(dimensions, span, context);
            true
        }
        HirStatement::Return(expression_option) => {
            lower_return(*expression_option, span, context);
            true
        }
        _ => false,
    }
}

fn dispatch_control_statement(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    if dispatch_loop_statement(statement, span, context) {
        return;
    }
    dispatch_branch_statement(statement, span, context);
}

fn dispatch_loop_statement(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    match statement {
        HirStatement::While { condition, body } => {
            lower_while(*condition, body, span, context);
            true
        }
        HirStatement::Repeat { body, condition } => {
            lower_repeat(body, *condition, span, context);
            true
        }
        HirStatement::For {
            control,
            initial,
            ending,
            step,
            body,
        } => {
            lower_for(
                &ForLoopDescriptor {
                    control: *control,
                    initial: *initial,
                    ending: *ending,
                    step: *step,
                    body,
                    statement_span: span,
                },
                context,
            );
            true
        }
        _ => false,
    }
}

fn dispatch_branch_statement(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    match statement {
        HirStatement::Conditional {
            condition,
            affirmative,
            negative,
        } => lower_conditional(
            &ConditionalBranch {
                condition: *condition,
                affirmative,
                negative,
                statement_span: span,
            },
            context,
        ),
        HirStatement::Switch {
            selector,
            cases,
            default,
        } => lower_switch(
            &SwitchStatementDescriptor {
                selector: *selector,
                cases,
                default_body: default,
                statement_span: span,
            },
            context,
        ),
        _ => {}
    }
}

fn lower_write(
    values: &[ExpressionId],
    newline: bool,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    if values.is_empty() && !newline {
        context.builder.emit_void(Operation::StmtExit, vec![], span);
        return;
    }
    let mut operands = Vec::new();
    for &expression_id in values {
        let value = crate::enum_output::lower_value(
            expression_id,
            context.expression_context,
            context.environment,
            context.builder,
        );
        operands.push(Operand::Value(value));
    }
    ensure_output_value(&mut operands, context.builder);
    if newline {
        operands.push(Operand::Newline);
    }
    context
        .builder
        .emit_void(Operation::OutWrite, operands, span);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_statement_call(
    expression_id: ExpressionId,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    lower_expression(
        expression_id,
        context.expression_context,
        context.environment,
        context.builder,
    );
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

fn lower_return(
    expression_option: Option<ExpressionId>,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    if let Some(expression_id) = expression_option {
        if crate::records::lower_return(expression_id, context) {
            context.builder.emit_void(Operation::StmtExit, vec![], span);
            context.builder.emit_void(Operation::Return, vec![], span);
            return;
        }
        let return_value = lower_expression(
            expression_id,
            context.expression_context,
            context.environment,
            context.builder,
        );
        context.builder.emit_void(Operation::StmtExit, vec![], span);
        context
            .builder
            .emit_void(Operation::Return, vec![Operand::Value(return_value)], span);
    } else {
        context.builder.emit_void(Operation::StmtExit, vec![], span);
        context.builder.emit_void(Operation::Return, vec![], span);
    }
}

fn ensure_output_value(operands: &mut Vec<Operand>, builder: &mut crate::builder::FunctionBuilder) {
    if operands.is_empty() {
        let empty = builder.next_value();
        builder.emit_with_target(
            Operation::ConstStr,
            vec![Operand::LiteralStr(String::new())],
            (Some(empty), None),
        );
        operands.push(Operand::Value(empty));
    }
}
