use crate::hir::HirLocal;
use crate::identities::{ExpressionId, FunctionId, LocalId};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default)]
pub(crate) struct LocalIndexes {
    pub scopes: LocalScopes,
    pub assignments: BTreeMap<LocalId, Vec<ExpressionId>>,
}

#[derive(Clone, Debug, Default)]
pub(crate) struct LocalScopes {
    scanned: usize,
    by_scope: BTreeMap<FunctionId, Vec<usize>>,
}

impl LocalScopes {
    pub(crate) fn forget_from(&mut self, length: usize) {
        if length >= self.scanned {
            return;
        }
        for indexes in self.by_scope.values_mut() {
            indexes.retain(|index| *index < length);
        }
        self.scanned = length;
    }

    pub(crate) fn owned_by(&mut self, locals: &[HirLocal], scope: FunctionId) -> &[usize] {
        self.forget_from(locals.len());
        for (index, local) in locals.iter().enumerate().skip(self.scanned) {
            self.by_scope.entry(local.scope).or_default().push(index);
        }
        self.scanned = locals.len();
        self.by_scope.get(&scope).map_or(&[], Vec::as_slice)
    }
}
