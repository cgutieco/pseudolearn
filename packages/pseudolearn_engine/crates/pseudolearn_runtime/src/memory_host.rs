use crate::{HostEffectProvider, HostEffectRequest, HostReply, HostValue, IoError};
use pseudolearn_abi::IoErrorKind;
use serde_json::Value;
use std::collections::{BTreeMap, VecDeque};

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct MemoryFault {
    pub(crate) operation: String,
    pub(crate) path: Option<String>,
    pub(crate) error: IoError,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct MemoryHostProvider {
    pub files: BTreeMap<String, Vec<u8>>,
    pub arguments: Vec<String>,
    pub time_nanos: u64,
    pub calls: u64,
    pub output: String,
    pub(crate) clocks: VecDeque<u64>,
    pub(crate) faults: Vec<MemoryFault>,
    pub(crate) resources: BTreeMap<u32, String>,
}

impl MemoryHostProvider {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn from_value(value: &Value) -> Result<Self, IoError> {
        crate::memory_host_config::parse(value)
    }

    pub fn read(&self, path: &str) -> Result<&[u8], IoErrorKind> {
        self.files
            .get(path)
            .map(Vec::as_slice)
            .ok_or(IoErrorKind::NotFound)
    }

    pub fn write(&mut self, path: String, content: Vec<u8>) -> Result<(), IoErrorKind> {
        if !crate::memory_host_files::valid_path(&path) {
            return Err(IoErrorKind::InvalidPath);
        }
        self.files.insert(path, content);
        Ok(())
    }

    pub fn delete(&mut self, path: &str) -> Result<(), IoErrorKind> {
        self.files
            .remove(path)
            .map(|_| ())
            .ok_or(IoErrorKind::NotFound)
    }

    pub fn live_resource_count(&self) -> usize {
        self.resources.len()
    }
}

impl HostEffectProvider for MemoryHostProvider {
    fn perform(&mut self, request: &HostEffectRequest) -> HostReply {
        self.calls = self.calls.saturating_add(1);
        let outcome = self.resolve(request);
        match outcome {
            Ok(value) => HostReply::Committed(value),
            Err(error) => HostReply::failure(error),
        }
    }

    fn close_all(&mut self) {
        self.resources.clear();
    }
}

impl MemoryHostProvider {
    fn resolve(&mut self, request: &HostEffectRequest) -> Result<HostValue, IoError> {
        let path = crate::memory_host_files::request_path(self, request).ok();
        if let Some(fault) = self.faults.iter().find(|fault| {
            fault.operation == request.operation
                && fault
                    .path
                    .as_ref()
                    .is_none_or(|expected| Some(expected) == path.as_ref())
        }) {
            return Err(fault.error);
        }
        match request.operation.as_str() {
            "request_directory" => {
                if text(request, 0)? != "root" {
                    return Err(IoError::not_found());
                }
                crate::memory_host_files::register(self, request, String::new())
            }
            name if name.starts_with("request_") => {
                crate::memory_host_files::register(self, request, String::new())
            }
            "console_write" => {
                let text = text(request, 0)?;
                self.output.push_str(text);
                Ok(HostValue::Integer(i64::try_from(text.len()).map_err(
                    |_| IoError::from_kind(IoErrorKind::Interrupted),
                )?))
            }
            "arguments_values" => Ok(HostValue::TextList(self.arguments.clone())),
            "clock_now" => {
                self.time_nanos = self.clocks.pop_front().ok_or_else(IoError::end_of_file)?;
                integer_time(self.time_nanos)
            }
            "timer_wait" => self.wait(request),
            _ => crate::memory_host_files::perform(self, request),
        }
    }

    fn wait(&mut self, request: &HostEffectRequest) -> Result<HostValue, IoError> {
        let Some(HostValue::Integer(duration)) = request.arguments.first() else {
            return Err(IoError::from_kind(IoErrorKind::TimedOut));
        };
        let duration =
            u64::try_from(*duration).map_err(|_| IoError::from_kind(IoErrorKind::TimedOut))?;
        self.time_nanos = self
            .time_nanos
            .checked_add(duration)
            .ok_or_else(|| IoError::from_kind(IoErrorKind::TimedOut))?;
        integer_time(self.time_nanos)
    }
}

fn integer_time(time: u64) -> Result<HostValue, IoError> {
    i64::try_from(time)
        .map(HostValue::Integer)
        .map_err(|_| IoError::from_kind(IoErrorKind::TimedOut))
}

pub(crate) fn text(request: &HostEffectRequest, index: usize) -> Result<&str, IoError> {
    match request.arguments.get(index) {
        Some(HostValue::Text(text)) => Ok(text),
        _ => Err(IoError::from_kind(IoErrorKind::InvalidPath)),
    }
}
