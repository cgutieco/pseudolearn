use crate::dap_session::DapSession;
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn call(&mut self, operation: &str, arguments: &Value) -> Result<Value, String> {
        let answer = self.api.call(operation, arguments);
        answer.get("value").cloned().ok_or_else(|| {
            answer
                .get("failure")
                .map_or_else(|| "invalid core response".to_owned(), ToString::to_string)
        })
    }

    pub(crate) fn execution(&self) -> Result<Value, String> {
        self.resource
            .clone()
            .ok_or_else(|| "debug session has no execution".to_owned())
    }

    pub(crate) fn generation(&self) -> u64 {
        self.state
            .get("stop_generation")
            .and_then(Value::as_u64)
            .unwrap_or(0)
    }

    pub(crate) fn refresh(&mut self) -> Result<(), String> {
        self.state = self.call("debug_state", &json!({"resource":self.execution()?}))?;
        self.update_sources();
        Ok(())
    }

    pub(crate) fn update_sources(&mut self) {
        let Some(sources) = self.state.get("sources").and_then(Value::as_array) else {
            return;
        };
        for source in sources {
            let Some(identifier) = source
                .get("source_id")
                .and_then(Value::as_u64)
                .and_then(|identifier| u32::try_from(identifier).ok())
            else {
                continue;
            };
            if let Some(snapshot) = self.sources.snapshots.get_mut(&identifier) {
                snapshot.revision = source
                    .get("revision")
                    .and_then(Value::as_str)
                    .map(str::to_owned);
            }
        }
    }
}
