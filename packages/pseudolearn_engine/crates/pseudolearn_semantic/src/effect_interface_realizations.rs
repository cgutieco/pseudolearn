use crate::effect_check::{causal_chain, report_with_chain};
use crate::identities::ClassId;
use crate::interface_model::InterfaceId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::BTreeMap;

pub(super) fn check(session: &mut AnalysisSession<'_>, reasons: &BTreeMap<usize, Option<usize>>) {
    let mut reports = Vec::new();
    for class_index in 0..session.module.classes.len() {
        let class = ClassId(u32::try_from(class_index).unwrap_or(u32::MAX));
        session.enter_class_id(class);
        inspect_interfaces(session, class, reasons, &mut reports);
    }
    for (syntax, index) in reports {
        let chain = causal_chain(reasons, index);
        report_with_chain(
            session,
            (DiagnosticCode::PureFunctionInterfaceImpurity, syntax),
            &chain,
        );
    }
}

fn inspect_interfaces(
    session: &mut AnalysisSession<'_>,
    class: ClassId,
    reasons: &BTreeMap<usize, Option<usize>>,
    reports: &mut Vec<(usize, usize)>,
) {
    for interface_index in 0..session.module.interfaces.len() {
        let interface = InterfaceId(u32::try_from(interface_index).unwrap_or(u32::MAX));
        if crate::interface_realizations::satisfies(session, class, interface) {
            inspect_class_methods(session, (class, interface), reasons, reports);
        }
    }
}

fn inspect_class_methods(
    session: &AnalysisSession<'_>,
    (class, interface): (ClassId, InterfaceId),
    reasons: &BTreeMap<usize, Option<usize>>,
    reports: &mut Vec<(usize, usize)>,
) {
    let Some(model) = session
        .module
        .interfaces
        .get(usize::try_from(interface.0).unwrap_or(usize::MAX))
        .cloned()
    else {
        return;
    };
    for expected in model.methods {
        inspect_expected_method(
            session,
            (class, &expected.name, expected.pure),
            reasons,
            reports,
        );
    }
}

fn inspect_expected_method(
    session: &AnalysisSession<'_>,
    (class, name, pure): (ClassId, &str, bool),
    reasons: &BTreeMap<usize, Option<usize>>,
    reports: &mut Vec<(usize, usize)>,
) {
    if !pure {
        return;
    }
    let Some(found) = crate::hierarchy::find_method(session, class, name) else {
        return;
    };
    let index = usize::try_from(found.0).unwrap_or(usize::MAX);
    if reasons.contains_key(&index) {
        let syntax =
            crate::hierarchy::function(session, found).map_or(0, |declaration| declaration.syntax);
        reports.push((syntax, index));
    }
}
