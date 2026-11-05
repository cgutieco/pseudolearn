use crate::generic_state::GenericTemplate;
use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) fn at_home<'syntax, Outcome>(
    session: &mut AnalysisSession<'syntax>,
    template: &GenericTemplate,
    work: impl FnOnce(&mut AnalysisSession<'syntax>) -> Outcome,
) -> Outcome {
    let caller = session.unit;
    session.switch_unit(template.unit);
    let outcome = work(session);
    session.switch_unit(caller);
    outcome
}

pub(crate) fn template_name(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
) -> Option<String> {
    at_home(session, template, |session| {
        let name_node = session.child(template.node, NodeKind::Identifier)?;
        Some(session.name(name_node))
    })
}
