use crate::identities::{ConstantId, EnumId, RecordId};
use crate::interface_model::InterfaceId;
use crate::module_imports::UnitBindings;
use crate::module_symbols::{Origin, SymbolKind};
use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use crate::type_scope::TypeScope;

enum Linked {
    Record(RecordId),
    Enum(EnumId),
    Constant(usize),
    Interface(InterfaceId),
}

pub(crate) fn register(session: &mut AnalysisSession<'_>, bindings: &[UnitBindings]) {
    let count = session.units.len();
    let mut per_unit = Vec::new();
    for unit in 0..count {
        session.switch_unit(unit);
        crate::interface_registry::declare_all(session);
        per_unit.push(crate::type_declarations::declare(session));
    }
    link(session, bindings);
    for (unit, records) in per_unit.iter().enumerate() {
        session.switch_unit(unit);
        crate::interface_registry::realizations(session);
        crate::record_registry::resolve_fields(session, records);
    }
    let all: Vec<RecordId> = per_unit.into_iter().flatten().collect();
    crate::record_cycles::layout(session, &all);
    for unit in 0..count {
        session.switch_unit(unit);
        crate::interface_registry::signatures(session);
    }
}

fn link(session: &mut AnalysisSession<'_>, bindings: &[UnitBindings]) {
    for (unit, unit_bindings) in bindings.iter().enumerate() {
        session.switch_unit(unit);
        for (local, origin) in &unit_bindings.symbols {
            if origin.unit == unit {
                continue;
            }
            if let Some(linked) = resolve(session, origin) {
                insert(&mut session.declared, local, linked);
            }
        }
    }
}

pub(crate) fn target(
    session: &AnalysisSession<'_>,
    origin: &Origin,
) -> Option<ServiceSymbolTarget> {
    Some(match resolve(session, origin)? {
        Linked::Record(id) => ServiceSymbolTarget::Record(id),
        Linked::Enum(id) => ServiceSymbolTarget::Enum(id),
        Linked::Constant(index) => {
            ServiceSymbolTarget::Constant(ConstantId(u32::try_from(index).ok()?))
        }
        Linked::Interface(id) => ServiceSymbolTarget::Interface(id),
    })
}

fn scope_of<'session>(
    session: &'session AnalysisSession<'_>,
    unit: usize,
) -> Option<&'session TypeScope> {
    if unit == session.unit {
        Some(&session.declared)
    } else {
        session.scopes.get(unit).map(|scope| &scope.declared)
    }
}

fn resolve(session: &AnalysisSession<'_>, origin: &Origin) -> Option<Linked> {
    let scope = scope_of(session, origin.unit)?;
    match origin.kind {
        SymbolKind::Record => scope.records.get(&origin.name).copied().map(Linked::Record),
        SymbolKind::Enum => scope.enums.get(&origin.name).copied().map(Linked::Enum),
        SymbolKind::Constant => scope
            .constants
            .get(&origin.name)
            .copied()
            .map(Linked::Constant),
        SymbolKind::Interface => {
            crate::interface_registry::find_in_unit(session, origin.unit, &origin.name)
                .map(Linked::Interface)
        }
        SymbolKind::Function | SymbolKind::Class => None,
    }
}

fn insert(scope: &mut TypeScope, local: &str, linked: Linked) {
    let name = local.to_owned();
    match linked {
        Linked::Record(id) => {
            scope.records.insert(name, id);
        }
        Linked::Enum(id) => {
            scope.enums.insert(name, id);
        }
        Linked::Constant(index) => {
            scope.constants.insert(name, index);
        }
        Linked::Interface(id) => {
            scope.interfaces.insert(name, id);
        }
    }
}
