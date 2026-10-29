use crate::{Heap, HostValue, HttpRequestValue, HttpResponseValue, MemoryError};
use pseudolearn_abi::{HTTP_REQUEST_PREFIX, HTTP_RESPONSE_PREFIX, HTTP_VALUE_PREFIX_BYTES, Handle};

pub(crate) fn request_bytes(request: &HttpRequestValue) -> Result<Vec<u8>, MemoryError> {
    encode(&HTTP_REQUEST_PREFIX, request)
}

pub(crate) fn response_bytes(response: &HttpResponseValue) -> Result<Vec<u8>, MemoryError> {
    encode(&HTTP_RESPONSE_PREFIX, response)
}

pub(crate) fn decode_request(heap: &Heap, handle: Handle) -> Result<HttpRequestValue, MemoryError> {
    let bytes = crate::bytes_content(heap, handle)?;
    decode(&HTTP_REQUEST_PREFIX, &bytes)
}

pub(crate) fn decode_response(
    heap: &Heap,
    handle: Handle,
) -> Result<HttpResponseValue, MemoryError> {
    let bytes = crate::bytes_content(heap, handle)?;
    decode(&HTTP_RESPONSE_PREFIX, &bytes)
}

pub(crate) fn request_from_value(value: &HostValue) -> Result<&HttpRequestValue, MemoryError> {
    match value {
        HostValue::HttpRequest(request) => Ok(request),
        _ => Err(MemoryError::Internal),
    }
}

fn encode<SerializedValue: serde::Serialize>(
    prefix: &[u8; HTTP_VALUE_PREFIX_BYTES],
    value: &SerializedValue,
) -> Result<Vec<u8>, MemoryError> {
    let encoded = serde_json::to_vec(value).map_err(|_| MemoryError::Internal)?;
    let mut bytes = Vec::new();
    bytes
        .try_reserve(prefix.len().saturating_add(encoded.len()))
        .map_err(|_| MemoryError::Resource)?;
    bytes.extend_from_slice(prefix);
    bytes.extend_from_slice(&encoded);
    Ok(bytes)
}

fn decode<DecodedValue: serde::de::DeserializeOwned>(
    prefix: &[u8; HTTP_VALUE_PREFIX_BYTES],
    bytes: &[u8],
) -> Result<DecodedValue, MemoryError> {
    if bytes.get(..HTTP_VALUE_PREFIX_BYTES) != Some(&prefix[..]) {
        return Err(MemoryError::Internal);
    }
    let document = bytes
        .get(HTTP_VALUE_PREFIX_BYTES..)
        .ok_or(MemoryError::Internal)?;
    serde_json::from_slice(document).map_err(|_| MemoryError::Internal)
}
