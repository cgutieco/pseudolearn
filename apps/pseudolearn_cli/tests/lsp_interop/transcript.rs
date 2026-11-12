use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Debug, PartialEq)]
pub struct Transcript {
    pub root: String,
    pub steps: Vec<Value>,
    pub diagnostics: BTreeMap<String, Value>,
}

impl Transcript {
    pub fn from_value(root: &str, document: &Value) -> Result<Self, String> {
        let steps = document
            .get("steps")
            .and_then(Value::as_array)
            .ok_or("transcript has no steps array")?
            .clone();
        let diagnostics = document
            .get("diagnostics")
            .and_then(Value::as_object)
            .ok_or("transcript has no diagnostics object")?
            .iter()
            .map(|(uri, published)| (uri.clone(), published.clone()))
            .collect();
        Ok(Self {
            root: root.to_owned(),
            steps,
            diagnostics,
        })
    }

    pub fn step_number(entry: &Value) -> Option<u64> {
        entry.get("step").and_then(Value::as_u64)
    }
}
