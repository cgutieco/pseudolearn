use crate::{HostEffectRequest, HostValue, IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;

pub(crate) fn write_error(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<HostValue, IoError> {
    let text = crate::memory_host::text(request, 0)?;
    provider.error_output.push_str(text);
    let length =
        i64::try_from(text.len()).map_err(|_| IoError::from_kind(IoErrorKind::Interrupted))?;
    Ok(HostValue::Integer(length))
}

pub(crate) fn set_exit_code(request: &HostEffectRequest) -> Result<HostValue, IoError> {
    crate::exit_code_argument(request).map(|code| HostValue::Integer(i64::from(code)))
}
