use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) fn constraints(session: &mut AnalysisSession<'_>) {
    let templates: Vec<usize> = session
        .generics
        .records
        .values()
        .chain(session.generics.functions.values())
        .map(|template| template.node)
        .collect();
    for template in templates {
        let Some(list) = session.child(template, NodeKind::TypeParameters) else {
            continue;
        };
        for parameter in session.children(list) {
            note_constraint(session, parameter);
        }
    }
}

fn note_constraint(session: &mut AnalysisSession<'_>, parameter: usize) {
    let Some(constraint) = session.children(parameter).get(1).copied() else {
        return;
    };
    let name = session.name(constraint);
    if let Some(interface) = crate::interface_registry::find(session, &name) {
        session.note_use(constraint, ServiceSymbolTarget::Interface(interface));
    }
}
