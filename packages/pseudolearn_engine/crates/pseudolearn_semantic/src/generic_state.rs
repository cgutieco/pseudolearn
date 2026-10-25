use crate::identities::{FunctionId, RecordId, TypeId};
use std::collections::{BTreeMap, BTreeSet};

pub(crate) const INSTANCE_LIMIT: usize = 64;

pub(crate) type InstanceKey = (usize, usize, Vec<TypeId>);

#[derive(Clone, Debug, Default)]
pub(crate) struct GenericTemplate {
    pub node: usize,
    pub parameters: Vec<String>,
}

#[derive(Clone, Default)]
pub(crate) struct GenericScope {
    pub functions: BTreeMap<String, GenericTemplate>,
    pub records: BTreeMap<String, GenericTemplate>,
}

#[derive(Default)]
pub(crate) struct GenericState {
    pub environment: Vec<(String, TypeId)>,
    pub functions: BTreeMap<InstanceKey, FunctionId>,
    pub records: BTreeMap<InstanceKey, RecordId>,
    pub origins: BTreeMap<RecordId, InstanceKey>,
    pub opaque: BTreeMap<(usize, usize, usize), TypeId>,
    pub opaque_records: BTreeSet<RecordId>,
    pub instantiated: bool,
    pub defining: bool,
    pub base_functions: usize,
    pub defining_records: usize,
    pub real_records: usize,
}

impl GenericState {
    pub(crate) fn instance_count(&self) -> usize {
        if self.defining {
            return self
                .functions
                .len()
                .saturating_sub(self.base_functions)
                .saturating_add(self.defining_records);
        }
        self.functions.len().saturating_add(self.real_records)
    }

    pub(crate) fn begin_definition(&mut self) {
        self.defining = true;
        self.base_functions = self.functions.len();
        self.defining_records = 0;
    }

    pub(crate) fn count_record(&mut self) {
        if self.defining {
            self.defining_records = self.defining_records.saturating_add(1);
        } else {
            self.real_records = self.real_records.saturating_add(1);
        }
    }

    pub(crate) fn lookup(&self, name: &str) -> Option<TypeId> {
        self.environment
            .iter()
            .rev()
            .find(|(candidate, _)| candidate == name)
            .map(|(_, kind)| *kind)
    }
}
