use crate::arena::{Arena, ScopeId, SymbolId};
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ScopeKind {
    Global,
    Unit,
    Block,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Scope {
    pub parent: Option<ScopeId>,
    pub kind: ScopeKind,
    symbols: BTreeMap<String, SymbolId>,
}

impl Scope {
    pub fn new(parent: Option<ScopeId>, kind: ScopeKind) -> Self {
        Self {
            parent,
            kind,
            symbols: BTreeMap::new(),
        }
    }

    pub fn insert(&mut self, name: &str, symbol_id: SymbolId) {
        self.symbols.insert(name.to_lowercase(), symbol_id);
    }

    pub fn find_local(&self, name: &str) -> Option<SymbolId> {
        self.symbols.get(&name.to_lowercase()).copied()
    }

    pub fn resolve(&self, name: &str, scopes_arena: &Arena<Scope>) -> Option<SymbolId> {
        if let Some(symbol_id) = self.find_local(name) {
            return Some(symbol_id);
        }
        let parent_id = self.parent?;
        let parent_scope = scopes_arena.get(parent_id.0)?;
        parent_scope.resolve(name, scopes_arena)
    }
}
