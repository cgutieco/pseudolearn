use crate::project_analysis::{ProjectUnit, algorithm_nodes, program_node};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_project::ProjectCatalog;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    catalog: &ProjectCatalog,
    units: &[ProjectUnit<'_>],
) {
    for (index, unit) in units.iter().enumerate() {
        session.switch_unit(index);
        let algorithms = algorithm_nodes(session);
        if pseudolearn_project::is_declared_entry(catalog, unit.module) {
            if algorithms.is_empty() {
                let node = program_node(session);
                session.report(DiagnosticCode::EntryMissingAlgorithm, node);
            }
            continue;
        }
        for node in algorithms {
            session.report(DiagnosticCode::AlgorithmOutsideEntry, node);
        }
    }
}
