use crate::{CapabilityKind, CapabilityToken, IoError, RightsMask};
use pseudolearn_abi::IoErrorKind;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub enum HostValue {
    Integer(i64),
    Real(u64),
    Boolean(bool),
    Text(String),
    Bytes(Vec<u8>),
    TextList(Vec<String>),
    JsonValue(String),
    JsonResult(JsonResultValue),
    JsonKind(u8),
    OptionalBoolean(Option<bool>),
    OptionalInteger(Option<i64>),
    OptionalReal(Option<u64>),
    OptionalText(Option<String>),
    OptionalJsonValue(Option<String>),
    Capability(HostCapability),
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub enum JsonResultValue {
    Value(String),
    Error(JsonFailure),
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct JsonFailure {
    pub code: String,
    pub line: i64,
    pub column: i64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct HostCapability {
    pub slot: u32,
    pub generation: u64,
    pub rights: u8,
    pub kind: u32,
}

impl From<CapabilityToken> for HostCapability {
    fn from(token: CapabilityToken) -> Self {
        Self {
            slot: token.slot,
            generation: token.generation,
            rights: u8::from(token.rights.read)
                | (u8::from(token.rights.write) << 1)
                | (u8::from(token.rights.execute) << 2),
            kind: token.kind.to_tag(),
        }
    }
}

impl HostCapability {
    pub fn token(&self) -> Result<CapabilityToken, IoError> {
        if self.rights > 7 {
            return Err(IoError::permission_denied());
        }
        Ok(CapabilityToken {
            slot: self.slot,
            generation: self.generation,
            rights: RightsMask {
                read: self.rights & 1 != 0,
                write: self.rights & 2 != 0,
                execute: self.rights & 4 != 0,
            },
            kind: CapabilityKind::from_tag(self.kind).ok_or_else(IoError::permission_denied)?,
        })
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct HostFailure {
    pub code: String,
    pub uncertain: bool,
}

impl From<IoError> for HostFailure {
    fn from(error: IoError) -> Self {
        Self {
            code: error.code().to_owned(),
            uncertain: error.uncertain,
        }
    }
}

impl HostFailure {
    pub fn error(&self) -> Option<IoError> {
        IoErrorKind::ALL
            .iter()
            .find(|kind| kind.code() == self.code)
            .map(|kind| IoError::new(*kind, self.uncertain))
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(tag = "outcome", content = "value", rename_all = "snake_case")]
pub enum HostReply {
    Committed(HostValue),
    Failed(HostFailure),
    Uncertain(HostFailure),
}

impl HostReply {
    pub fn failure(error: IoError) -> Self {
        if error.uncertain {
            Self::Uncertain(error.into())
        } else {
            Self::Failed(error.into())
        }
    }

    pub fn commit_outcome(&self) -> crate::CommitOutcome {
        match self {
            Self::Committed(_) => crate::CommitOutcome::Committed,
            Self::Failed(_) => crate::CommitOutcome::Failed,
            Self::Uncertain(_) => crate::CommitOutcome::Uncertain,
        }
    }

    pub fn outcome(&self) -> &'static str {
        self.commit_outcome().as_str()
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct HostEffectRequest {
    pub effect_seq: u64,
    pub operation: String,
    pub receiver: Option<HostCapability>,
    pub arguments: Vec<HostValue>,
    pub result_capability: Option<HostCapability>,
    pub source_node_id: u32,
}

pub trait HostEffectProvider {
    fn perform(&mut self, request: &HostEffectRequest) -> HostReply;
    fn close_all(&mut self);
}
