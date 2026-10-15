use crate::identities::FunctionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn bodies(session: &mut AnalysisSession<'_>) {
    let registry_diagnostics = session.diagnostics.len();
    for _ in 0..=session.module.functions.len() {
        session.diagnostics.truncate(registry_diagnostics);
        session.module.expressions = crate::expression_model::ExpressionColumns::default();
        session.module.statements = crate::statement_model::StatementColumns::default();
        session.reads.clear();
        session.writes.clear();
        session.called.clear();
        session.signature_changed = false;
        for (index, local) in session.module.locals.iter().enumerate() {
            if let Some(initialized) = session.initialized.get_mut(index) {
                *initialized = local.parameter;
            }
        }
        for index in 0..session.module.functions.len() {
            function(session, index);
        }
        if !session.signature_changed {
            break;
        }
    }
}

fn function(session: &mut AnalysisSession<'_>, index: usize) {
    let Some(function) = session.module.functions.get(index).cloned() else {
        return;
    };
    session.current = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
    session.returned = false;
    let body = session
        .child(function.syntax, NodeKind::Body)
        .map(|body| crate::statement_checker::body(session, body))
        .unwrap_or_default();
    if session.module.types.get(function.result) != Type::Unit && !session.returned {
        session.named_report(
            DiagnosticCode::SubroutineWithoutReturn,
            function.syntax,
            &function.name,
        );
    }
    if let Some(function) = session.module.functions.get_mut(index) {
        function.body = body;
    }
}
