use crate::{DateTimeValue, Heap, MemoryError};
use pseudolearn_abi::{
    DATE_TIME_INSTANT_BYTES, DATE_TIME_PREFIX, DATE_TIME_PREFIX_BYTES, DATE_TIME_TOTAL_BYTES,
    Handle,
};

pub(crate) fn date_time_bytes(value: &DateTimeValue) -> Vec<u8> {
    let mut bytes = Vec::with_capacity(DATE_TIME_TOTAL_BYTES);
    bytes.extend_from_slice(&DATE_TIME_PREFIX);
    bytes.extend_from_slice(&value.nanos.to_le_bytes());
    bytes.extend_from_slice(&value.offset_seconds.to_le_bytes());
    bytes
}

pub(crate) fn new_date_time(
    heap: &mut Heap,
    value: &DateTimeValue,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    crate::new_bytes(heap, &date_time_bytes(value), roots)
}

pub(crate) fn decode_date_time(heap: &Heap, handle: Handle) -> Result<DateTimeValue, MemoryError> {
    let bytes = crate::bytes_content(heap, handle)?;
    if bytes.len() != DATE_TIME_TOTAL_BYTES
        || bytes.get(..DATE_TIME_PREFIX_BYTES) != Some(&DATE_TIME_PREFIX[..])
    {
        return Err(MemoryError::Internal);
    }
    let instant_end = DATE_TIME_PREFIX_BYTES + DATE_TIME_INSTANT_BYTES;
    let nanos = bytes
        .get(DATE_TIME_PREFIX_BYTES..instant_end)
        .and_then(|slice| <[u8; 8]>::try_from(slice).ok())
        .map(i64::from_le_bytes)
        .ok_or(MemoryError::Internal)?;
    let offset_seconds = bytes
        .get(instant_end..)
        .and_then(|slice| <[u8; 4]>::try_from(slice).ok())
        .map(i32::from_le_bytes)
        .ok_or(MemoryError::Internal)?;
    Ok(DateTimeValue {
        nanos,
        offset_seconds,
    })
}
