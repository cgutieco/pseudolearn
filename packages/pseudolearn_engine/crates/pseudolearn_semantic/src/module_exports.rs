use crate::module_symbols::{Origin, SymbolKind, UnitDeclarations};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{ModuleId, PackageId, ProjectCatalog};
use pseudolearn_source::IdentifierNormalizer;
use std::collections::BTreeMap;

#[derive(Clone, Debug)]
pub(crate) struct Report {
    pub unit: usize,
    pub node: usize,
    pub code: DiagnosticCode,
    pub lexeme: String,
}

pub(crate) enum PathResolution {
    Module(usize),
    Symbol(Origin),
    Private(String),
    MissingSymbol(String),
    MissingModule(String),
}

pub(crate) struct ExportResolver<'catalog> {
    catalog: &'catalog ProjectCatalog,
    declarations: Vec<UnitDeclarations>,
    memo: Vec<Option<BTreeMap<String, Origin>>>,
    active: Vec<bool>,
    profiles: Vec<Profile>,
    pub reports: Vec<Report>,
}

impl<'catalog> ExportResolver<'catalog> {
    pub(crate) fn new(
        catalog: &'catalog ProjectCatalog,
        declarations: Vec<UnitDeclarations>,
        profiles: Vec<Profile>,
    ) -> Self {
        let count = declarations.len();
        Self {
            catalog,
            declarations,
            memo: vec![None; count],
            active: vec![false; count],
            profiles,
            reports: Vec::new(),
        }
    }

    pub(crate) fn profile(&self, unit: usize) -> Profile {
        self.profiles.get(unit).copied().unwrap_or(Profile::Spanish)
    }

    pub(crate) fn declarations(&self, unit: usize) -> Option<&UnitDeclarations> {
        self.declarations.get(unit)
    }

    pub(crate) fn exports(&mut self, unit: usize) -> BTreeMap<String, Origin> {
        if let Some(Some(done)) = self.memo.get(unit) {
            return done.clone();
        }
        let mut table = self.public_symbols(unit);
        if self.active.get(unit).copied().unwrap_or(true) {
            return table;
        }
        self.set_active(unit, true);
        self.reexport(unit, &mut table);
        self.set_active(unit, false);
        if let Some(slot) = self.memo.get_mut(unit) {
            *slot = Some(table.clone());
        }
        table
    }

    fn set_active(&mut self, unit: usize, value: bool) {
        if let Some(slot) = self.active.get_mut(unit) {
            *slot = value;
        }
    }

    fn public_symbols(&self, unit: usize) -> BTreeMap<String, Origin> {
        let Some(declarations) = self.declarations.get(unit) else {
            return BTreeMap::new();
        };
        declarations
            .symbols
            .iter()
            .filter(|(_, declaration)| declaration.public)
            .map(|(name, declaration)| {
                let origin = Origin {
                    unit,
                    name: name.clone(),
                    kind: declaration.kind,
                };
                (name.clone(), origin)
            })
            .collect()
    }

    fn reexport(&mut self, unit: usize, table: &mut BTreeMap<String, Origin>) {
        let directives: Vec<_> = self
            .declarations
            .get(unit)
            .map(|declarations| {
                declarations
                    .directives
                    .iter()
                    .filter(|directive| directive.export)
                    .cloned()
                    .collect()
            })
            .unwrap_or_default();
        for directive in directives {
            let Some(last) = directive.segments.last().cloned() else {
                continue;
            };
            let resolution = self.resolve_path(unit, &directive.segments);
            if let Some((code, lexeme)) = admit(table, resolution, (&last, &directive.segments)) {
                self.reports.push(Report {
                    unit,
                    node: directive.path_node,
                    code,
                    lexeme,
                });
            }
        }
    }

    pub(crate) fn resolve_path(&mut self, from: usize, segments: &[String]) -> PathResolution {
        let joined = segments.join(".");
        let Some(package) = self.target_package(from, segments.first()) else {
            return PathResolution::MissingModule(joined);
        };
        let rest = segments.get(1..).unwrap_or_default();
        if let Some(module) = self.find_module(package, rest) {
            return PathResolution::Module(module);
        }
        let Some((last, prefix)) = rest.split_last() else {
            return PathResolution::MissingModule(joined);
        };
        let Some(module) = self
            .find_module(package, prefix)
            .filter(|_| !prefix.is_empty())
        else {
            return PathResolution::MissingModule(joined);
        };
        self.symbol_of(module, last)
    }

    pub(crate) fn named_module(&self, from: usize, segments: &[String]) -> Option<usize> {
        let package = self.target_package(from, segments.first())?;
        let rest = segments.get(1..)?;
        self.find_module(package, rest).or_else(|| {
            let (_, prefix) = rest.split_last()?;
            self.find_module(package, prefix)
        })
    }

    fn symbol_of(&mut self, module: usize, name: &str) -> PathResolution {
        if let Some(origin) = self.exports(module).get(name) {
            return PathResolution::Symbol(origin.clone());
        }
        let private = self
            .declarations
            .get(module)
            .is_some_and(|declarations| declarations.symbols.contains_key(name));
        if private {
            PathResolution::Private(name.to_owned())
        } else {
            PathResolution::MissingSymbol(name.to_owned())
        }
    }

    fn target_package(&self, from: usize, first: Option<&String>) -> Option<PackageId> {
        let first = first?;
        let owner = self.catalog.module(ModuleId(u32::try_from(from).ok()?))?;
        let package = self.catalog.package(owner.package)?;
        if IdentifierNormalizer::normalize(&package.name) == *first {
            return Some(owner.package);
        }
        package
            .dependencies
            .iter()
            .find(|(alias, _)| IdentifierNormalizer::normalize(alias) == *first)
            .map(|(_, target)| *target)
    }

    fn find_module(&self, package: PackageId, relative: &[String]) -> Option<usize> {
        if relative.is_empty() {
            return None;
        }
        self.catalog
            .modules()
            .iter()
            .find(|module| module.package == package && same_segments(&module.segments, relative))
            .and_then(|module| usize::try_from(module.id.0).ok())
    }
}

fn admit(
    table: &mut BTreeMap<String, Origin>,
    resolution: PathResolution,
    path: (&String, &[String]),
) -> Option<(DiagnosticCode, String)> {
    let (last, segments) = path;
    match resolution {
        PathResolution::Symbol(origin) => {
            if table.get(last).is_some_and(|existing| *existing != origin) {
                return Some((DiagnosticCode::AmbiguousReexport, last.clone()));
            }
            table.insert(last.clone(), origin);
            None
        }
        PathResolution::Private(name) => Some((DiagnosticCode::PrivateReexport, name)),
        PathResolution::MissingSymbol(name) => Some((DiagnosticCode::UnresolvedImport, name)),
        PathResolution::Module(_) | PathResolution::MissingModule(_) => {
            Some((DiagnosticCode::UnresolvedModule, segments.join(".")))
        }
    }
}

fn same_segments(declared: &[String], requested: &[String]) -> bool {
    declared.len() == requested.len()
        && declared
            .iter()
            .zip(requested)
            .all(|(left, right)| IdentifierNormalizer::normalize(left) == *right)
}

pub(crate) fn is_function(origin: &Origin) -> bool {
    origin.kind == SymbolKind::Function
}
