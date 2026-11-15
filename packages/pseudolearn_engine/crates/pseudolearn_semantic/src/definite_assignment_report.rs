use crate::definite_assignment_state::{AssignmentCause, PendingArgument};
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;

pub(crate) fn unassigned_read(session: &mut AnalysisSession<'_>, local: LocalId, span: Span) {
    if session.assignment.candidates.contains(&local) {
        session.assignment.not_output.insert(local);
        return;
    }
    let cause = session.assignment.dropped.get(&local).copied();
    report(session, local, span, cause);
}

pub(crate) fn report(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    span: Span,
    cause: Option<(AssignmentCause, Span)>,
) {
    let Some(declaration) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
    else {
        return;
    };
    let (term, origin) = cause.map_or((AssignmentCause::NoAssignment, None), |(cause, origin)| {
        (cause, Some(origin))
    });
    let mut diagnostic = Diagnostic::new(DiagnosticCode::VariableUsedUninitialized, span)
        .with_argument("lexeme", &declaration.name)
        .with_argument("cause", term.term())
        .with_related(declaration.span);
    if let Some(origin) = origin {
        diagnostic = diagnostic.with_related(origin);
    }
    session.diagnostics.push(diagnostic);
}

pub(crate) fn defer_argument(
    session: &mut AnalysisSession<'_>,
    expression: ExpressionId,
    local: LocalId,
) {
    let span = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .copied()
        .unwrap_or_default();
    let cause = session.assignment.dropped.get(&local).copied();
    session.assignment.pending_arguments.push(PendingArgument {
        expression,
        local,
        span,
        cause,
    });
}

pub(crate) fn take_argument(
    session: &mut AnalysisSession<'_>,
    expression: ExpressionId,
) -> Option<PendingArgument> {
    let position = session
        .assignment
        .pending_arguments
        .iter()
        .position(|pending| pending.expression == expression)?;
    Some(session.assignment.pending_arguments.remove(position))
}

pub(crate) fn flush(session: &mut AnalysisSession<'_>, mark: usize) {
    if session.assignment.pending_arguments.len() <= mark {
        return;
    }
    let remaining = session.assignment.pending_arguments.split_off(mark);
    for pending in remaining {
        if session.assignment.candidates.contains(&pending.local) {
            session.assignment.not_output.insert(pending.local);
            continue;
        }
        report(session, pending.local, pending.span, pending.cause);
    }
}
