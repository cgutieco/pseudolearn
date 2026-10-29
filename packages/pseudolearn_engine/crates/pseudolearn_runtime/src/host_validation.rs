use crate::{HostEffectRequest, HostReply, HostValue, ReplayError};
use pseudolearn_abi::{EffectOperation, EffectValueKind};

pub(crate) fn reply(
    operation: &EffectOperation,
    request: &HostEffectRequest,
    reply: &HostReply,
) -> Result<(), ReplayError> {
    let valid = match reply {
        HostReply::Committed(value) => {
            value_kind(value) == operation.result
                && !matches!(value, HostValue::Capability(token) if Some(token) != request.result_capability.as_ref())
        }
        HostReply::Failed(error) => !error.uncertain && error.error().is_some(),
        HostReply::Uncertain(error) => {
            error.uncertain && error.error().is_some() && mutates(operation, request)
        }
    };
    if valid {
        Ok(())
    } else {
        Err(ReplayError::Divergence)
    }
}

pub(crate) fn value_kind(value: &HostValue) -> EffectValueKind {
    match value {
        HostValue::Integer(_) => EffectValueKind::Integer,
        HostValue::Real(_) => EffectValueKind::Real,
        HostValue::Boolean(_) => EffectValueKind::Boolean,
        HostValue::HttpMethod(_) => EffectValueKind::HttpMethod,
        HostValue::Text(_) => EffectValueKind::Text,
        HostValue::Bytes(_) => EffectValueKind::Bytes,
        HostValue::TextList(_) => EffectValueKind::TextList,
        HostValue::JsonValue(_) => EffectValueKind::JsonValue,
        HostValue::JsonResult(_) => EffectValueKind::JsonResult,
        HostValue::JsonKind(_) => EffectValueKind::JsonKind,
        HostValue::OptionalBoolean(_) => EffectValueKind::OptionalBoolean,
        HostValue::OptionalInteger(_) => EffectValueKind::OptionalInteger,
        HostValue::OptionalReal(_) => EffectValueKind::OptionalReal,
        HostValue::OptionalText(_) => EffectValueKind::OptionalText,
        HostValue::OptionalJsonValue(_) => EffectValueKind::OptionalJsonValue,
        HostValue::HttpRequest(_) => EffectValueKind::HttpRequest,
        HostValue::HttpResponse(_) => EffectValueKind::HttpResponse,
        HostValue::Capability(capability) => match capability.kind {
            0 => EffectValueKind::Console,
            1 => EffectValueKind::Arguments,
            2 => EffectValueKind::Directory,
            3 => EffectValueKind::File,
            4 => EffectValueKind::Clock,
            5 => EffectValueKind::Timer,
            _ => EffectValueKind::Network,
        },
    }
}

fn mutates(operation: &EffectOperation, request: &HostEffectRequest) -> bool {
    match operation.identity {
        "file_write_bytes" | "file_write_text" | "file_close" | "directory_close"
        | "console_write" => true,
        "network_send" => request
            .arguments
            .first()
            .and_then(|value| crate::http_values::request_from_value(value).ok())
            .is_some_and(|request| {
                !matches!(
                    request.method,
                    crate::HttpMethod::Get | crate::HttpMethod::Head
                )
            }),
        "file_open" => crate::effect_authority::mode_rights(request.arguments.last())
            .is_ok_and(|rights| rights.write),
        _ => false,
    }
}
