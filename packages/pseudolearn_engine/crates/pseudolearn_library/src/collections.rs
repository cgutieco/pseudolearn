use pseudolearn_runtime::{
    self as runtime, CollectionCommand, CollectionWords, DictionaryKeyKind, DictionaryLayout,
    Handle, Heap, MemoryError, VectorLayout,
};

#[derive(Clone, Debug)]
pub struct CollectionRequest<'arguments> {
    pub command: CollectionCommand,
    pub layout: VectorLayout,
    pub key: Option<DictionaryKeyKind>,
    pub leaf: u32,
    pub arguments: &'arguments [u64],
}

pub fn collection_operation(
    heap: &mut Heap,
    request: &CollectionRequest<'_>,
    roots: &[Handle],
) -> Result<u64, MemoryError> {
    if request.command == CollectionCommand::New {
        return create(heap, request, roots);
    }
    let handle = Handle(u32::try_from(word(request, 0)?).map_err(|_| MemoryError::Internal)?);
    match request.command {
        CollectionCommand::Length => runtime::collection_length(heap, handle).map(u64::from),
        CollectionCommand::Version => runtime::collection_version(heap, handle).map(u64::from),
        CollectionCommand::Check => {
            runtime::collection_check_version(
                heap,
                handle,
                u32::try_from(word(request, 1)?).map_err(|_| MemoryError::CollectionModified)?,
            )?;
            Ok(0)
        }
        CollectionCommand::Load => {
            runtime::collection_load_word(heap, handle, (integer(word(request, 1)?), request.leaf))
        }
        CollectionCommand::Key => runtime::collection_key(heap, handle, integer(word(request, 1)?)),
        CollectionCommand::Lookup => {
            Ok(runtime::dictionary_lookup(heap, handle, word(request, 1)?)?
                .map_or(u64::MAX, u64::from))
        }
        CollectionCommand::Next => next(heap, handle, word(request, 1)?),
        CollectionCommand::ArrayLength => array_length(heap, handle),
        _ => modify(heap, request, handle, roots),
    }
}

fn modify(
    heap: &mut Heap,
    request: &CollectionRequest<'_>,
    handle: Handle,
    roots: &[Handle],
) -> Result<u64, MemoryError> {
    let key = word(request, 1)?;
    if request.command == CollectionCommand::Remove {
        if runtime::collection_is_dictionary(heap, handle)? {
            runtime::dictionary_remove(heap, handle, key)?;
        } else {
            runtime::vector_remove(heap, handle, integer(key))?;
        }
        return Ok(0);
    }
    let value = payload(request)?;
    match request.command {
        CollectionCommand::Insert => {
            runtime::vector_insert(heap, handle, (integer(key), value), roots)?
        }
        CollectionCommand::Store if runtime::collection_is_dictionary(heap, handle)? => {
            runtime::dictionary_set(heap, handle, (key, value), roots)?
        }
        CollectionCommand::Store => runtime::vector_set(heap, handle, (integer(key), value))?,
        _ => return Err(MemoryError::Internal),
    }
    Ok(0)
}

fn payload(request: &CollectionRequest<'_>) -> Result<CollectionWords, MemoryError> {
    let scalar_end = usize::try_from(request.layout.scalar_words)
        .ok()
        .and_then(|count| count.checked_add(2))
        .ok_or(MemoryError::Internal)?;
    let expected = scalar_end
        .checked_add(
            usize::try_from(request.layout.reference_words).map_err(|_| MemoryError::Internal)?,
        )
        .ok_or(MemoryError::Internal)?;
    if request.arguments.len() != expected {
        return Err(MemoryError::Internal);
    }
    let scalars = request
        .arguments
        .get(2..scalar_end)
        .ok_or(MemoryError::Internal)?
        .to_vec();
    let references = request
        .arguments
        .get(scalar_end..)
        .ok_or(MemoryError::Internal)?
        .iter()
        .map(|word| {
            u32::try_from(*word)
                .map(Handle)
                .map_err(|_| MemoryError::Internal)
        })
        .collect::<Result<_, _>>()?;
    Ok(CollectionWords {
        scalars,
        references,
    })
}

fn word(request: &CollectionRequest<'_>, index: usize) -> Result<u64, MemoryError> {
    request
        .arguments
        .get(index)
        .copied()
        .ok_or(MemoryError::Internal)
}

fn integer(word: u64) -> i64 {
    i64::from_ne_bytes(word.to_ne_bytes())
}

fn next(heap: &Heap, handle: Handle, cursor: u64) -> Result<u64, MemoryError> {
    let cursor = u32::try_from(cursor).map_err(|_| MemoryError::Internal)?;
    Ok(runtime::dictionary_next(heap, handle, cursor)?
        .map_or(u64::MAX, |(next, _, _)| u64::from(next.saturating_sub(1))))
}

fn array_length(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    let dimensions = runtime::array_dimensions(heap, handle)?;
    if dimensions.len() != 1 {
        return Err(MemoryError::Internal);
    }
    dimensions.first().copied().ok_or(MemoryError::Internal)
}

fn create(
    heap: &mut Heap,
    request: &CollectionRequest<'_>,
    roots: &[Handle],
) -> Result<u64, MemoryError> {
    let handle = if let Some(key) = request.key {
        runtime::new_dictionary(
            heap,
            DictionaryLayout {
                value: request.layout,
                key,
            },
            roots,
        )?
    } else {
        runtime::new_vector(heap, request.layout, roots)?
    };
    Ok(u64::from(handle.0))
}
