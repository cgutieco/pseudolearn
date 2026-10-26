use crate::expression_checker::ExpressionPurpose;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let names = session.children(*children.first()?);
    let collection_node = *children.get(1)?;
    let collection =
        crate::expression_checker::check_for(session, collection_node, ExpressionPurpose::Argument);
    let kind = session.expression_type(collection);
    let bindings = binding_types(session, kind, node)?;
    if bindings.len() != names.len() {
        session.report(DiagnosticCode::InvalidForEachBindings, node);
        return None;
    }
    session.bindings.enter();
    let body_node = session.child(node, NodeKind::Body)?;
    let locals: Vec<_> = names
        .into_iter()
        .zip(bindings)
        .map(|(node, kind)| binding(session, node, kind, body_node))
        .collect();
    let before = session.initialized.clone();
    let pending = session.pending_results.clone();
    session.control.loops = session.control.loops.saturating_add(1);
    let body = crate::statement_checker::body(session, body_node);
    session.control.loops = session.control.loops.saturating_sub(1);
    session.initialized = before;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    session.pending_results.extend(pending);
    crate::scope_bindings::leave(session);
    Some(HirStatement::ForEach {
        collection,
        bindings: locals,
        body,
    })
}

fn binding(
    session: &mut AnalysisSession<'_>,
    node: usize,
    kind: crate::identities::TypeId,
    body: usize,
) -> crate::identities::LocalId {
    let local = crate::variant_bindings::pattern(session, kind, node);
    crate::binding_checker::mark_initialized(session, local);
    session
        .module
        .local_visibility
        .insert(local, session.span(body));
    local
}

fn binding_types(
    session: &mut AnalysisSession<'_>,
    kind: Type,
    node: usize,
) -> Option<Vec<crate::TypeId>> {
    let bindings = if let Some(model) = crate::collection_types::get(session, &kind) {
        model
            .key
            .into_iter()
            .chain(std::iter::once(model.value))
            .collect::<Vec<_>>()
    } else if let Type::Array { element, rank: 1 } = kind {
        vec![element]
    } else {
        session.report(DiagnosticCode::InvalidForEachCollection, node);
        return None;
    };
    Some(bindings)
}
