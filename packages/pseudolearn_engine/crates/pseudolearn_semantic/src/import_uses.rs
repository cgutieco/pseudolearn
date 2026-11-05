use crate::module_exports::{ExportResolver, PathResolution};
use crate::module_symbols::{Origin, SymbolKind};
use crate::project_analysis::{ClassTable, FunctionTable};
use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) fn record(
    session: &mut AnalysisSession<'_>,
    resolver: &mut ExportResolver<'_>,
    tables: (&ClassTable, &FunctionTable),
) {
    for unit in 0..session.units.len() {
        let directives = resolver
            .declarations(unit)
            .map(|declarations| declarations.directives.clone())
            .unwrap_or_default();
        session.switch_unit(unit);
        for directive in directives {
            let PathResolution::Symbol(origin) = resolver.resolve_path(unit, &directive.segments)
            else {
                continue;
            };
            let name_node = session
                .children(directive.path_node)
                .into_iter()
                .rev()
                .find(|child| session.kind(*child) == NodeKind::Identifier);
            let target = target_of(session, &origin, tables);
            if let (Some(name_node), Some(target)) = (name_node, target) {
                session.note_use(name_node, target);
            }
        }
    }
}

fn target_of(
    session: &AnalysisSession<'_>,
    origin: &Origin,
    tables: (&ClassTable, &FunctionTable),
) -> Option<ServiceSymbolTarget> {
    let key = (origin.unit, origin.name.clone());
    match origin.kind {
        SymbolKind::Function => tables
            .1
            .get(&key)
            .copied()
            .map(ServiceSymbolTarget::Function),
        SymbolKind::Class => tables.0.get(&key).copied().map(ServiceSymbolTarget::Class),
        _ => crate::module_type_links::target(session, origin),
    }
}
