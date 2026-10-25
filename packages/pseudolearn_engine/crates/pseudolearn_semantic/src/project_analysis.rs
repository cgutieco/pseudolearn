use crate::hir::{FunctionKind, HirModule};
use crate::identities::{ClassId, FunctionId};
use crate::module_exports::{ExportResolver, Report, is_function};
use crate::module_imports::{UnitBindings, bind};
use crate::module_symbols::{SymbolKind, UnitDeclarations, collect};
use crate::session::{AnalysisSession, SemanticOptions, UnitView};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticSeverity};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{ModuleId, ProjectCatalog};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use std::collections::BTreeMap;

pub struct ProjectUnit<'syntax> {
    pub module: ModuleId,
    pub tree: &'syntax SyntaxTree,
    pub source: &'syntax SourceText,
    pub profile: Profile,
}

type ClassTable = BTreeMap<(usize, String), ClassId>;
type FunctionTable = BTreeMap<(usize, String), FunctionId>;

pub fn analyze_project(
    catalog: &ProjectCatalog,
    units: &[ProjectUnit<'_>],
    entry: Option<ModuleId>,
    options: SemanticOptions,
) -> (Option<HirModule>, Vec<Diagnostic>) {
    if units.iter().any(|unit| unit.tree.has_errors) {
        return (None, Vec::new());
    }
    let views = units
        .iter()
        .map(|unit| UnitView {
            tree: unit.tree,
            source: unit.source,
            profile: unit.profile,
        })
        .collect();
    let Some(mut session) = AnalysisSession::for_units(views, options) else {
        return (Some(HirModule::default()), Vec::new());
    };
    session.module.units.qualifiers = units
        .iter()
        .map(|unit| pseudolearn_project::qualifier(catalog, unit.module))
        .collect();
    let declarations = declarations(&mut session);
    let mut resolver = ExportResolver::new(catalog, declarations, unit_profiles(units));
    let bindings = resolve_links(&mut session, &mut resolver);
    if crate::module_cycles::report(&mut session, catalog, units, &resolver) {
        return (None, session.diagnostics);
    }
    register(&mut session, &mut resolver, &bindings);
    crate::module_structure::check(&mut session, catalog, units);
    select_entry(&mut session, units, entry);
    check_bodies(&mut session);
    let valid = !session
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error);
    (valid.then_some(session.module), session.diagnostics)
}

