use crate::service::workspace_campaign::clock::Clock;
use crate::service::workspace_campaign::loads::Load;
use crate::service::workspace_campaign::transport::Transport;
use serde_json::{Value, json};
use std::collections::VecDeque;

pub const TINY_LOAD: Load = Load {
    name: "tiny",
    files: 3,
    lines_per_file: 9,
};

pub struct SteppingClock {
    now: u64,
    step: u64,
}

impl SteppingClock {
    pub fn new(step_nanos: u64) -> Self {
        Self {
            now: 0,
            step: step_nanos,
        }
    }
}

impl Clock for SteppingClock {
    fn now_nanos(&mut self) -> u64 {
        let current = self.now;
        self.now = self.now.saturating_add(self.step);
        current
    }
}

pub struct ScriptedTransport {
    pending: VecDeque<Value>,
    diagnostic: String,
}

impl ScriptedTransport {
    pub fn new(diagnostic: &str) -> Self {
        Self {
            pending: VecDeque::new(),
            diagnostic: diagnostic.to_owned(),
        }
    }

    fn publish(&mut self, message: &Value) {
        if let Some(uri) = message.pointer("/params/textDocument/uri") {
            self.pending.push_back(json!({
                "jsonrpc": "2.0", "method": "textDocument/publishDiagnostics",
                "params": {"uri": uri, "diagnostics": [{"message": self.diagnostic}]}
            }));
        }
    }
}

impl Transport for ScriptedTransport {
    fn send(&mut self, message: &Value) -> Result<(), String> {
        let method = message.get("method").and_then(Value::as_str).unwrap_or("");
        if method == "textDocument/didOpen" || method == "textDocument/didChange" {
            self.publish(message);
        }
        if let Some(id) = message.get("id") {
            self.pending
                .push_back(json!({"jsonrpc": "2.0", "id": id, "result": []}));
        }
        Ok(())
    }

    fn receive(&mut self) -> Result<Value, String> {
        self.pending
            .pop_front()
            .ok_or_else(|| "server closed the stream".to_owned())
    }
}

pub fn alternating_connect(
    candidate: &'static str,
    control: &'static str,
) -> impl FnMut() -> Result<ScriptedTransport, String> {
    let mut calls = 0_usize;
    move || {
        calls = calls.saturating_add(1);
        Ok(ScriptedTransport::new(if calls.is_multiple_of(2) {
            control
        } else {
            candidate
        }))
    }
}
