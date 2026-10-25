use crate::identities::FunctionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn bodies(session: &mut AnalysisSession<'_>) {
    let registry_diagnostics = session.diagnostics.len();
    let bindings = crate::flow_bindings::FlowBindings::capture(session);
    for _ in 0..=session.module.functions.len() {
        session.diagnostics.truncate(registry_diagnostics);
        bindings.restore(session);
        session.module.expressions = crate::expression_model::ExpressionColumns::default();
        session.module.statements = crate::statement_model::StatementColumns::default();
        session.reads.clear();
        session.writes.clear();
        session.called.clear();
        session.signature_changed = false;
        for index in 0..session.module.functions.len() {
            function(session, index);
        }
        if !session.signature_changed {
            break;
        }
    }
}

fn function(session: &mut AnalysisSession<'_>, index: usize) {
    session.enter_function(index);
    let Some(function) = session.module.functions.get(index).cloned() else {
        return;
    };
    session.current = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
    session.returned = false;
    session.pending_results.clear();
    for parameter in &function.parameters {
        if let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            && crate::result_obligations::is_result(
                session,
                &session.module.types.get(local.type_id),
            )
        {
            session.pending_results.insert(*parameter);
        }
    }
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
    crate::result_obligations::finish(session);
    if let Some(function) = session.module.functions.get_mut(index) {
        function.body = body;
    }
}
