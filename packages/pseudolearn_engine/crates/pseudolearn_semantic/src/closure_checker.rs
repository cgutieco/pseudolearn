use crate::expression_model::HirExpression;
use crate::function_model::{ClosureFrame, HirClosure};
use crate::hir::{FunctionKind, HirFunction};
use crate::identities::{ExpressionId, FunctionId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let parent = session.current;
    let returned = session.returned;
    let pending = std::mem::take(&mut session.pending_results);
    let controls = std::mem::take(&mut session.controls);
    let function = register(session, node);
    session.closure_stack.push(ClosureFrame { function });
    session.bindings.enter();
    crate::local_registry::parameters(session, node);
    let signature = crate::function_types::signature(session, function);
    let kind = crate::function_types::intern(session, signature, node);
    prepare_obligations(session, function);
    add_environment_parameter(session, function);
    session.returned = false;
    let body = session
        .child(node, NodeKind::Body)
        .map(|body| crate::statement_checker::body(session, body))
        .unwrap_or_default();
    finish(session, function, (node, body));
    crate::scope_bindings::leave(session);
    session.closure_stack.pop();
    session.current = parent;
    session.returned = returned;
    session.pending_results = pending;
    session.controls = controls;
    session.emit(
        HirExpression::FunctionValue(function),
        kind,
        session.span(node),
    )
}

fn register(session: &mut AnalysisSession<'_>, node: usize) -> FunctionId {
    let result = session
        .child(node, NodeKind::Type)
        .map(|kind| crate::type_resolution::resolve(session, kind))
        .unwrap_or_else(|| session.module.types.intern(Type::Unit));
    let identifier = FunctionId(u32::try_from(session.module.functions.len()).unwrap_or(u32::MAX));
    session.tag_function();
    session.module.functions.push(HirFunction {
        kind: FunctionKind::Function,
        name: format!("$closure{}", identifier.0),
        owner: None,
        parameters: Vec::new(),
        result,
        body: Vec::new(),
        span: session.span(node),
        closing_span: session.closing_span(node),
        syntax: node,
        private: true,
    });
    session.current = identifier;
    identifier
}

fn add_environment_parameter(session: &mut AnalysisSession<'_>, function: FunctionId) {
    let reference = session.module.types.intern(Type::String);
    let environment =
        crate::closure_locals::create(session, "$environment".to_owned(), reference, true);
    if let Some(model) = usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get_mut(index))
    {
        model.parameters.insert(0, environment);
    }
    session.module.closures.insert(
        function,
        HirClosure {
            environment,
            class: None,
            captures: Vec::new(),
            offsets: Vec::new(),
            layout: None,
        },
    );
}

fn finish(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    (node, body): (usize, Vec<crate::identities::StatementId>),
) {
    let result = usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
        .map(|function| function.result);
    if result.is_some_and(|kind| session.module.types.get(kind) != Type::Unit) && !session.returned
    {
        session.report(DiagnosticCode::SubroutineWithoutReturn, node);
    }
    crate::result_obligations::finish(session);
    crate::capture_environment::finish(session, function, body);
    session.called.insert(function);
}

fn prepare_obligations(session: &mut AnalysisSession<'_>, function: FunctionId) {
    if let Some(model) = crate::hierarchy::function(session, function) {
        let parameters = model.parameters.clone();
        crate::result_obligations::parameters(session, &parameters);
    }
}
