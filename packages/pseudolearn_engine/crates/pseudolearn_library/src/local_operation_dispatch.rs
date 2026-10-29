use super::{bytes_operation, json_operation, text_operation};
use pseudolearn_runtime::{EffectOperation, Handle, Heap, HostValue, MemoryError};

#[derive(Clone, Copy)]
pub struct LocalOperationRequest<'call> {
    pub heap: &'call Heap,
    pub receiver: Handle,
    pub operation: &'call EffectOperation,
    pub arguments: &'call [HostValue],
    pub maximum_json_depth: usize,
}

pub fn local_operation(
    request: LocalOperationRequest<'_>,
) -> Result<Option<HostValue>, MemoryError> {
    let LocalOperationRequest {
        heap,
        receiver,
        operation,
        arguments,
        maximum_json_depth,
    } = request;
    let receiver_value = operation
        .receiver
        .map(|kind| pseudolearn_runtime::decode_host_value(heap, kind, u64::from(receiver.0)))
        .transpose()?;
    match operation.family {
        "text" => text_operation(operation.identity, arguments),
        "bytes" => bytes_operation(receiver_value.as_ref(), operation.identity, arguments),
        "json" => json_operation(
            receiver_value.as_ref(),
            operation.identity,
            arguments,
            maximum_json_depth,
        ),
        "network" => crate::http_operations::http_operation(
            receiver_value.as_ref(),
            operation.identity,
            arguments,
        ),
        _ => Ok(None),
    }
}
