use crate::identities::{EnumId, RecordId};
use std::collections::BTreeMap;

#[derive(Clone, Default)]
pub(crate) struct TypeScope {
    pub enums: BTreeMap<String, EnumId>,
    pub records: BTreeMap<String, RecordId>,
    pub constants: BTreeMap<String, usize>,
}
