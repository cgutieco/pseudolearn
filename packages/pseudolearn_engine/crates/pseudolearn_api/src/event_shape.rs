use crate::ApiError;
use crate::event_codec::{canonical_value, serialization_failure};
use crate::execution_resource::usage;
use serde_json::Value;

const EVENT_KEYS: &[&str] = &["class", "line", "depth", "data", "source"];
const RECORD_KEYS: &[&str] = &["data", "source"];
const BRANCHES: &[&str] = &["afirmativa", "negativa", "caso", "otro", "ninguna"];

pub(crate) fn require_event_keys(event: &Value) -> Result<(), ApiError> {
    let fields = event.as_object().ok_or_else(|| usage("invalid event"))?;
    if fields.keys().any(|key| !EVENT_KEYS.contains(&key.as_str())) {
        return Err(usage("unknown event field"));
    }
    Ok(())
}

pub(crate) fn single_text(body: Option<&Value>, name: &str) -> Result<String, ApiError> {
    body.and_then(Value::as_object)
        .filter(|fields| fields.len() == 1)
        .and_then(|fields| fields.get(name))
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| usage("invalid event payload"))
}

pub(crate) fn decision(body: Option<&Value>) -> Result<(String, Option<u64>), ApiError> {
    let fields = body
        .and_then(Value::as_object)
        .filter(|fields| fields.keys().all(|key| key == "rama" || key == "indice"))
        .ok_or_else(|| usage("invalid event payload"))?;
    let branch = fields
        .get("rama")
        .and_then(Value::as_str)
        .filter(|branch| BRANCHES.contains(branch))
        .ok_or_else(|| usage("invalid event payload"))?;
    let index = fields
        .get("indice")
        .map(|index| index.as_u64().ok_or_else(|| usage("invalid event payload")))
        .transpose()?;
    Ok((branch.to_owned(), index))
}

pub(crate) fn canonical_record(text: &str) -> Result<Value, ApiError> {
    let record: Value = serde_json::from_str(text).map_err(|error| usage(&error.to_string()))?;
    let exact_keys = record.as_object().is_some_and(|fields| {
        fields.len() == RECORD_KEYS.len() && RECORD_KEYS.iter().all(|key| fields.contains_key(*key))
    });
    let canonical =
        serde_json::to_string(&canonical_value(record.clone())).map_err(serialization_failure)?;
    if !exact_keys || canonical != text {
        return Err(usage("non-canonical event record"));
    }
    Ok(record)
}
