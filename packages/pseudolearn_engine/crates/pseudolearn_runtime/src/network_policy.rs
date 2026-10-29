use crate::{HttpMethod, HttpRequestValue, HttpResponseValue, IoError};
use pseudolearn_abi::IoErrorKind;
use std::collections::BTreeSet;

pub(crate) fn validate_request(
    request: &HttpRequestValue,
    origins: &BTreeSet<String>,
) -> Result<crate::network_url::ParsedUrl, IoError> {
    let parsed = crate::network_url::parse_url(&request.url)?;
    if !origins.contains(&parsed.origin) {
        return Err(IoError::from_kind(IoErrorKind::DestinationDenied));
    }
    crate::network_headers::validate(&request.headers)?;
    if matches!(request.method, HttpMethod::Get | HttpMethod::Head) && request.body.is_some() {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    Ok(parsed)
}

pub(crate) fn request_key(request: &HttpRequestValue) -> Result<String, IoError> {
    let parsed = crate::network_url::parse_url(&request.url)?;
    Ok(format!(
        "{} {}",
        request.method.as_str(),
        parsed.without_fragment
    ))
}

pub(crate) fn validate_response(response: &HttpResponseValue) -> Result<(), IoError> {
    if !(100..=599).contains(&response.status) || response.status == 101 {
        return Err(IoError::from_kind(IoErrorKind::InvalidResponse));
    }
    crate::network_headers::validate_response(&response.headers)
}

pub(crate) fn configured_origins(host: Option<&serde_json::Value>) -> BTreeSet<String> {
    host.and_then(|value| value.get("http"))
        .and_then(serde_json::Value::as_object)
        .into_iter()
        .flat_map(serde_json::Map::keys)
        .filter_map(|key| script_origin(key))
        .collect()
}

fn script_origin(key: &str) -> Option<String> {
    let (method, url) = key.split_once(' ')?;
    HttpMethod::parse(method)?;
    crate::network_url::parse_url(url)
        .ok()
        .map(|parsed| parsed.origin)
}
