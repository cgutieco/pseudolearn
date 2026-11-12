use std::collections::BTreeSet;

#[derive(Default)]
pub(crate) struct SupportRequests {
    requested: BTreeSet<&'static str>,
}

impl SupportRequests {
    pub(crate) fn request(&mut self, name: &'static str) {
        self.requested.insert(name);
    }

    pub(crate) fn contains(&self, name: &str) -> bool {
        self.requested.contains(name)
    }

    pub(crate) fn close_over(&mut self, dependencies: fn(&str) -> &'static [&'static str]) {
        let mut pending: Vec<&'static str> = self.requested.iter().copied().collect();
        while let Some(name) = pending.pop() {
            for dependency in dependencies(name) {
                if self.requested.insert(dependency) {
                    pending.push(dependency);
                }
            }
        }
    }
}
