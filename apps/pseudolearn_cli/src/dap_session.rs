use crate::dap_protocol::response;
use crate::dap_sources::Sources;
use crate::options::CliOptions;
use pseudolearn_api::ApiSession;
use serde_json::Value;
use std::collections::BTreeMap;

pub(crate) enum Reference {
    Frame {
        task: u64,
        position: u64,
        generation: u64,
    },
    Variables {
        task: u64,
        target: u64,
        query: String,
        generation: u64,
    },
}

#[derive(Default)]
pub(crate) struct Handshake {
    pub(crate) initialized: bool,
    pub(crate) configured: bool,
}

pub(crate) struct DapSession {
    pub(crate) api: ApiSession,
    pub(crate) options: Option<CliOptions>,
    pub(crate) resource: Option<Value>,
    pub(crate) document: Option<Value>,
    pub(crate) handshake: Handshake,
    pub(crate) running: bool,
    pub(crate) finished: bool,
    pub(crate) state: Value,
    pub(crate) sources: Sources,
    pub(crate) references: BTreeMap<i32, Reference>,
    pub(crate) threads: BTreeMap<u64, i32>,
    pub(crate) next_reference: i32,
    pub(crate) input_token: Option<String>,
    pub(crate) input_generation: u64,
    pub(crate) output_bytes: usize,
    pub(crate) effects: Option<crate::dap_effects::EffectHost>,
    pub(crate) pending: Vec<Value>,
    pub(crate) breakpoints: BTreeMap<u32, Vec<Value>>,
    pub(crate) stop_on_entry: bool,
}

impl DapSession {
    pub(crate) fn new(options: Option<CliOptions>) -> Self {
        Self {
            api: ApiSession::default(),
            options,
            resource: None,
            document: None,
            handshake: Handshake::default(),
            running: false,
            finished: false,
            state: Value::Null,
            sources: Sources::default(),
            references: BTreeMap::new(),
            threads: BTreeMap::new(),
            next_reference: 0,
            input_token: None,
            input_generation: 0,
            output_bytes: 0,
            effects: None,
            pending: Vec::new(),
            breakpoints: BTreeMap::new(),
            stop_on_entry: true,
        }
    }

    pub(crate) fn handle(&mut self, request: &Value) -> Vec<Value> {
        self.pending.clear();
        let outcome = self.dispatch(request);
        let mut messages = vec![response(request, outcome)];
        messages.append(&mut self.pending);
        messages
    }

    fn dispatch(&mut self, request: &Value) -> Result<Value, String> {
        if request.get("type").and_then(Value::as_str) != Some("request")
            || request.get("seq").and_then(Value::as_u64).is_none()
        {
            return Err("invalid debug request".to_owned());
        }
        match request.get("command").and_then(Value::as_str).unwrap_or("") {
            "initialize" | "launch" | "configurationDone" | "terminate" | "disconnect" => {
                self.lifecycle(request)
            }
            "setBreakpoints" => self.breakpoints(request),
            "continue" | "next" | "stepIn" | "stepOut" | "pause" | "stepBack"
            | "pseudolearn/input" => self.control(request),
            "threads" | "stackTrace" | "scopes" | "variables" | "evaluate" | "source"
            | "loadedSources" => self.inspect(request),
            _ => Err("unsupported debug request".to_owned()),
        }
    }

    pub(crate) fn can_advance(&self) -> bool {
        self.running
            && self.input_token.is_none()
            && !self
                .effects
                .as_ref()
                .is_some_and(crate::dap_effects::EffectHost::is_pending)
    }
    pub(crate) fn is_finished(&self) -> bool {
        self.finished
    }
}
