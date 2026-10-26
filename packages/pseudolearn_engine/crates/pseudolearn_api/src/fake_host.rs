#![forbid(unsafe_code)]

use pseudolearn_abi::IoErrorKind;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FakeHostProvider {
    pub files: BTreeMap<String, Vec<u8>>,
    pub arguments: Vec<String>,
    pub time_nanos: u64,
    pub faults: BTreeMap<String, IoErrorKind>,
}

impl FakeHostProvider {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn from_value(value: &Value) -> Self {
        let mut provider = Self::default();
        if let Some(files) = value.get("files").or_else(|| value.get("archivos"))
            && let Some(map) = files.as_object()
        {
            for (path, content) in map {
                if let Some(text) = content.as_str() {
                    provider.files.insert(path.clone(), text.as_bytes().to_vec());
                }
            }
        }
        if let Some(provided_arguments) = value.get("args").or_else(|| value.get("argumentos"))
            && let Some(list) = provided_arguments.as_array()
        {
            for argument_value in list {
                if let Some(text) = argument_value.as_str() {
                    provider.arguments.push(text.to_owned());
                }
            }
        }
        if let Some(time) = value.get("time").or_else(|| value.get("tiempo"))
            && let Some(nanos) = time.as_u64()
        {
            provider.time_nanos = nanos;
        }
        provider
    }

    pub fn read(&self, path: &str) -> Result<&[u8], IoErrorKind> {
        if let Some(&fault) = self.faults.get(path) {
            return Err(fault);
        }
        self.files
            .get(path)
            .map(Vec::as_slice)
            .ok_or(IoErrorKind::NotFound)
    }

    pub fn write(&mut self, path: String, content: Vec<u8>) -> Result<(), IoErrorKind> {
        if let Some(&fault) = self.faults.get(&path) {
            return Err(fault);
        }
        self.files.insert(path, content);
        Ok(())
    }

    pub(crate) fn delete(&mut self, path: &str) -> Result<(), IoErrorKind> {
        if let Some(&fault) = self.faults.get(path) {
            return Err(fault);
        }
        self.files
            .remove(path)
            .map(|_| ())
            .ok_or(IoErrorKind::NotFound)
    }

    pub(crate) fn current_time(&self) -> u64 {
        self.time_nanos
    }

    pub(crate) fn advance_time(&mut self, nanos: u64) {
        self.time_nanos = self.time_nanos.saturating_add(nanos);
    }

    pub(crate) fn program_arguments(&self) -> &[String] {
        &self.arguments
    }

    pub(crate) fn inject_fault(&mut self, path: String, kind: IoErrorKind) {
        self.faults.insert(path, kind);
    }
}
