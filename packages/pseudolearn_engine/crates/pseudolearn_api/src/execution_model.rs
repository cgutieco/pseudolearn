use crate::ApiDiagnostic;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
pub struct ExecutionLimits {
    pub depth: Option<usize>,
    pub statements: Option<u64>,
    pub cells: Option<u64>,
    pub micro_steps: Option<u64>,
    pub tasks: Option<u64>,
    pub channel_capacity: Option<u64>,
    pub max_json_depth: Option<usize>,
    pub max_http_body_bytes: Option<u64>,
    pub max_http_wire_bytes: Option<u64>,
    pub max_http_header_bytes: Option<u64>,
    pub max_http_headers: Option<u64>,
    pub max_pending_network: Option<u64>,
    pub max_http_timeout_nanos: Option<u64>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(default)]
pub struct ExecuteRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
    pub seed: i64,
    pub inputs: Vec<String>,
    pub observe: String,
    pub limits: ExecutionLimits,
    pub cancel_at_statement: Option<u64>,
    pub cancel_at_poll: Option<u64>,
    pub state_at: Option<usize>,
    pub state_page: Option<serde_json::Value>,
    pub include_program_view: bool,
    pub gc_stress: bool,
    pub source: Option<crate::ApiSourceIdentity>,
    pub execution_mode: Option<String>,
    pub effect_tape: Option<serde_json::Value>,
    pub host: Option<serde_json::Value>,
}

impl Default for ExecuteRequest {
    fn default() -> Self {
        Self {
            program: String::new(),
            profile: "es".to_owned(),
            strictness: "strict".to_owned(),
            seed: 42,
            inputs: Vec::new(),
            observe: "none".to_owned(),
            limits: ExecutionLimits::default(),
            cancel_at_statement: None,
            cancel_at_poll: None,
            state_at: None,
            state_page: None,
            include_program_view: false,
            gc_stress: false,
            source: None,
            execution_mode: None,
            effect_tape: None,
            host: None,
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct ExecuteResponse {
    pub kind: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub effect_tape: Option<serde_json::Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub pending_effect: Option<serde_json::Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub host_observation: Option<serde_json::Value>,
    pub output: String,
    pub termination: serde_json::Value,
    pub diagnostics: Vec<ApiDiagnostic>,
    pub events: Vec<serde_json::Value>,
    pub inputs_consumed: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub state_at: Option<serde_json::Value>,
}
