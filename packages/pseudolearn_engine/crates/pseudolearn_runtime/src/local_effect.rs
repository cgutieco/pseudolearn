use crate::{Heap, HostReply, HostValue, IoError, MemoryError};
use pseudolearn_abi::{EffectOperation, Handle, IoErrorKind};

pub fn local_effect(
    heap: &Heap,
    receiver: Handle,
    operation: &EffectOperation,
    arguments: &[HostValue],
) -> Result<HostReply, MemoryError> {
    let value = match operation.identity {
        "bytes_new" => HostValue::Bytes(Vec::new()),
        "bytes_length" => HostValue::Integer(
            i64::try_from(crate::bytes_length(heap, receiver)?)
                .map_err(|_| MemoryError::Resource)?,
        ),
        "bytes_at" => {
            let Some(HostValue::Integer(index)) = arguments.first() else {
                return Err(MemoryError::Internal);
            };
            HostValue::Integer(i64::from(crate::bytes_at(heap, receiver, *index)?))
        }
        "bytes_utf8" => {
            let bytes = crate::bytes_content(heap, receiver)?;
            match String::from_utf8(bytes) {
                Ok(text) => HostValue::Text(text),
                Err(_) => {
                    return Ok(HostReply::failure(IoError::from_kind(
                        IoErrorKind::InvalidUtf8,
                    )));
                }
            }
        }
        _ => return Err(MemoryError::Internal),
    };
    Ok(HostReply::Committed(value))
}
