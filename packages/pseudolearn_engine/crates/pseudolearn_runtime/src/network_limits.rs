use crate::{HttpRequestValue, HttpResponseValue, IoError};
use pseudolearn_abi::IoErrorKind;

pub const DEFAULT_JSON_DEPTH: usize = 64;
pub const DEFAULT_HTTP_BODY_BYTES: u64 = 1_048_576;
pub const DEFAULT_HTTP_WIRE_BYTES: u64 = 1_048_576;
pub const DEFAULT_HTTP_HEADER_BYTES: u64 = 16_384;
pub const DEFAULT_HTTP_HEADERS: u64 = 64;
pub const DEFAULT_PENDING_NETWORK: u64 = 4;
pub const DEFAULT_HTTP_TIMEOUT_NANOS: u64 = 30_000_000_000;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct NetworkLimits {
    pub body_bytes: u64,
    pub wire_bytes: u64,
    pub header_bytes: u64,
    pub headers: u64,
    pub pending: u64,
    pub timeout_nanos: u64,
}

impl Default for NetworkLimits {
    fn default() -> Self {
        Self {
            body_bytes: DEFAULT_HTTP_BODY_BYTES,
            wire_bytes: DEFAULT_HTTP_WIRE_BYTES,
            header_bytes: DEFAULT_HTTP_HEADER_BYTES,
            headers: DEFAULT_HTTP_HEADERS,
            pending: DEFAULT_PENDING_NETWORK,
            timeout_nanos: DEFAULT_HTTP_TIMEOUT_NANOS,
        }
    }
}

impl NetworkLimits {
    pub fn has_positive_values(self) -> bool {
        self.body_bytes > 0
            && self.wire_bytes > 0
            && self.header_bytes > 0
            && self.headers > 0
            && self.pending > 0
            && self.timeout_nanos > 0
    }
}

pub fn prepare_request(
    request: &mut HttpRequestValue,
    limits: NetworkLimits,
) -> Result<(), IoError> {
    if !limits.has_positive_values() {
        return Err(invalid_request());
    }
    let response_limit = positive(request.response_limit)?;
    let timeout_nanos = positive(request.timeout_nanos)?;
    crate::network_headers::validate(&request.headers)?;
    validate_header_size(&request.headers, limits)?;
    if request
        .body
        .as_ref()
        .is_some_and(|body| u64::try_from(body.len()).unwrap_or(u64::MAX) > limits.wire_bytes)
    {
        return Err(limit_exceeded());
    }
    request.effective_response_limit =
        Some(response_limit.map_or(limits.body_bytes, |value| value.min(limits.body_bytes)));
    request.effective_timeout_nanos = Some(timeout_nanos.map_or(limits.timeout_nanos, |value| {
        value.min(limits.timeout_nanos)
    }));
    request.wire_limit = Some(limits.wire_bytes);
    request.header_bytes_limit = Some(limits.header_bytes);
    request.headers_limit = Some(limits.headers);
    Ok(())
}

pub fn validate_response(
    response: &HttpResponseValue,
    request: &HttpRequestValue,
) -> Result<(), IoError> {
    crate::network_policy::validate_response(response)?;
    let body_limit = request
        .effective_response_limit
        .unwrap_or(DEFAULT_HTTP_BODY_BYTES);
    if u64::try_from(response.body.len()).unwrap_or(u64::MAX) > body_limit {
        return Err(limit_exceeded());
    }
    let limits = NetworkLimits {
        body_bytes: body_limit,
        wire_bytes: request.wire_limit.unwrap_or(DEFAULT_HTTP_WIRE_BYTES),
        header_bytes: request
            .header_bytes_limit
            .unwrap_or(DEFAULT_HTTP_HEADER_BYTES),
        headers: request.headers_limit.unwrap_or(DEFAULT_HTTP_HEADERS),
        pending: DEFAULT_PENDING_NETWORK,
        timeout_nanos: request
            .effective_timeout_nanos
            .unwrap_or(DEFAULT_HTTP_TIMEOUT_NANOS),
    };
    validate_header_size(&response.headers, limits)
}

pub fn pending_limit_exceeded(pending: u64, maximum: u64) -> bool {
    pending > maximum
}

fn positive(value: Option<i64>) -> Result<Option<u64>, IoError> {
    value
        .map(|value| {
            u64::try_from(value)
                .ok()
                .filter(|value| *value > 0)
                .ok_or_else(invalid_request)
        })
        .transpose()
}

fn validate_header_size(
    headers: &[(String, String)],
    limits: NetworkLimits,
) -> Result<(), IoError> {
    let count = u64::try_from(headers.len()).unwrap_or(u64::MAX);
    let bytes = headers.iter().try_fold(0_u64, |total, (name, value)| {
        let name = u64::try_from(name.len()).ok()?;
        let value = u64::try_from(value.len()).ok()?;
        total.checked_add(name)?.checked_add(value)?.checked_add(4)
    });
    if count > limits.headers || bytes.is_none_or(|bytes| bytes > limits.header_bytes) {
        return Err(limit_exceeded());
    }
    Ok(())
}

fn invalid_request() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidRequest)
}

fn limit_exceeded() -> IoError {
    IoError::from_kind(IoErrorKind::LimitExceeded)
}
