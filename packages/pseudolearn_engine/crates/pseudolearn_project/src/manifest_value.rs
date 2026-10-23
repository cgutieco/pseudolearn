use crate::manifest_error::Location;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum Scalar {
    Text(String),
    Integer(u64),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Located<Content> {
    pub position: Location,
    pub value: Content,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum Value {
    Scalar(Scalar),
    List(Vec<Located<Scalar>>),
    Inline(Table),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum Node {
    Value(Located<Value>),
    Table(Table),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Entry {
    pub key_at: Location,
    pub node: Node,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Table {
    pub position: Location,
    pub defined: bool,
    pub entries: BTreeMap<String, Entry>,
}

impl Table {
    pub(crate) fn new(position: Location, defined: bool) -> Self {
        Self {
            position,
            defined,
            entries: BTreeMap::new(),
        }
    }
}
