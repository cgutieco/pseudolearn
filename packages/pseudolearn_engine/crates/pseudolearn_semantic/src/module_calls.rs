use crate::expression_checker::ExpressionPurpose;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> Option<ExpressionId> {
    if session.modules.is_empty() {
        return None;
    }
    let children = session.children(node);
    let target = children.first().copied()?;
    let name_node = children.get(1).copied()?;
    let arguments_node = session.child(node, NodeKind::Arguments)?;
    let alias = alias_name(session, target)?;
    if session.local(&alias).is_some() {
        return None;
    }
    let members = session.modules.get(&alias)?.clone();
    let name = session.name(name_node);
    let Some(function) = members.get(&name).copied() else {
        return Some(template_call(
            session,
            (node, name_node),
            (&alias, &name),
            purpose,
        ));
    };
    let mut arguments = crate::call_checker::arguments_for(session, arguments_node);
    crate::argument_checker::check(session, function, &mut arguments, node);
    Some(crate::call_checker::emit_call(
        session,
        function,
        arguments,
        (node, purpose),
    ))
}

fn alias_name(session: &AnalysisSession<'_>, target: usize) -> Option<String> {
    match session.kind(target) {
        NodeKind::Identifier => Some(session.name(target)),
        NodeKind::Primary => {
            let children = session.children(target);
            let [only] = children.as_slice() else {
                return None;
            };
            (session.kind(*only) == NodeKind::Identifier).then(|| session.name(*only))
        }
        _ => None,
    }
}

fn module_template(
    session: &AnalysisSession<'_>,
    alias: &str,
    name: &str,
) -> Option<crate::generic_state::GenericTemplate> {
    session.generics.modules.get(alias)?.get(name).cloned()
}

fn template_call(
    session: &mut AnalysisSession<'_>,
    (node, name_node): (usize, usize),
    (alias, name): (&str, &str),
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let Some(template) = module_template(session, alias, name) else {
        if let Some(arguments) = session.child(node, NodeKind::Arguments) {
            crate::call_checker::arguments_for(session, arguments);
        }
        session.named_report(DiagnosticCode::UnresolvedImport, name_node, name);
        return crate::expression_checker::invalid(session, node);
    };
    session.note_use(
        name_node,
        crate::service_model::ServiceSymbolTarget::Template(template.identity),
    );
    crate::generic_calls::call(session, node, (template, purpose))
}
