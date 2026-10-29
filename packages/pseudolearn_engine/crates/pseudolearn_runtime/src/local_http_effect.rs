use crate::{Heap, HostReply, HostValue, IoError, MemoryError};
use pseudolearn_abi::IoErrorKind;

pub(crate) fn http_text_body(
    heap: &Heap,
    receiver: pseudolearn_abi::Handle,
) -> Result<HostReply, MemoryError> {
    let response = crate::http_values::decode_response(heap, receiver)?;
    match String::from_utf8(response.body) {
        Ok(text) => Ok(HostReply::Committed(HostValue::Text(text))),
        Err(_) => Ok(HostReply::failure(IoError::from_kind(
            IoErrorKind::InvalidUtf8,
        ))),
    }
}
