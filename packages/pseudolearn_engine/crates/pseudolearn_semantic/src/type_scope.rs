use crate::identities::{EnumId, RecordId};
use crate::interface_model::InterfaceId;
use std::collections::BTreeMap;

#[derive(Clone, Default)]
pub(crate) struct TypeScope {
    pub enums: BTreeMap<String, EnumId>,
    pub records: BTreeMap<String, RecordId>,
    pub constants: BTreeMap<String, usize>,
    pub interfaces: BTreeMap<String, InterfaceId>,
}
