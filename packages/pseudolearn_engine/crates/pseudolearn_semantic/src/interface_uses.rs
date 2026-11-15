use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) fn constraints(session: &mut AnalysisSession<'_>) {
    let unit = session.unit;
    let scope = &session.generics;
    let templates: Vec<usize> = scope
        .records
        .values()
        .chain(scope.functions.values())
        .chain(scope.classes.values())
        .chain(scope.interfaces.values())
        .chain(scope.variants.values())
        .filter(|template| template.unit == unit)
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
    } else {
        crate::generic_symbols::note_named_use(session, constraint, &name);
    }
}
