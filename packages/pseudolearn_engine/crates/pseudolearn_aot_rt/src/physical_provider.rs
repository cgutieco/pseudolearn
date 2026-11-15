use pseudolearn_host::PhysicalHost;
use pseudolearn_runtime::{HostEffectProvider, HostEffectRequest, HostReply, IoError};

pub struct PhysicalProvider {
    host: PhysicalHost,
    arguments: Vec<String>,
    pub calls: u64,
}

impl PhysicalProvider {
    pub fn new() -> Self {
        Self::with_arguments(Vec::new())
    }

    pub fn with_arguments(arguments: Vec<String>) -> Self {
        Self {
            host: PhysicalHost::new(working_directory(), arguments.clone()),
            arguments,
            calls: 0,
        }
    }

    pub fn from_value(value: &serde_json::Value) -> Result<Self, IoError> {
        pseudolearn_runtime::ExecutionHostProvider::from_value(value)?;
        Ok(Self::new())
    }

    pub fn live_resource_count(&self) -> usize {
        0
    }
}

impl Default for PhysicalProvider {
    fn default() -> Self {
        Self::new()
    }
}

fn working_directory() -> std::path::PathBuf {
    std::env::current_dir().unwrap_or_default()
}

fn interrupted() -> HostReply {
    HostReply::failure(IoError::from_kind(
        pseudolearn_abi::IoErrorKind::Interrupted,
    ))
}

impl HostEffectProvider for PhysicalProvider {
    fn perform(&mut self, request: &HostEffectRequest) -> HostReply {
        self.calls = self.calls.saturating_add(1);
        let Ok(raw) = serde_json::to_value(request) else {
            return interrupted();
        };
        serde_json::from_value(self.host.perform(&raw)).unwrap_or_else(|_| interrupted())
    }

    fn close_all(&mut self) {
        self.host = PhysicalHost::new(working_directory(), self.arguments.clone());
    }
}
