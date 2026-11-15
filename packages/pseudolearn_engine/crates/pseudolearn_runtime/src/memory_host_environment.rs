use crate::{DateTimeValue, HostEffectRequest, HostValue, IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;

pub(crate) fn environment_get(
    provider: &MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<HostValue, IoError> {
    let Some(HostValue::Text(name)) = request.arguments.first() else {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    };
    if !crate::environment_name_is_valid(name) {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    Ok(HostValue::OptionalText(
        provider.environment.get(name).cloned(),
    ))
}

pub(crate) fn local_now(provider: &mut MemoryHostProvider) -> Result<HostValue, IoError> {
    provider.time_nanos = provider
        .clocks
        .pop_front()
        .ok_or_else(IoError::end_of_file)?;
    let nanos = i64::try_from(provider.time_nanos)
        .map_err(|_| IoError::from_kind(IoErrorKind::TimedOut))?;
    Ok(HostValue::DateTime(DateTimeValue {
        nanos,
        offset_seconds: provider.offset_seconds,
    }))
}
