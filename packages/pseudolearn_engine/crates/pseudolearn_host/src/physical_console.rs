use crate::physical_error::{HostError, committed};
use crate::physical_request::{Argument, Request};
use serde_json::{Value, json};

const MAXIMUM_EXIT_CODE: i64 = 255;

pub(crate) fn write_error(request: &Request) -> Result<Value, HostError> {
    let text = request.text(0).map_err(|_| HostError::INVALID_REQUEST)?;
    let length = i64::try_from(text.len()).map_err(|_| HostError::INTERRUPTED)?;
    Ok(committed("integer", json!(length)))
}

pub(crate) fn set_exit_code(request: &Request) -> Result<Value, HostError> {
    let Some(Argument::Integer(code)) = request.arguments.first() else {
        return Err(HostError::INVALID_REQUEST);
    };
    if !(0..=MAXIMUM_EXIT_CODE).contains(code) {
        return Err(HostError::INVALID_REQUEST);
    }
    Ok(committed("integer", json!(code)))
}
