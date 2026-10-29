use crate::{Heap, HostReply, HostValue, JsonResultValue, MemoryError};
use pseudolearn_abi::{EffectOperation, EffectValueKind, Handle, VectorLayout};

pub fn decode_host_value(
    heap: &Heap,
    kind: EffectValueKind,
    word: u64,
) -> Result<HostValue, MemoryError> {
    match kind {
        EffectValueKind::Integer => Ok(HostValue::Integer(i64::from_ne_bytes(word.to_ne_bytes()))),
        EffectValueKind::Real => Ok(HostValue::Real(word)),
        EffectValueKind::Boolean => Ok(HostValue::Boolean(word != 0)),
        EffectValueKind::HttpMethod => Ok(HostValue::HttpMethod(
            crate::HttpMethod::from_tag(word).ok_or(MemoryError::Internal)?,
        )),
        EffectValueKind::JsonKind => Ok(HostValue::JsonKind(
            u8::try_from(word).map_err(|_| MemoryError::Internal)?,
        )),
        EffectValueKind::Text => Ok(HostValue::Text(
            crate::text_content(heap, handle(word)?)?.to_owned(),
        )),
        EffectValueKind::JsonValue => Ok(HostValue::JsonValue(
            crate::json_document::json_document_text(heap, handle(word)?)?,
        )),
        EffectValueKind::Bytes => Ok(HostValue::Bytes(crate::bytes_content(heap, handle(word)?)?)),
        EffectValueKind::TextList => Ok(HostValue::TextList(text_list(heap, handle(word)?)?)),
        EffectValueKind::HttpRequest => Ok(HostValue::HttpRequest(
            crate::http_values::decode_request(heap, handle(word)?)?,
        )),
        EffectValueKind::HttpResponse => Ok(HostValue::HttpResponse(
            crate::http_values::decode_response(heap, handle(word)?)?,
        )),
        _ => Ok(HostValue::Capability(
            crate::capability_token(heap, handle(word)?)?.into(),
        )),
    }
}

pub fn host_reply_words(
    heap: &mut Heap,
    reply: &HostReply,
    signature: (&EffectOperation, u32),
    roots: &[Handle],
) -> Result<Vec<u64>, MemoryError> {
    let (operation, type_identity) = signature;
    match reply {
        HostReply::Committed(value) => {
            if let Some(words) = encode_variant(heap, value, (operation, roots))? {
                return Ok(words);
            }
            let word = encode_value(heap, value, (roots, type_identity))?;
            if !operation.fallible {
                return Ok(vec![word]);
            }
            let reference = !matches!(
                operation.result,
                EffectValueKind::Integer | EffectValueKind::Boolean
            );
            Ok(if reference {
                vec![0, 0, word]
            } else {
                vec![0, word, 0]
            })
        }
        HostReply::Failed(error) | HostReply::Uncertain(error) => {
            if !operation.fallible || error.error().is_none() {
                return Err(MemoryError::Internal);
            }
            let handle = crate::new_text(heap, &error.code, false, roots)?;
            Ok(vec![1, u64::from(error.uncertain), u64::from(handle.0)])
        }
    }
}

fn encode_variant(
    heap: &mut Heap,
    value: &HostValue,
    allocation: (&EffectOperation, &[Handle]),
) -> Result<Option<Vec<u64>>, MemoryError> {
    let (operation, roots) = allocation;
    let words = match value {
        HostValue::OptionalBoolean(Some(value)) => vec![1, u64::from(*value)],
        HostValue::OptionalBoolean(None) => vec![0, 0],
        HostValue::OptionalInteger(Some(value)) => vec![1, u64::from_ne_bytes(value.to_ne_bytes())],
        HostValue::OptionalInteger(None) => vec![0, 0],
        HostValue::OptionalReal(Some(value)) => vec![1, *value],
        HostValue::OptionalReal(None) => vec![0, 0],
        HostValue::OptionalText(Some(value)) => {
            vec![u64::from(crate::new_text(heap, value, false, roots)?.0)]
        }
        HostValue::OptionalText(None) | HostValue::OptionalJsonValue(None) => vec![0],
        HostValue::OptionalJsonValue(Some(value)) => {
            vec![u64::from(
                crate::json_document::new_json_document(heap, value, roots)?.0,
            )]
        }
        HostValue::JsonResult(JsonResultValue::Value(value)) => {
            let document = crate::json_document::new_json_document(heap, value, roots)?;
            vec![0, 0, 0, 0, u64::from(document.0)]
        }
        HostValue::JsonResult(JsonResultValue::Error(error)) => vec![
            1,
            u64::try_from(json_error_ordinal(&error.code)?).map_err(|_| MemoryError::Internal)?,
            u64::try_from(error.line).map_err(|_| MemoryError::Internal)?,
            u64::try_from(error.column).map_err(|_| MemoryError::Internal)?,
            0,
        ],
        _ => return Ok(None),
    };
    if operation.result_cell_count() != words.len() {
        return Err(MemoryError::Internal);
    }
    Ok(Some(words))
}

