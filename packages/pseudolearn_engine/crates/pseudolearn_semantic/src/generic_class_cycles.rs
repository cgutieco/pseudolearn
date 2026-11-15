use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn detect(session: &mut AnalysisSession<'_>) {
    let mut templates: Vec<usize> = session
        .generics
        .classes
        .values()
        .map(|template| template.node)
        .collect();
    templates.sort_unstable();
    for start in templates {
        walk(session, start);
    }
}

pub(crate) fn is_cyclic(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.generic.cyclic.contains(&(session.unit, node))
}

fn walk(session: &mut AnalysisSession<'_>, start: usize) {
    let mut path = Vec::new();
    let mut current = Some(start);
    while let Some(node) = current {
        if is_cyclic(session, node) {
            return;
        }
        if let Some(position) = path.iter().position(|visited| *visited == node) {
            let members: Vec<usize> = path.iter().skip(position).copied().collect();
            if let Some(first) = members.first().copied() {
                session.report(DiagnosticCode::CircularInheritance, first);
            }
            for member in members {
                session.generic.cyclic.insert((session.unit, member));
            }
            return;
        }
        path.push(node);
        current = base_template(session, node);
    }
}

fn base_template(session: &AnalysisSession<'_>, node: usize) -> Option<usize> {
    let base = session
        .children(node)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::Identifier)
        .nth(1)?;
    session
        .generics
        .classes
        .get(&session.name(base))
        .map(|template| template.node)
}
