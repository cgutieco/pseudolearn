use crate::physical_error::{HostError, committed};
use crate::physical_files::Entry;
use crate::physical_request::Request;
use cap_std::fs::Dir;
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) struct PhysicalHost {
    pub(crate) root: Option<(Dir, u8)>,
    pub(crate) entries: BTreeMap<u32, Entry>,
    logical_nanos: Option<i64>,
}

impl PhysicalHost {
    pub fn new(root: Option<(Dir, u8)>) -> Self {
        Self {
            root,
            entries: BTreeMap::new(),
            logical_nanos: None,
        }
    }

    pub fn perform(&mut self, raw: &Value) -> Value {
        if raw.get("operation").and_then(Value::as_str) == Some("network_send") {
            return crate::physical_network_send::perform(raw);
        }
        let outcome = serde_json::from_value::<Request>(raw.clone())
            .map_err(|_| HostError::INVALID_PATH)
            .and_then(|request| self.dispatch(&request));
        outcome.unwrap_or_else(HostError::reply)
    }

    fn dispatch(&mut self, request: &Request) -> Result<Value, HostError> {
        match request.operation.as_str() {
            "console_write" => console_write(request),
            "arguments_values" => Ok(committed("text_list", json!([]))),
            "clock_now" => self.clock_now(),
            "timer_wait" => self.timer_wait(request),
            "request_directory" => self.request_root(request),
            name if name.starts_with("request_") => self.register_plain(request),
            _ => self.file_operation(request),
        }
    }

    fn clock_now(&mut self) -> Result<Value, HostError> {
        let now = self.logical_nanos.map_or_else(real_nanos, Ok)?;
        self.logical_nanos = Some(now);
        Ok(committed("integer", json!(now)))
    }

    fn timer_wait(&mut self, request: &Request) -> Result<Value, HostError> {
        let Some(crate::physical_request::Argument::Integer(duration)) = request.arguments.first()
        else {
            return Err(HostError::TIMED_OUT);
        };
        let base = self.logical_nanos.map_or_else(real_nanos, Ok)?;
        let advanced = base.checked_add(*duration).ok_or(HostError::TIMED_OUT)?;
        self.logical_nanos = Some(advanced);
        Ok(committed("integer", json!(advanced)))
    }
}

fn real_nanos() -> Result<i64, HostError> {
    let elapsed = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_err(|_| HostError::INTERRUPTED)?;
    i64::try_from(elapsed.as_nanos()).map_err(|_| HostError::INTERRUPTED)
}

fn console_write(request: &Request) -> Result<Value, HostError> {
    use std::io::Write;
    let text = request.text(0)?;
    let mut stdout = std::io::stdout().lock();
    stdout
        .write_all(text.as_bytes())
        .and_then(|()| stdout.flush())
        .map_err(|_| HostError::INTERRUPTED)?;
    let length = i64::try_from(text.len()).map_err(|_| HostError::INTERRUPTED)?;
    Ok(committed("integer", json!(length)))
}
