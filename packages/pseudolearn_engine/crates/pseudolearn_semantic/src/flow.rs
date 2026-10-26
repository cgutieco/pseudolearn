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
        crate::generic_discard::check_functions(session);
        if !session.signature_changed {
            break;
        }
    }
}

pub(crate) fn function(session: &mut AnalysisSession<'_>, index: usize) {
    session.enter_function(index);
    let Some(function) = session.module.functions.get(index).cloned() else {
        return;
    };
    session.current = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
    prepare_function(session, &function);
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

fn prepare_function(session: &mut AnalysisSession<'_>, function: &crate::hir::HirFunction) {
    session.bindings = crate::block_scopes::BlockScopes::default();
    session.bindings.enter();
    for parameter in &function.parameters {
        if let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
        {
            session.bindings.insert(
                local.name.clone(),
                crate::block_scopes::BindingTarget::Local(*parameter),
            );
        }
    }
    for parameter in &function.parameters {
        session
            .module
            .local_visibility
            .insert(*parameter, function.span);
    }
    session.returned = false;
    session.control = crate::control_context::ControlContext::default();
    session.pending_results.clear();
    crate::result_obligations::parameters(session, &function.parameters);
}
