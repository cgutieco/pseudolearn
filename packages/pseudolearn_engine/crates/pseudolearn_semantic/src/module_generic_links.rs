use crate::generic_state::{GenericScope, GenericTemplate};
use crate::module_imports::UnitBindings;
use crate::module_symbols::{Origin, SymbolKind};
use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use std::collections::BTreeMap;

pub(crate) fn link(session: &mut AnalysisSession<'_>, bindings: &[UnitBindings]) {
    for (unit, unit_bindings) in bindings.iter().enumerate() {
        let imported: Vec<(String, SymbolKind, GenericTemplate)> = unit_bindings
            .symbols
            .iter()
            .filter(|(_, origin)| origin.unit != unit)
            .filter_map(|(local, origin)| {
                template_of(session, origin).map(|template| (local.clone(), origin.kind, template))
            })
            .collect();
        session.switch_unit(unit);
        for (local, kind, template) in imported {
            if let Some(table) = table_for(&mut session.generics, kind) {
                table.insert(local, template);
            }
        }
    }
}

pub(crate) fn link_modules(
    session: &mut AnalysisSession<'_>,
    resolver: &mut crate::module_exports::ExportResolver<'_>,
    bindings: &[UnitBindings],
) {
    for (unit, unit_bindings) in bindings.iter().enumerate() {
        let mut modules = BTreeMap::new();
        for (alias, module) in &unit_bindings.modules {
            let members: BTreeMap<String, GenericTemplate> = resolver
                .exports(*module)
                .into_iter()
                .filter_map(|(name, origin)| {
                    template_of(session, &origin).map(|template| (name, template))
                })
                .collect();
            modules.insert(alias.clone(), members);
        }
        session.switch_unit(unit);
        session.generics.modules = modules;
    }
}

pub(crate) fn target(
    session: &AnalysisSession<'_>,
    origin: &Origin,
) -> Option<ServiceSymbolTarget> {
    template_of(session, origin).map(|template| ServiceSymbolTarget::Template(template.identity))
}

fn template_of(session: &AnalysisSession<'_>, origin: &Origin) -> Option<GenericTemplate> {
    let scope = if origin.unit == session.unit {
        &session.generics
    } else {
        &session.scopes.get(origin.unit)?.generics
    };
    let table = match origin.kind {
        SymbolKind::Function => &scope.functions,
        SymbolKind::Record => &scope.records,
        SymbolKind::Class => &scope.classes,
        SymbolKind::Interface => &scope.interfaces,
        SymbolKind::Variant => &scope.variants,
        SymbolKind::Enum | SymbolKind::Constant => return None,
    };
    table.get(&origin.name).cloned()
}

fn table_for(
    scope: &mut GenericScope,
    kind: SymbolKind,
) -> Option<&mut BTreeMap<String, GenericTemplate>> {
    match kind {
        SymbolKind::Function => Some(&mut scope.functions),
        SymbolKind::Record => Some(&mut scope.records),
        SymbolKind::Class => Some(&mut scope.classes),
        SymbolKind::Interface => Some(&mut scope.interfaces),
        SymbolKind::Variant => Some(&mut scope.variants),
        SymbolKind::Enum | SymbolKind::Constant => None,
    }
}
