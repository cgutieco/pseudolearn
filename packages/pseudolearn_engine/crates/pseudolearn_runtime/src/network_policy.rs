use crate::{HttpMethod, HttpRequestValue, HttpResponseValue, IoError};
use pseudolearn_abi::IoErrorKind;
use std::collections::BTreeSet;

pub(crate) fn validate_request(
    request: &HttpRequestValue,
    origins: &BTreeSet<String>,
) -> Result<crate::network_url::ParsedUrl, IoError> {
    let parsed = crate::network_url::parse_url(&request.url)?;
    if !origins.is_empty() && !origins.contains(&parsed.origin) {
        return Err(IoError::from_kind(IoErrorKind::DestinationDenied));
    }
    crate::network_headers::validate(&request.headers)?;
    if matches!(request.method, HttpMethod::Get | HttpMethod::Head) && request.body.is_some() {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    Ok(parsed)
}

#[cfg(feature = "test-host")]
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
