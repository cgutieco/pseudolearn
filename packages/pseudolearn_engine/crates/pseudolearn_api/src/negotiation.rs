use crate::ApiError;
use serde_json::Value;

pub(crate) fn negotiate(arguments: &Value) -> Result<Value, ApiError> {
    validate_requested_versions(arguments)?;
    let mut response = serde_json::Map::new();
    select_network_capabilities(arguments, &mut response)?;
    select_event_binary_version(arguments, &mut response)?;
    if response.is_empty() {
        Ok(Value::Null)
    } else {
        Ok(Value::Object(response))
    }
}

fn validate_requested_versions(arguments: &Value) -> Result<(), ApiError> {
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
    Ok(())
}

fn select_network_capabilities(
    arguments: &Value,
    response: &mut serde_json::Map<String, Value>,
) -> Result<(), ApiError> {
    if let Some(capabilities) = arguments.get("network_capabilities") {
        if !valid_network_capabilities(capabilities) {
            return Err(ApiError::InvalidProtocol(
                "invalid network capabilities".to_owned(),
            ));
        }
        response.insert("network_capabilities".to_owned(), capabilities.clone());
    }
    Ok(())
}

fn select_event_binary_version(
    arguments: &Value,
    response: &mut serde_json::Map<String, Value>,
) -> Result<(), ApiError> {
    if let Some(requested_versions) = arguments.get("event_binary_versions") {
        let versions = requested_versions
            .as_array()
            .ok_or_else(|| ApiError::InvalidProtocol("invalid event binary versions".to_owned()))?;
        let selected = versions
            .iter()
            .filter_map(Value::as_u64)
            .filter(|version| matches!(version, 1 | 2))
            .max()
            .ok_or_else(|| ApiError::UnsupportedVersion("event_binary".to_owned()))?;
        response.insert("event_binary_version".to_owned(), Value::from(selected));
        response.insert(
            "event_binary_write_version".to_owned(),
            Value::from(selected),
        );
        response.insert(
            "event_binary_read_versions".to_owned(),
            serde_json::json!([1, 2]),
        );
    }
    Ok(())
}

fn valid_network_capabilities(value: &Value) -> bool {
    let Some(fields) = value.as_object() else {
        return false;
    };
    fields.len() == 6
        && value.get("tls_validation") == Some(&Value::Bool(true))
        && matches!(
            value.get("wire_limit").and_then(Value::as_str),
            Some("available" | "unavailable")
        )
        && value
            .get("certificate_errors_distinguished")
            .is_some_and(Value::is_boolean)
        && value
            .get("redirect_location_visible")
            .is_some_and(Value::is_boolean)
        && matches!(
            value.get("ssrf_policy").and_then(Value::as_str),
            Some("adapter" | "browser")
        )
        && matches!(
            value.get("compression").and_then(Value::as_str),
            Some("gzip" | "browser")
        )
}
