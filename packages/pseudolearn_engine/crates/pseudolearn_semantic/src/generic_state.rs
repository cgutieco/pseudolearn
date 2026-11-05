use crate::identities::{ClassId, FunctionId, RecordId, TypeId};
use crate::interface_model::InterfaceId;
use std::collections::{BTreeMap, BTreeSet};

pub(crate) const INSTANCE_LIMIT: usize = 64;

pub(crate) type InstanceKey = (usize, usize, Vec<TypeId>);

#[derive(Clone, Debug, Default)]
pub(crate) struct GenericTemplate {
    pub node: usize,
    pub parameters: Vec<String>,
    pub constraints: Vec<Option<String>>,
    pub constraint_nodes: Vec<usize>,
}

#[derive(Clone, Default)]
pub(crate) struct GenericScope {
    pub functions: BTreeMap<String, GenericTemplate>,
    pub records: BTreeMap<String, GenericTemplate>,
    pub classes: BTreeMap<String, GenericTemplate>,
    pub interfaces: BTreeMap<String, GenericTemplate>,
    pub variants: BTreeMap<String, GenericTemplate>,
}

impl GenericScope {
    pub(crate) fn declares_type(&self, name: &str) -> bool {
        self.records.contains_key(name)
            || self.classes.contains_key(name)
            || self.interfaces.contains_key(name)
            || self.variants.contains_key(name)
    }

    pub(crate) fn declares(&self, name: &str) -> bool {
        self.functions.contains_key(name)
            || self.records.contains_key(name)
            || self.classes.contains_key(name)
            || self.interfaces.contains_key(name)
            || self.variants.contains_key(name)
    }
}

#[derive(Default)]
pub(crate) struct GenericState {
    pub environment: Vec<(String, TypeId)>,
    pub functions: BTreeMap<InstanceKey, FunctionId>,
    pub records: BTreeMap<InstanceKey, RecordId>,
    pub origins: BTreeMap<RecordId, InstanceKey>,
    pub opaque: BTreeMap<(usize, usize, usize), TypeId>,
    pub opaque_records: BTreeSet<RecordId>,
    pub constraints: BTreeMap<RecordId, InterfaceId>,
    pub classes: BTreeMap<InstanceKey, ClassId>,
    pub class_origins: BTreeMap<ClassId, InstanceKey>,
    pub class_environments: BTreeMap<ClassId, Vec<(String, TypeId)>>,
    pub interfaces: BTreeMap<InstanceKey, InterfaceId>,
    pub interface_environments: BTreeMap<InterfaceId, Vec<(String, TypeId)>>,
    pub cyclic: BTreeSet<(usize, usize)>,
    pub signatures_ready: bool,
    pub checking_bodies: bool,
    pub instantiated: bool,
    pub defining: bool,
    pub base_functions: usize,
    pub base_classes: usize,
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
                .saturating_add(self.classes.len().saturating_sub(self.base_classes))
                .saturating_add(self.defining_records);
        }
        self.functions
            .len()
            .saturating_add(self.classes.len())
            .saturating_add(self.real_records)
    }

    pub(crate) fn begin_definition(&mut self) {
        self.defining = true;
        self.base_functions = self.functions.len();
        self.base_classes = self.classes.len();
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