fn json_error_ordinal(code: &str) -> Result<i64, MemoryError> {
    match code {
        "invalidSyntax" => Ok(0),
        "unexpectedEnd" => Ok(1),
        "duplicateKey" => Ok(2),
        "depthExceeded" => Ok(3),
        "invalidEscape" => Ok(4),
        "trailingContent" => Ok(5),
        _ => Err(MemoryError::Internal),
    }
}

fn encode_value(
    heap: &mut Heap,
    value: &HostValue,
    allocation: (&[Handle], u32),
) -> Result<u64, MemoryError> {
    let (roots, type_identity) = allocation;
    let value = match value {
        HostValue::Integer(value) => return Ok(u64::from_ne_bytes(value.to_ne_bytes())),
        HostValue::HttpMethod(value) => return Ok(value.to_tag()),
        HostValue::JsonKind(value) => return Ok(u64::from(*value)),
        HostValue::Real(value) => return Ok(*value),
        HostValue::Boolean(value) => return Ok(u64::from(*value)),
        HostValue::Text(text) => crate::new_text(heap, text, false, roots)?,
        HostValue::JsonValue(text) => crate::json_document::new_json_document(heap, text, roots)?,
        HostValue::Bytes(bytes) => crate::new_bytes(heap, bytes, roots)?,
        HostValue::HttpRequest(request) => {
            let bytes = crate::http_values::request_bytes(request)?;
            crate::new_bytes(heap, &bytes, roots)?
        }
        HostValue::HttpResponse(response) => {
            let bytes = crate::http_values::response_bytes(response)?;
            crate::new_bytes(heap, &bytes, roots)?
        }
        HostValue::JsonResult(_) | HostValue::OptionalBoolean(_) => {
            return Err(MemoryError::Internal);
        }
        HostValue::OptionalInteger(_)
        | HostValue::OptionalReal(_)
        | HostValue::OptionalText(_)
        | HostValue::OptionalJsonValue(_) => return Err(MemoryError::Internal),
        HostValue::Capability(token) => crate::new_capability(
            heap,
            token.token().map_err(|_| MemoryError::Internal)?,
            roots,
        )?,
        HostValue::TextList(values) => text_vector(heap, values, (roots, type_identity))?,
    };
    Ok(u64::from(value.0))
}

fn text_list(heap: &Heap, handle: Handle) -> Result<Vec<String>, MemoryError> {
    let layout = crate::collection_layout(heap, handle)?;
    if layout.scalar_words != 0 || layout.reference_words != 1 {
        return Err(MemoryError::Internal);
    }
    let length = crate::collection_length(heap, handle)?;
    (0..length)
        .map(|index| {
            let index = i64::from(index);
            let value = crate::vector_get(heap, handle, index)?;
            let text = value
                .references
                .first()
                .copied()
                .ok_or(MemoryError::Internal)?;
            crate::text_content(heap, text).map(str::to_owned)
        })
        .collect()
}

fn text_vector(
    heap: &mut Heap,
    texts: &[String],
    allocation: (&[Handle], u32),
) -> Result<Handle, MemoryError> {
    let (roots, type_identity) = allocation;
    let layout = VectorLayout {
        scalar_words: 0,
        reference_words: 1,
        type_identity,
    };
    let vector = crate::new_vector(heap, layout, roots)?;
    let mut retained = roots.to_vec();
    retained.push(vector);
    for (index, text) in texts.iter().enumerate() {
        let text = crate::new_text(heap, text, false, &retained)?;
        crate::vector_insert(
            heap,
            vector,
            (
                i64::try_from(index).map_err(|_| MemoryError::Resource)?,
                crate::CollectionWords {
                    scalars: Vec::new(),
                    references: vec![text],
                },
            ),
            &retained,
        )?;
    }
    Ok(vector)
}

fn handle(word: u64) -> Result<Handle, MemoryError> {
    u32::try_from(word)
        .map(Handle)
        .map_err(|_| MemoryError::Internal)
}
