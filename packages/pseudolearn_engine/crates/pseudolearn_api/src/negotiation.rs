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
    let Some(requested_versions) = arguments.get("event_binary_versions") else {
        return Ok(Value::Null);
    };
    let versions = requested_versions
        .as_array()
        .ok_or_else(|| ApiError::InvalidProtocol("invalid event binary versions".to_owned()))?;
    let selected = versions
        .iter()
        .filter_map(Value::as_u64)
        .filter(|version| matches!(version, 1 | 2))
        .max()
        .ok_or_else(|| ApiError::UnsupportedVersion("event_binary".to_owned()))?;
    Ok(serde_json::json!({
        "event_binary_version": selected,
        "event_binary_write_version": selected,
        "event_binary_read_versions": [1, 2]
    }))
}
