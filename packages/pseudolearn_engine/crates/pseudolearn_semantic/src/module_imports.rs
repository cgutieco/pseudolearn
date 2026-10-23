use crate::module_exports::{ExportResolver, PathResolution, Report};
use crate::module_symbols::{Directive, Origin};
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::BTreeMap;

#[derive(Debug, Default)]
pub(crate) struct UnitBindings {
    pub symbols: BTreeMap<String, Origin>,
    pub modules: BTreeMap<String, usize>,
}

type Rejection = Option<(DiagnosticCode, String, usize)>;

struct Binder<'resolver, 'catalog> {
    resolver: &'resolver mut ExportResolver<'catalog>,
    unit: usize,
    bindings: UnitBindings,
}

pub(crate) fn bind(resolver: &mut ExportResolver<'_>, unit: usize) -> (UnitBindings, Vec<Report>) {
    let directives: Vec<Directive> = resolver
        .declarations(unit)
        .map(|declarations| {
            declarations
                .directives
                .iter()
                .filter(|directive| !directive.export)
                .cloned()
                .collect()
        })
        .unwrap_or_default();
    let mut binder = Binder {
        resolver,
        unit,
        bindings: UnitBindings::default(),
    };
    let mut reports = Vec::new();
    for directive in &directives {
        if let Some((code, lexeme, node)) = binder.bind_directive(directive) {
            reports.push(Report {
                unit,
                node,
                code,
                lexeme,
            });
        }
    }
    (binder.bindings, reports)
}

impl Binder<'_, '_> {
    fn bind_directive(&mut self, directive: &Directive) -> Rejection {
        let last = directive.segments.last()?.clone();
        let (local, node) = match &directive.alias {
            Some((alias_node, alias)) => (alias.clone(), *alias_node),
            None => (last, directive.path_node),
        };
        let path_node = directive.path_node;
        match self.resolver.resolve_path(self.unit, &directive.segments) {
            PathResolution::Module(module) => self.add_module(&local, node, module),
            PathResolution::Symbol(origin) => self.add_symbol(&local, node, origin),
            PathResolution::Private(name) => Some((DiagnosticCode::PrivateImport, name, path_node)),
            PathResolution::MissingSymbol(name) => {
                Some((DiagnosticCode::UnresolvedImport, name, path_node))
            }
            PathResolution::MissingModule(path) => {
                Some((DiagnosticCode::UnresolvedModule, path, path_node))
            }
        }
    }

    fn add_module(&mut self, name: &str, node: usize, module: usize) -> Rejection {
        let taken = self.bindings.symbols.contains_key(name)
            || self
                .bindings
                .modules
                .get(name)
                .is_some_and(|existing| *existing != module)
            || self.declares(name);
        if taken {
            return Some((DiagnosticCode::ImportNameCollision, name.to_owned(), node));
        }
        self.bindings.modules.insert(name.to_owned(), module);
        None
    }

    fn add_symbol(&mut self, name: &str, node: usize, origin: Origin) -> Rejection {
        let own = origin.unit == self.unit && origin.name == name;
        let taken = self.bindings.modules.contains_key(name)
            || self
                .bindings
                .symbols
                .get(name)
                .is_some_and(|existing| *existing != origin)
            || (self.declares(name) && !own);
        if taken {
            return Some((DiagnosticCode::ImportNameCollision, name.to_owned(), node));
        }
        self.bindings.symbols.insert(name.to_owned(), origin);
        None
    }

    fn declares(&self, name: &str) -> bool {
        self.resolver
            .declarations(self.unit)
            .is_some_and(|declarations| declarations.symbols.contains_key(name))
    }
}
