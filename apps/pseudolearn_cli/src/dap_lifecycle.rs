use crate::dap_protocol::{argument, capabilities, event};
use crate::dap_session::DapSession;
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn lifecycle(&mut self, request: &Value) -> Result<Value, String> {
        match request.get("command").and_then(Value::as_str).unwrap_or("") {
            "initialize" => self.initialize(request),
            "launch" => self.launch(request),
            "configurationDone" => self.configuration_done(),
            "terminate" | "disconnect" => {
                self.terminate();
                Ok(json!({}))
            }
            _ => Err("unsupported lifecycle request".to_owned()),
        }
    }

    fn initialize(&mut self, request: &Value) -> Result<Value, String> {
        if self.handshake.initialized || self.finished {
            return Err("debug session is already initialized".to_owned());
        }
        if argument(request, "pathFormat")
            .as_str()
            .is_some_and(|format| format != "path")
        {
            return Err("only path source format is supported".to_owned());
        }
        self.sources.lines_start_at_one =
            argument(request, "linesStartAt1").as_bool().unwrap_or(true);
        self.sources.columns_start_at_one = argument(request, "columnsStartAt1")
            .as_bool()
            .unwrap_or(true);
        self.handshake.initialized = true;
        Ok(capabilities())
    }

    fn launch(&mut self, request: &Value) -> Result<Value, String> {
        if !self.handshake.initialized || self.resource.is_some() || self.finished {
            return Err("launch is invalid in the current state".to_owned());
        }
        if let Err(error) =
            crate::dap_launch::launch(self, request.get("arguments").unwrap_or(&Value::Null))
        {
            self.close();
            return Err(error);
        }
        self.pending.push(event("initialized", json!({})));
        Ok(json!({}))
    }

    fn configuration_done(&mut self) -> Result<Value, String> {
        if self.resource.is_none() || self.handshake.configured || self.finished {
            return Err("configurationDone is invalid in the current state".to_owned());
        }
        self.handshake.configured = true;
        self.call(
            "debug_control",
            &json!({"resource":self.execution()?,"command":"continue"}),
        )?;
        self.running = true;
        Ok(json!({}))
    }

    pub(crate) fn close(&mut self) {
        self.running = false;
        self.input_token = None;
        self.references.clear();
        self.sources.snapshots.clear();
        self.breakpoints.clear();
        if let Some(host) = self.effects.take() {
            host.close();
        }
        if let Some(resource) = self.resource.take() {
            let _ = self.api.call("cancel", &json!({"resource":resource}));
            let _ = self
                .api
                .call("advance", &json!({"resource":resource,"batch_size":1}));
            let _ = self.api.call("release", &json!({"resource":resource}));
        }
        if let Some(document) = self.document.take() {
            let _ = self.api.call("release", &json!({"resource":document}));
        }
    }

    pub(crate) fn terminate(&mut self) {
        if self.finished {
            return;
        }
        self.close();
        self.finished = true;
        self.pending.push(event("terminated", json!({})));
    }
}
