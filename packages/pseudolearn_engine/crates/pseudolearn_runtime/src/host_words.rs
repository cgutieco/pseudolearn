use crate::{Heap, HostReply, HostValue, MemoryError};
use pseudolearn_abi::{EffectOperation, EffectValueKind, Handle, VectorLayout};

pub fn decode_host_value(
    heap: &Heap,
    kind: EffectValueKind,
    word: u64,
) -> Result<HostValue, MemoryError> {
    match kind {
        EffectValueKind::Integer => Ok(HostValue::Integer(i64::from_ne_bytes(word.to_ne_bytes()))),
        EffectValueKind::Boolean => Ok(HostValue::Boolean(word != 0)),
        EffectValueKind::Text => Ok(HostValue::Text(
            crate::text_content(heap, handle(word)?)?.to_owned(),
        )),
        EffectValueKind::Bytes => Ok(HostValue::Bytes(crate::bytes_content(heap, handle(word)?)?)),
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

fn encode_value(
    heap: &mut Heap,
    value: &HostValue,
    allocation: (&[Handle], u32),
) -> Result<u64, MemoryError> {
    let (roots, type_identity) = allocation;
    let value = match value {
        HostValue::Integer(value) => return Ok(u64::from_ne_bytes(value.to_ne_bytes())),
        HostValue::Boolean(value) => return Ok(u64::from(*value)),
        HostValue::Text(text) => crate::new_text(heap, text, false, roots)?,
        HostValue::Bytes(bytes) => crate::new_bytes(heap, bytes, roots)?,
        HostValue::Capability(token) => crate::new_capability(
            heap,
            token.token().map_err(|_| MemoryError::Internal)?,
            roots,
        )?,
        HostValue::TextList(values) => text_vector(heap, values, (roots, type_identity))?,
    };
    Ok(u64::from(value.0))
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
