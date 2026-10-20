use crate::ApiError;
use serde_json::Value;

pub(crate) fn negotiate(arguments: &Value) -> Result<Value, ApiError> {
    for (name, values) in [
        ("editions", vec!["2026"]),
        ("capabilities", crate::supported_capabilities()),
    ] {
        if let Some(requested) = arguments.get(name) {
            let requested = requested
                .as_str()
                .ok_or_else(|| ApiError::InvalidProtocol("invalid negotiation value".to_owned()))?;
            if !values.contains(&requested) {
                return Err(ApiError::UnsupportedVersion(requested.to_owned()));
            }
        }
    }
    Ok(Value::Null)
}
