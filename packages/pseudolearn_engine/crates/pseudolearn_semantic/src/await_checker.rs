use crate::expression_checker::{ExpressionPurpose, check_for};
use crate::expression_model::HirExpression;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let operand = session.children(node).first().copied().unwrap_or(node);
    let allowed = context(session, node);
    let call_node = awaited_call(session, operand);
    if let Some(call_node) = call_node {
        session.awaited_calls.push(call_node);
    }
    let previous_task_handle = session.control.awaiting_task_handle;
    session.control.awaiting_task_handle = true;
    let expression = check_for(session, operand, purpose);
    session.control.awaiting_task_handle = previous_task_handle;
    if let Type::Task(payload) = session.expression_type(expression) {
        return session.emit(
            HirExpression::AwaitTask(expression),
            payload,
            session.span(node),
        );
    }
    if call_node.is_some() {
        session.awaited_calls.pop();
    }
    if allowed && !valid_operand(session, expression) {
        session.report(DiagnosticCode::AwaitOperandInvalid, node);
    }
    expression
}

pub(crate) fn context(session: &mut AnalysisSession<'_>, node: usize) -> bool {
    if session.control.cleaning {
        session.report(DiagnosticCode::AwaitInsideDefer, node);
        return false;
    }
    let current = usize::try_from(session.current.0)
        .ok()
        .and_then(|index| session.module.functions.get(index));
    if !current.is_some_and(|function| function.suspendible) {
        session.report(DiagnosticCode::AwaitOutsideSuspendible, node);
        return false;
    }
    true
}

fn awaited_call(session: &AnalysisSession<'_>, node: usize) -> Option<usize> {
    match session.kind(node) {
        NodeKind::Postfix if postfix_is_call(session, node) => Some(node),
        NodeKind::Unary | NodeKind::Primary => session
            .children(node)
            .first()
            .copied()
            .and_then(|child| awaited_call(session, child)),
        _ => None,
    }
}

fn postfix_is_call(session: &AnalysisSession<'_>, node: usize) -> bool {
    if session.child(node, NodeKind::Arguments).is_some() {
        return true;
    }
    session
        .tree
        .operator_tokens
        .get(node)
        .copied()
        .flatten()
        .and_then(|token| usize::try_from(token).ok())
        .and_then(|token| session.tree.tokens.kind(token))
        == Some(TokenKind::LeftParenthesis)
}

fn valid_operand(session: &AnalysisSession<'_>, expression: ExpressionId) -> bool {
    let model = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index));
    match model {
        Some(HirExpression::Local(_))
            if matches!(session.expression_type(expression), Type::Task(_)) =>
        {
            true
        }
        Some(HirExpression::Effect { .. } | HirExpression::Channel(_)) => true,
        Some(HirExpression::Call { function, .. }) => usize::try_from(function.0)
            .ok()
            .and_then(|index| session.module.functions.get(index))
            .is_some_and(|function| function.suspendible),
        _ => false,
    }
}