fn unit_profiles(units: &[ProjectUnit<'_>]) -> Vec<Profile> {
    units.iter().map(|unit| unit.profile).collect()
}

fn check_bodies(session: &mut AnalysisSession<'_>) {
    crate::unit_resolver::register_members(session);
    crate::constant_registry::evaluate_all(session);
    crate::hierarchy::check(session);
    crate::flow::bodies(session);
    crate::constructor_rules::check(session);
    crate::usage::unused(session);
    crate::hir_finalization::finalize(&mut session.module);
}

fn declarations(session: &mut AnalysisSession<'_>) -> Vec<UnitDeclarations> {
    (0..session.units.len())
        .map(|unit| {
            session.switch_unit(unit);
            collect(session)
        })
        .collect()
}

fn resolve_links(
    session: &mut AnalysisSession<'_>,
    resolver: &mut ExportResolver<'_>,
) -> Vec<UnitBindings> {
    let count = session.units.len();
    for unit in 0..count {
        resolver.exports(unit);
    }
    let mut bindings = Vec::new();
    let mut reports = std::mem::take(&mut resolver.reports);
    for unit in 0..count {
        let (unit_bindings, mut unit_reports) = bind(resolver, unit);
        bindings.push(unit_bindings);
        reports.append(&mut unit_reports);
    }
    for report in reports {
        report_link(session, &report);
    }
    bindings
}

fn report_link(session: &mut AnalysisSession<'_>, report: &Report) {
    session.switch_unit(report.unit);
    session.named_report(report.code, report.node, &report.lexeme);
}

fn register(
    session: &mut AnalysisSession<'_>,
    resolver: &mut ExportResolver<'_>,
    bindings: &[UnitBindings],
) {
    let count = session.units.len();
    let mut classes = ClassTable::new();
    for unit in 0..count {
        session.switch_unit(unit);
        crate::unit_resolver::register_classes(session);
        for (name, id) in &session.classes {
            classes.insert((unit, name.clone()), *id);
        }
    }
    link_classes(session, bindings, &classes);
    for unit in 0..count {
        session.switch_unit(unit);
        crate::type_declarations::register(session);
    }
    let mut functions = FunctionTable::new();
    for unit in 0..count {
        session.switch_unit(unit);
        crate::unit_resolver::register_functions(session);
        for (name, id) in &session.functions {
            functions.insert((unit, name.clone()), *id);
        }
    }
    link_functions(session, resolver, bindings, &functions);
    mark_exports(session, resolver, &functions);
}

fn link_classes(session: &mut AnalysisSession<'_>, bindings: &[UnitBindings], table: &ClassTable) {
    for (unit, unit_bindings) in bindings.iter().enumerate() {
        session.switch_unit(unit);
        for (local, origin) in &unit_bindings.symbols {
            if origin.kind != SymbolKind::Class {
                continue;
            }
            if let Some(id) = table.get(&(origin.unit, origin.name.clone())) {
                session.classes.insert(local.clone(), *id);
            }
        }
    }
}

fn link_functions(
    session: &mut AnalysisSession<'_>,
    resolver: &mut ExportResolver<'_>,
    bindings: &[UnitBindings],
    table: &FunctionTable,
) {
    for (unit, unit_bindings) in bindings.iter().enumerate() {
        session.switch_unit(unit);
        for (local, origin) in &unit_bindings.symbols {
            if !is_function(origin) {
                continue;
            }
            if let Some(id) = table.get(&(origin.unit, origin.name.clone())) {
                session.functions.insert(local.clone(), *id);
            }
        }
        for (alias, module) in &unit_bindings.modules {
            let members = module_members(resolver, *module, table);
            session.modules.insert(alias.clone(), members);
        }
    }
}

fn module_members(
    resolver: &mut ExportResolver<'_>,
    module: usize,
    table: &FunctionTable,
) -> BTreeMap<String, FunctionId> {
    resolver
        .exports(module)
        .into_iter()
        .filter(|(_, origin)| is_function(origin))
        .filter_map(|(name, origin)| {
            table
                .get(&(origin.unit, origin.name.clone()))
                .map(|id| (name, *id))
        })
        .collect()
}

fn mark_exports(
    session: &mut AnalysisSession<'_>,
    resolver: &ExportResolver<'_>,
    table: &FunctionTable,
) {
    for unit in 0..session.units.len() {
        let Some(declarations) = resolver.declarations(unit) else {
            continue;
        };
        for (name, declaration) in &declarations.symbols {
            let exported = declaration.public && declaration.kind == SymbolKind::Function;
            if let Some(id) = table.get(&(unit, name.clone())).filter(|_| exported) {
                session.module.units.exported.push(*id);
            }
        }
    }
}

fn select_entry(
    session: &mut AnalysisSession<'_>,
    units: &[ProjectUnit<'_>],
    entry: Option<ModuleId>,
) {
    let Some(entry) = entry else {
        return;
    };
    let unit = units.iter().position(|candidate| candidate.module == entry);
    let main = session
        .module
        .functions
        .iter()
        .enumerate()
        .find(|(index, function)| {
            function.kind == FunctionKind::Main
                && Some(
                    session
                        .module
                        .units
                        .function_unit(FunctionId(u32::try_from(*index).unwrap_or(u32::MAX))),
                ) == unit
        });
    if let Some((index, _)) = main {
        session.module.units.entry = Some(FunctionId(u32::try_from(index).unwrap_or(u32::MAX)));
    }
}

pub(crate) fn algorithm_nodes(session: &AnalysisSession<'_>) -> Vec<usize> {
    session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::AlgorithmUnit)
        .map(|(index, _)| index)
        .collect()
}

pub(crate) fn program_node(session: &AnalysisSession<'_>) -> usize {
    session
        .tree
        .nodes
        .iter()
        .rposition(|node| node.kind == NodeKind::Program)
        .unwrap_or(0)
}
