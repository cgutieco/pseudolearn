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
        HostValue::Boolean(_) => EffectValueKind::Boolean,
        HostValue::Text(_) => EffectValueKind::Text,
        HostValue::Bytes(_) => EffectValueKind::Bytes,
        HostValue::TextList(_) => EffectValueKind::TextList,
        HostValue::Capability(capability) => match capability.kind {
            0 => EffectValueKind::Console,
            1 => EffectValueKind::Arguments,
            2 => EffectValueKind::Directory,
            3 => EffectValueKind::File,
            4 => EffectValueKind::Clock,
            _ => EffectValueKind::Timer,
        },
    }
}

fn mutates(operation: &EffectOperation, request: &HostEffectRequest) -> bool {
    match operation.identity {
        "file_write_bytes" | "file_write_text" | "file_close" | "directory_close"
        | "console_write" => true,
        "file_open" => crate::effect_authority::mode_rights(request.arguments.last())
            .is_ok_and(|rights| rights.write),
        _ => false,
    }
}
