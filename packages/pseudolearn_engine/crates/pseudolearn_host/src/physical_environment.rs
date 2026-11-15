use crate::physical_error::{HostError, committed};
use crate::physical_request::Request;
use serde_json::{Value, json};
use std::ffi::OsString;

pub(crate) fn environment_name_is_valid(name: &str) -> bool {
    !name.is_empty() && !name.contains('=') && !name.contains('\0')
}

pub(crate) fn environment_get(request: &Request) -> Result<Value, HostError> {
    let name = request.text(0).map_err(|_| HostError::INVALID_REQUEST)?;
    if !environment_name_is_valid(name) {
        return Err(HostError::INVALID_REQUEST);
    }
    variable_reply(std::env::var_os(name))
}

pub(crate) fn variable_reply(value: Option<OsString>) -> Result<Value, HostError> {
    match value {
        None => Ok(committed("optional_text", Value::Null)),
        Some(raw) => raw
            .into_string()
            .map(|text| committed("optional_text", json!(text)))
            .map_err(|_| HostError::INVALID_UTF8),
    }
}
