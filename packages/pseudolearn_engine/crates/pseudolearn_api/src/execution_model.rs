use crate::ApiDiagnostic;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
pub struct ExecutionLimits {
    pub depth: Option<usize>,
    pub statements: Option<u64>,
    pub cells: Option<u64>,
    pub micro_steps: Option<u64>,
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
        }
    }
}

#[derive(Clone, Debug, Serialize)]
pub struct ExecuteResponse {
    pub kind: String,
    pub output: String,
    pub termination: serde_json::Value,
    pub diagnostics: Vec<ApiDiagnostic>,
    pub events: Vec<serde_json::Value>,
    pub inputs_consumed: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub state_at: Option<serde_json::Value>,
}
