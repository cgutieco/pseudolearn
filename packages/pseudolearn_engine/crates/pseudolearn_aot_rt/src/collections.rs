use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::trap::Trap;
use pseudolearn_abi::{CollectionCommand, DictionaryKeyKind, VectorLayout};
use pseudolearn_library::{CollectionRequest, collection_operation};

pub const COLLECTION_PACKET_WORDS: usize = 6;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_collection(
    context: *mut AotRuntimeContext,
    site: u32,
    command: u32,
    packet: *const u64,
) -> u32 {
    let header = borrow_slice(packet, COLLECTION_PACKET_WORDS);
    run_entry(context, site, |entry| {
        execute(entry, command, (packet, header))
    })
}

fn execute(
    entry: &mut Entry<'_>,
    command: u32,
    packet: (*const u64, Option<&[u64]>),
) -> Result<u64, Trap> {
    let header = packet.1.ok_or_else(|| Trap::named("internalFault"))?;
    let count = usize::try_from(*header.first().ok_or_else(|| Trap::named("internalFault"))?)
        .map_err(|_| Trap::named("internalFault"))?;
    if count > usize::from(u16::MAX) {
        return Err(Trap::named("internalFault"));
    }
    let words = borrow_slice(
        packet.0,
        count
            .checked_add(COLLECTION_PACKET_WORDS)
            .ok_or_else(|| Trap::named("internalFault"))?,
    )
    .ok_or_else(|| Trap::named("internalFault"))?;
    let request = request(header, words, command)?;
    let cells = u64::from(request.layout.scalar_words)
        .checked_add(u64::from(request.layout.reference_words))
        .and_then(|count| count.checked_add(2))
        .ok_or_else(|| Trap::named("resourceLimit"))?;
    let allocating = matches!(
        request.command,
        CollectionCommand::New
            | CollectionCommand::Store
            | CollectionCommand::Insert
            | CollectionCommand::Remove
    );
    let roots = if allocating {
        entry.allocation_roots(cells)?
    } else {
        Vec::new()
    };
    collection_operation(&mut entry.engine.heap, &request, &roots)
        .map_err(|error| fault(entry, &request, error))
}

fn number(header: &[u64], index: usize) -> Result<u32, Trap> {
    header
        .get(index)
        .copied()
        .and_then(|word| u32::try_from(word).ok())
        .ok_or_else(|| Trap::named("internalFault"))
}

fn request<'words>(
    header: &[u64],
    words: &'words [u64],
    command: u32,
) -> Result<CollectionRequest<'words>, Trap> {
    Ok(CollectionRequest {
        command: CollectionCommand::from_code(command)
            .ok_or_else(|| Trap::named("internalFault"))?,
        layout: VectorLayout {
            scalar_words: number(header, 1)?,
            reference_words: number(header, 2)?,
            type_identity: number(header, 3)?,
        },
        key: match number(header, 4)? {
            u32::MAX => None,
            code => Some(
                DictionaryKeyKind::from_code(code).ok_or_else(|| Trap::named("internalFault"))?,
            ),
        },
        leaf: number(header, 5)?,
        arguments: words
            .get(COLLECTION_PACKET_WORDS..)
            .ok_or_else(|| Trap::named("internalFault"))?,
    })
}

fn fault(
    entry: &Entry<'_>,
    request: &CollectionRequest<'_>,
    error: pseudolearn_runtime::MemoryError,
) -> Trap {
    let trap = Trap::from(error);
    if error != pseudolearn_runtime::MemoryError::IndexOutOfRange {
        return trap;
    }
    let handle = request
        .arguments
        .first()
        .copied()
        .and_then(|word| u32::try_from(word).ok())
        .map(pseudolearn_runtime::Handle);
    let size = handle
        .and_then(|handle| pseudolearn_runtime::collection_length(&entry.engine.heap, handle).ok())
        .unwrap_or(0);
    let index = request
        .arguments
        .get(1)
        .copied()
        .map(|word| i64::from_ne_bytes(word.to_ne_bytes()))
        .unwrap_or(0);
    trap.argument("index", index).argument("size", size)
}
