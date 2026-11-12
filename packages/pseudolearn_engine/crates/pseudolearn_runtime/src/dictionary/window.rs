use crate::collection::storage::read_word;
use crate::collection::{CollectionWords, buffer, collection_length, number, read_value, validate};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_KEYS_OFFSET, DICTIONARY_OCCUPIED_OFFSET, DICTIONARY_USED_OFFSET,
};

pub fn dictionary_window(
    heap: &Heap,
    handle: Handle,
    range: (usize, usize),
) -> Result<Vec<(u64, CollectionWords)>, MemoryError> {
    validate(heap, handle)?;
    let length =
        usize::try_from(collection_length(heap, handle)?).map_err(|_| MemoryError::Internal)?;
    let (start, count) = range;
    if start > length {
        return Err(MemoryError::IndexOutOfRange);
    }
    let count = count.min(length.saturating_sub(start));
    if count == 0 {
        return Ok(Vec::new());
    }
    collect_window(heap, handle, (start, count))
}

fn collect_window(
    heap: &Heap,
    handle: Handle,
    range: (usize, usize),
) -> Result<Vec<(u64, CollectionWords)>, MemoryError> {
    let used = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    let occupied = buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?;
    let keys = buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?;
    let (start, count) = range;
    let mut ordinal = 0_usize;
    let mut result = Vec::new();
    result
        .try_reserve_exact(count)
        .map_err(|_| MemoryError::Resource)?;
    for position in 0..used {
        if read_word(heap, occupied, u64::from(position))? == 0 {
            continue;
        }
        if ordinal >= start {
            let key = read_word(heap, keys, u64::from(position))?;
            result.push((key, read_value(heap, handle, position)?));
        }
        ordinal = ordinal.checked_add(1).ok_or(MemoryError::Internal)?;
        if result.len() == count {
            break;
        }
    }
    Ok(result)
}
