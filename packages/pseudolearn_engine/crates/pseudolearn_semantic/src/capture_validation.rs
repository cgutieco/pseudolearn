use crate::identities::LocalId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;
use std::collections::BTreeSet;

pub(crate) fn record(session: &mut AnalysisSession<'_>, local: LocalId, span: Span) {
    session.assignment.captures.push((local, span));
}

pub(crate) fn finish(session: &mut AnalysisSession<'_>) {
    let captures = std::mem::take(&mut session.assignment.captures);
    let mut reported = BTreeSet::new();
    for (local, span) in captures {
        let Some(reassignment) = session.assignment.reassigned.get(&local).copied() else {
            continue;
        };
        if !reported.insert((local, span.source_id, span.start)) {
            continue;
        }
        report(session, local, span, reassignment);
    }
}

fn report(session: &mut AnalysisSession<'_>, local: LocalId, span: Span, reassignment: Span) {
    let Some(declaration) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
    else {
        return;
    };
    let kind = session.module.types.get(declaration.type_id);
    let argument = crate::diagnostic_arguments::type_argument(session, &kind);
    let mut diagnostic = Diagnostic::new(DiagnosticCode::MutableClosureCapture, span)
        .with_argument("lexeme", &declaration.name)
        .with_related(reassignment);
    diagnostic.arguments.insert("type".to_owned(), argument);
    session.diagnostics.push(diagnostic);
}
