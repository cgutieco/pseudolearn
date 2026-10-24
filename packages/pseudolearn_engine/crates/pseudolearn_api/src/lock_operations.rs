use crate::ApiError;
use crate::lock_wire::{LOCK_BYTE_BUDGET, error_values, packages};
use crate::project_resource::usage;
use pseudolearn_project::Lock;
use serde_json::{Value, json};

pub(crate) fn build(arguments: &Value) -> Result<Value, ApiError> {
    Ok(match Lock::from_packages(packages(arguments)?) {
        Ok(lock) => json!({"lock": lock.canonical_text(), "lock_errors": []}),
        Err(errors) => json!({"lock": Value::Null, "lock_errors": error_values(&errors)}),
    })
}

pub(crate) fn resolve(arguments: &Value) -> Result<Value, ApiError> {
    let text = arguments
        .get("lock")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing lock"))?;
    let observed = packages(arguments)?;
    let errors = match (
        Lock::parse(text, LOCK_BYTE_BUDGET),
        Lock::from_packages(observed),
    ) {
        (Ok(recorded), Ok(actual)) => recorded.verify(&actual),
        (Err(errors), _) | (_, Err(errors)) => errors,
    };
    Ok(json!({"verified": errors.is_empty(), "lock_errors": error_values(&errors)}))
}
