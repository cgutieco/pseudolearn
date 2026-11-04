use crate::physical_error::{HostError, committed};
use crate::physical_files::Entry;
use crate::physical_request::{Argument, Request};
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::path::PathBuf;
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
};

pub struct PhysicalHost {
    pub(crate) working_directory: PathBuf,
    pub(crate) entries: BTreeMap<u32, Entry>,
    arguments: Vec<String>,
    network_policy: Arc<crate::NetworkPolicy>,
    cancellation: Arc<AtomicBool>,
}

impl PhysicalHost {
    pub fn new(working_directory: PathBuf, arguments: Vec<String>) -> Self {
        Self {
            working_directory,
            arguments,
            entries: BTreeMap::new(),
            network_policy: Arc::new(crate::NetworkPolicy::default_policy()),
            cancellation: Arc::new(AtomicBool::new(false)),
        }
    }

    pub fn set_network_policy(&mut self, policy: crate::NetworkPolicy) {
        self.network_policy = Arc::new(policy);
    }

    pub(crate) fn fork(&self) -> Self {
        Self {
            working_directory: self.working_directory.clone(),
            arguments: self.arguments.clone(),
            entries: BTreeMap::new(),
            network_policy: self.network_policy.clone(),
            cancellation: self.cancellation.clone(),
        }
    }

    pub fn network_policy(&self) -> &Arc<crate::NetworkPolicy> {
        &self.network_policy
    }

    pub fn cancellation(&self) -> Arc<AtomicBool> {
        self.cancellation.clone()
    }

    pub fn set_cancellation(&mut self, cancellation: Arc<AtomicBool>) {
        self.cancellation = cancellation;
    }

    pub fn perform(&mut self, raw: &Value) -> Value {
        if self.cancellation.load(Ordering::SeqCst) {
            return HostError::INTERRUPTED.reply();
        }
        if raw.get("operation").and_then(Value::as_str) == Some("network_send") {
            return crate::physical_network_send::perform_cancellable(
                raw,
                &self.network_policy,
                self.cancellation.clone(),
            );
        }
        let outcome = serde_json::from_value::<Request>(raw.clone())
            .map_err(|_| HostError::INVALID_PATH)
            .and_then(|request| self.dispatch(&request));
        outcome.unwrap_or_else(HostError::reply)
    }

    fn dispatch(&mut self, request: &Request) -> Result<Value, HostError> {
        match request.operation.as_str() {
            "console_write" => console_write(request),
            "arguments_values" => Ok(committed("text_list", json!(self.arguments))),
            "clock_now" => Ok(committed("integer", json!(real_nanos()?))),
            "clock_local_now" => crate::physical_local_zone::local_now(real_nanos()?),
            "environment_get" => crate::physical_environment::environment_get(request),
            "timer_wait" => self.timer_wait(request),
            "request_directory" => self.request_root(request),
            name if name.starts_with("request_") => self.register_plain(request),
            "network_restrict" => self.register_plain(request),
            "network_close" => Ok(committed("boolean", true)),
            _ => self.file_operation(request),
        }
    }

    fn timer_wait(&self, request: &Request) -> Result<Value, HostError> {
        let Some(Argument::Integer(duration)) = request.arguments.first() else {
            return Err(HostError::TIMED_OUT);
        };
        let nanos = u64::try_from(*duration).map_err(|_| HostError::TIMED_OUT)?;
        let start = std::time::Instant::now();
        let duration = std::time::Duration::from_nanos(nanos);
        while start.elapsed() < duration {
            if self.cancellation.load(Ordering::SeqCst) {
                return Err(HostError::INTERRUPTED);
            }
            std::thread::sleep(
                duration
                    .saturating_sub(start.elapsed())
                    .min(std::time::Duration::from_millis(5)),
            );
        }
        Ok(committed("integer", json!(real_nanos()?)))
    }
}

pub fn entropy_seed() -> Result<i64, String> {
    let mut bytes = [0_u8; 8];
    getrandom::getrandom(&mut bytes).map_err(|error| error.to_string())?;
    Ok(i64::from_le_bytes(bytes))
}

pub(crate) fn real_nanos() -> Result<i64, HostError> {
    let elapsed = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_err(|_| HostError::INTERRUPTED)?;
    i64::try_from(elapsed.as_nanos()).map_err(|_| HostError::INTERRUPTED)
}

fn console_write(request: &Request) -> Result<Value, HostError> {
    let text = request.text(0)?;
    let length = i64::try_from(text.len()).map_err(|_| HostError::INTERRUPTED)?;
    Ok(committed("integer", json!(length)))
}
