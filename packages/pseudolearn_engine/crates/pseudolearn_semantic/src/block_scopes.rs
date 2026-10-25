use crate::identities::LocalId;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum BindingTarget {
    Local(LocalId),
    Constant(usize),
}

#[derive(Clone, Debug, Default)]
pub(crate) struct BlockScopes {
    entries: Vec<(String, BindingTarget)>,
    marks: Vec<usize>,
    expired: Vec<(String, BindingTarget)>,
}

impl BlockScopes {
    pub(crate) fn enter(&mut self) {
        self.marks.push(self.entries.len());
    }

    pub(crate) fn leave(&mut self) -> Vec<BindingTarget> {
        let Some(mark) = self.marks.pop() else {
            return Vec::new();
        };
        let removed = self.entries.split_off(mark);
        let targets = removed.iter().map(|entry| entry.1).collect();
        self.expired.extend(removed);
        targets
    }

    pub(crate) fn find(&self, name: &str) -> Option<BindingTarget> {
        self.entries
            .iter()
            .rev()
            .find(|entry| entry.0 == name)
            .map(|entry| entry.1)
    }

    pub(crate) fn current(&self, name: &str) -> Option<BindingTarget> {
        let mark = self.marks.last().copied().unwrap_or(0);
        self.entries
            .get(mark..)?
            .iter()
            .rev()
            .find(|entry| entry.0 == name)
            .map(|entry| entry.1)
    }

    pub(crate) fn expired(&self, name: &str) -> Option<BindingTarget> {
        self.expired
            .iter()
            .rev()
            .find(|entry| entry.0 == name)
            .map(|entry| entry.1)
    }

    pub(crate) fn insert(&mut self, name: String, target: BindingTarget) {
        self.entries.push((name, target));
    }
}
