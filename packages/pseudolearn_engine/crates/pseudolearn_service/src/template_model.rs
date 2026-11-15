use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum StopRole {
    Expression,
    NewIdentifier,
}

impl StopRole {
    pub fn name(self) -> &'static str {
        match self {
            StopRole::Expression => "expression",
            StopRole::NewIdentifier => "new_identifier",
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StopSpec {
    pub index: u8,
    pub role: StopRole,
    pub marker: String,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Segment {
    Text(String),
    NewLine,
    Indent(usize),
    Stop(StopSpec),
    Final,
}

#[derive(Clone, Debug, PartialEq, Eq, Default)]
pub struct Template {
    pub segments: Vec<Segment>,
}

pub fn text(value: impl Into<String>) -> Segment {
    Segment::Text(value.into())
}

pub fn stop(index: u8, role: StopRole, marker: &str) -> Segment {
    Segment::Stop(StopSpec {
        index,
        role,
        marker: marker.to_owned(),
    })
}
