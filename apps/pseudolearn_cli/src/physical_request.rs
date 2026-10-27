use crate::physical_error::HostError;
use serde::Deserialize;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq)]
pub(crate) struct Capability {
    pub slot: u32,
    pub generation: u64,
    pub rights: u8,
    pub kind: u32,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub(crate) enum Argument {
    Integer(i64),
    Boolean(bool),
    Text(String),
    Bytes(Vec<u8>),
    TextList(Vec<String>),
    Capability(Capability),
}

#[derive(Clone, Debug, Deserialize)]
pub(crate) struct Request {
    pub operation: String,
    pub receiver: Option<Capability>,
    pub arguments: Vec<Argument>,
    pub result_capability: Option<Capability>,
}

impl Request {
    pub fn text(&self, index: usize) -> Result<&str, HostError> {
        match self.arguments.get(index) {
            Some(Argument::Text(text)) => Ok(text),
            _ => Err(HostError::INVALID_PATH),
        }
    }

    pub fn receiver(&self) -> Result<&Capability, HostError> {
        self.receiver.as_ref().ok_or(HostError::PERMISSION_DENIED)
    }

    pub fn result(&self) -> Result<&Capability, HostError> {
        self.result_capability
            .as_ref()
            .ok_or(HostError::PERMISSION_DENIED)
    }
}

pub(crate) const READ: u8 = 1;
pub(crate) const WRITE: u8 = 2;

pub(crate) fn mode_rights(mode: &str) -> Result<u8, HostError> {
    match mode {
        "read" | "lectura" => Ok(READ),
        "write" | "escritura" => Ok(WRITE),
        "read_write" | "lectura_escritura" => Ok(READ | WRITE),
        _ => Err(HostError::INVALID_PATH),
    }
}

pub(crate) fn checked_path(path: &str) -> Result<&str, HostError> {
    let valid = !path.is_empty()
        && !path.starts_with('/')
        && !path.contains(['\\', ':', '\0'])
        && path.split('/').all(|part| !["", ".", ".."].contains(&part));
    if valid {
        Ok(path)
    } else {
        Err(HostError::INVALID_PATH)
    }
}
