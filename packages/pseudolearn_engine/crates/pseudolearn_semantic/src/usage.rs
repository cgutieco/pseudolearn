use crate::hir::{FunctionKind, Passing};
use crate::identities::{FunctionId, LocalId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};

pub(crate) fn unused(session: &mut AnalysisSession<'_>) {
    if session
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
    {
        return;
    }
    unused_functions(session);
    unused_locals(session);
}

fn unused_locals(session: &mut AnalysisSession<'_>) {
    let components: std::collections::BTreeSet<LocalId> = session
        .module
        .record_locals
        .values()
        .flatten()
        .copied()
        .collect();
    for index in 0..session.module.locals.len() {
        let Some(local) = session.module.locals.get(index).cloned() else {
            continue;
        };
        let identifier = LocalId(u32::try_from(index).unwrap_or(u32::MAX));
        if local.name.starts_with('$') {
            continue;
        }
        if components.contains(&identifier) {
            continue;
        }
        if session.invalid.contains(&identifier)
            || session.reads.contains(&identifier)
            || (session.assignment.reused_controls.contains(&identifier)
                && !session.writes.contains(&identifier))
            || (local.parameter
                && local.passing == Passing::Reference
                && session.writes.contains(&identifier))
        {
            continue;
        }
        report_unused_local(session, identifier, &local);
    }
}

fn unused_functions(session: &mut AnalysisSession<'_>) {
    let exported: std::collections::BTreeSet<FunctionId> =
        session.module.units.exported.iter().copied().collect();
    for index in 0..session.module.functions.len() {
        let identifier = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
        session.enter_function(index);
        let Some(function) = session.module.functions.get(index).cloned() else {
            continue;
        };
        if session.module.closures.contains_key(&identifier) {
            continue;
        }
        if !matches!(
            function.kind,
            FunctionKind::Procedure | FunctionKind::Function
        ) || session.called.contains(&identifier)
            || exported.contains(&identifier)
        {
            continue;
        }
        session.named_report(
            DiagnosticCode::UnusedSubroutine,
            function.syntax,
            &function.name,
        );
    }
}

fn report_unused_local(
    session: &mut AnalysisSession<'_>,
    identifier: LocalId,
    local: &crate::hir::HirLocal,
) {
    let code = if local.parameter {
        DiagnosticCode::UnusedParameter
    } else if session.writes.contains(&identifier) {
        DiagnosticCode::VariableAssignedNeverRead
    } else {
        DiagnosticCode::VariableDeclaredNeverUsed
    };
    let diagnostic = pseudolearn_diagnostics::Diagnostic::new(code, local.span)
        .with_argument("lexeme", &local.name);
    session.diagnostics.push(diagnostic);
}
