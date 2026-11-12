use crate::{HostEffectProvider, HostEffectRequest, HostReply, IoError};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct DetachedHostProvider {
    pub calls: u64,
}

impl DetachedHostProvider {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn from_value(value: &serde_json::Value) -> Result<Self, IoError> {
        if value.as_object().is_none_or(|fields| {
            fields
                .keys()
                .any(|key| matches!(key.as_str(), "files" | "http" | "clock" | "faults"))
        }) {
            return Err(IoError::from_kind(
                pseudolearn_abi::IoErrorKind::InvalidRequest,
            ));
        }
        Ok(Self::default())
    }

    pub fn live_resource_count(&self) -> usize {
        0
    }
}

impl HostEffectProvider for DetachedHostProvider {
    fn perform(&mut self, _request: &HostEffectRequest) -> HostReply {
        HostReply::failure(IoError::from_kind(
            pseudolearn_abi::IoErrorKind::Interrupted,
        ))
    }

    fn close_all(&mut self) {}
}
