use crate::pg_tasks_agendas::Agenda;
use pseudolearn_api::ExecuteResponse;
use serde_json::Value;

#[derive(Clone, Debug, PartialEq)]
pub struct Observation {
    pub output: String,
    pub kind: String,
    pub code: Option<String>,
    pub tape: Option<Value>,
}

pub fn observe(response: &ExecuteResponse) -> Observation {
    let text = |field: &str| {
        response
            .termination
            .get(field)
            .and_then(Value::as_str)
            .map(str::to_owned)
    };
    Observation {
        output: response.output.clone(),
        kind: text("kind").unwrap_or_default(),
        code: text("code"),
        tape: response.effect_tape.clone(),
    }
}

pub fn differences(label: &str, left: &Observation, right: &Observation) -> Vec<String> {
    let mut found = Vec::new();
    if left.output != right.output {
        found.push(format!("{label}: output differs"));
    }
    if left.kind != right.kind || left.code != right.code {
        found.push(format!("{label}: termination differs"));
    }
    if left.tape != right.tape {
        found.push(format!("{label}: tape differs"));
    }
    found
}

pub fn against_expected(agenda: &Agenda, observed: &Observation) -> Vec<String> {
    let mut found = Vec::new();
    if observed.output != agenda.expected.output {
        found.push("expected output differs".to_owned());
    }
    let reached = observed.code.as_deref().unwrap_or(observed.kind.as_str());
    if reached != agenda.expected.termination {
        found.push(format!(
            "expected termination {} but reached {reached}",
            agenda.expected.termination
        ));
    }
    found
}
