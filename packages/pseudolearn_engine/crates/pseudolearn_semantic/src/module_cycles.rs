use crate::module_exports::ExportResolver;
use crate::project_analysis::ProjectUnit;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_project::{ImportEdge, ModuleCycle, ModuleId, ProjectCatalog, module_cycles};
use pseudolearn_source::Span;

pub(crate) fn report(
    session: &mut AnalysisSession<'_>,
    catalog: &ProjectCatalog,
    units: &[ProjectUnit<'_>],
    resolver: &ExportResolver<'_>,
) -> bool {
    let cycles = module_cycles(catalog, &import_edges(units, resolver));
    for cycle in &cycles {
        report_cycle(session, catalog, cycle);
    }
    !cycles.is_empty()
}

fn import_edges(units: &[ProjectUnit<'_>], resolver: &ExportResolver<'_>) -> Vec<ImportEdge> {
    let mut edges = Vec::new();
    for (unit, owner) in units.iter().enumerate() {
        let Some(declarations) = resolver.declarations(unit) else {
            continue;
        };
        for directive in &declarations.directives {
            let target = resolver
                .named_module(unit, &directive.segments)
                .and_then(|target| units.get(target));
            if let Some(target) = target {
                edges.push(ImportEdge {
                    from: owner.module,
                    target: target.module,
                    site: directive.path_node,
                });
            }
        }
    }
    edges
}

fn report_cycle(session: &mut AnalysisSession<'_>, catalog: &ProjectCatalog, cycle: &ModuleCycle) {
    let Some((first, rest)) = cycle.edges.split_first() else {
        return;
    };
    let related: Vec<Span> = rest
        .iter()
        .filter_map(|edge| {
            session.switch_unit(unit_of(edge.from)?);
            Some(session.span(edge.site))
        })
        .collect();
    let Some(unit) = unit_of(first.from) else {
        return;
    };
    session.switch_unit(unit);
    let chain = chain_text(catalog, cycle);
    session.named_report(DiagnosticCode::ImportCycle, first.site, &chain);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.related.extend(related);
    }
}

fn unit_of(module: ModuleId) -> Option<usize> {
    usize::try_from(module.0).ok()
}

fn chain_text(catalog: &ProjectCatalog, cycle: &ModuleCycle) -> String {
    let mut names: Vec<String> = cycle
        .edges
        .iter()
        .map(|edge| pseudolearn_project::qualifier(catalog, edge.from))
        .collect();
    if let Some(last) = cycle.edges.last() {
        names.push(pseudolearn_project::qualifier(catalog, last.target));
    }
    names.join(" -> ")
}
