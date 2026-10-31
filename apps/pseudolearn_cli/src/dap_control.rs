use crate::dap_protocol::{argument, event};
use crate::dap_session::DapSession;
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn control(&mut self, request: &Value) -> Result<Value, String> {
        let command = request.get("command").and_then(Value::as_str).unwrap_or("");
        if command == "pseudolearn/input" {
            return self.input(request);
        }
        if !self.handshake.configured {
            return Err("debug execution is not configured".to_owned());
        }
        if command == "pause" {
            return self.pause();
        }
        if self.running {
            return Err("another debug control is active".to_owned());
        }
        let task = self.selected_task(argument(request, "threadId"))?;
        let condition = match command {
            "continue" => "continue",
            "next" => "next",
            "stepIn" => "step_in",
            "stepOut" => "step_out",
            "stepBack" => "step_back",
            _ => return Err("unsupported control".to_owned()),
        };
        self.state = self.call(
            "debug_control",
            &json!({"resource":self.execution()?,
            "command":condition,"task_id":task}),
        )?;
        self.references.clear();
        self.running = true;
        let identifier = self.thread_id(task)?;
        self.pending.push(event(
            "continued",
            json!({"threadId":identifier,"allThreadsContinued":true}),
        ));
        Ok(json!({"allThreadsContinued":true}))
    }

    fn pause(&mut self) -> Result<Value, String> {
        if !self.running {
            return Err("debug execution is already paused".to_owned());
        }
        self.call(
            "debug_control",
            &json!({"resource":self.execution()?,"command":"pause"}),
        )?;
        self.running = false;
        self.refresh()?;
        self.stopped("pause");
        Ok(json!({}))
    }

    fn input(&mut self, request: &Value) -> Result<Value, String> {
        let token = argument(request, "token")
            .as_str()
            .ok_or("missing input token")?;
        if self.input_token.as_deref() != Some(token) {
            return Err("stale input token".to_owned());
        }
        match argument(request, "action").as_str() {
            Some("cancel") => {
                self.input_token = None;
                self.terminate();
            }
            Some("line") => {
                let text = argument(request, "text")
                    .as_str()
                    .ok_or("missing input line")?;
                self.call("input", &json!({"resource":self.execution()?,"text":text}))?;
                self.input_token = None;
            }
            _ => return Err("invalid input action".to_owned()),
        }
        Ok(json!({}))
    }

    pub(crate) fn selected_task(&self, identifier: &Value) -> Result<u64, String> {
        if identifier.is_null() {
            return Ok(0);
        }
        let identifier = identifier
            .as_i64()
            .and_then(|value| i32::try_from(value).ok())
            .ok_or("invalid thread identifier")?;
        self.threads
            .iter()
            .find(|(_, assigned)| **assigned == identifier)
            .map(|(task, _)| *task)
            .ok_or_else(|| "unknown thread identifier".to_owned())
    }

    pub(crate) fn thread_id(&mut self, task: u64) -> Result<i32, String> {
        if let Some(identifier) = self.threads.get(&task) {
            return Ok(*identifier);
        }
        let identifier = i32::try_from(self.threads.len())
            .ok()
            .and_then(|count| count.checked_add(1))
            .ok_or("debug thread identifiers exhausted")?;
        self.threads.insert(task, identifier);
        Ok(identifier)
    }

    pub(crate) fn stopped(&mut self, reason: &str) {
        let task = self
            .state
            .get("task_id")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let identifier = self.thread_id(task).unwrap_or(1);
        self.pending.push(event(
            "stopped",
            json!({"reason":reason,"threadId":identifier,
            "allThreadsStopped":true,"preserveFocusHint":false}),
        ));
    }
}
