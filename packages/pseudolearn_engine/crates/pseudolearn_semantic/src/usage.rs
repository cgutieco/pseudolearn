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
    for index in 0..session.module.locals.len() {
        let Some(local) = session.module.locals.get(index).cloned() else {
            continue;
        };
        let identifier = LocalId(u32::try_from(index).unwrap_or(u32::MAX));
        if session
            .module
            .record_locals
            .values()
            .any(|components| components.contains(&identifier))
        {
            continue;
        }
        mutable_warning(session, identifier, &local);
        if session.invalid.contains(&identifier)
            || session.reads.contains(&identifier)
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
    for index in 0..session.module.functions.len() {
        let identifier = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
        session.enter_function(index);
        let Some(function) = session.module.functions.get(index).cloned() else {
            continue;
        };
        if !matches!(
            function.kind,
            FunctionKind::Procedure | FunctionKind::Function
        ) || session.called.contains(&identifier)
            || session.module.units.exported.contains(&identifier)
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

fn mutable_warning(
    session: &mut AnalysisSession<'_>,
    identifier: LocalId,
    local: &crate::hir::HirLocal,
) {
    if local.mutable
        && !local.parameter
        && !session.writes.contains(&identifier)
        && !matches!(
            session.module.types.get(local.type_id),
            crate::types::Type::Array { .. }
        )
    {
        session
            .diagnostics
            .push(pseudolearn_diagnostics::Diagnostic::new(
                DiagnosticCode::MutableBindingNeverModified,
                local.span,
            ));
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
    let mut diagnostic = pseudolearn_diagnostics::Diagnostic::new(code, local.span)
        .with_argument("lexeme", &local.name);
    diagnostic.severity = code.severity(if session.options.strict {
        "estricto"
    } else {
        "flexible"
    });
    session.diagnostics.push(diagnostic);
}
