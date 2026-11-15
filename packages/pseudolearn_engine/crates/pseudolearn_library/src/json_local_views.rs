#![forbid(unsafe_code)]

use pseudolearn_runtime::{
    EffectOperation, EffectValueKind, Handle, Heap, MemoryError, json_document,
};

pub struct LocalJsonViewCall<'call> {
    receiver: Handle,
    operation: &'call EffectOperation,
    arguments: &'call [u64],
    roots: &'call [Handle],
}

impl<'call> LocalJsonViewCall<'call> {
    pub fn new(
        receiver: Handle,
        operation: &'call EffectOperation,
        arguments: &'call [u64],
        roots: &'call [Handle],
    ) -> Self {
        Self {
            receiver,
            operation,
            arguments,
            roots,
        }
    }
}

pub fn local_json_view(
    heap: &mut Heap,
    call: LocalJsonViewCall<'_>,
) -> Result<Option<u64>, MemoryError> {
    let LocalJsonViewCall {
        receiver,
        operation,
        arguments,
        roots,
    } = call;
    if operation.family != "json"
        || operation.receiver != Some(EffectValueKind::JsonValue)
        || operation.result != EffectValueKind::OptionalJsonValue
    {
        return Ok(None);
    }
    let view = match operation.identity {
        "json_element" => element_view(heap, receiver, arguments, roots)?,
        "json_field" => field_view(heap, receiver, arguments, roots)?,
        _ => return Ok(None),
    };
    Ok(Some(view.map_or(0, |handle| u64::from(handle.0))))
}

fn element_view(
    heap: &mut Heap,
    receiver: Handle,
    arguments: &[u64],
    roots: &[Handle],
) -> Result<Option<Handle>, MemoryError> {
    let [index] = arguments else {
        return Err(MemoryError::Internal);
    };
    let index = i64::from_ne_bytes(index.to_ne_bytes());
    json_document::json_element_view(heap, receiver, index, roots)
}

fn field_view(
    heap: &mut Heap,
    receiver: Handle,
    arguments: &[u64],
    roots: &[Handle],
) -> Result<Option<Handle>, MemoryError> {
    let [name] = arguments else {
        return Err(MemoryError::Internal);
    };
    let name = u32::try_from(*name)
        .map(Handle)
        .map_err(|_| MemoryError::Internal)?;
    let name = pseudolearn_runtime::text_content(heap, name)?.to_owned();
    json_document::json_field_view(heap, receiver, &name, roots)
}
