use crate::cells::store_word;
use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::trap::Trap;
use pseudolearn_runtime::{
    EFFECT_OPERATIONS, EffectOperation, EffectValueKind, Handle, HostReply, HostValue,
};
use std::io::Write;

const HEADER_WORDS: usize = 3;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_effect_call(
    context: *mut AotRuntimeContext,
    site: u32,
    descriptor: u32,
    buffer: *const u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let operation = operation_at(descriptor)?;
        let count = HEADER_WORDS
            .saturating_add(operation.parameters.len())
            .saturating_add(result_cell_count(operation));
        let words = borrow_slice(buffer, count).ok_or_else(internal)?;
        perform_effect(entry, operation, &EffectFrame::split(operation, words)?)
    })
}

struct EffectFrame<'words> {
    capability: u64,
    source_node: u32,
    result_class: u32,
    arguments: &'words [u64],
    cells: &'words [u64],
}

impl<'words> EffectFrame<'words> {
    fn split(operation: &EffectOperation, words: &'words [u64]) -> Result<Self, Trap> {
        let [capability, source_node, result_class, rest @ ..] = words else {
            return Err(internal());
        };
        let (arguments, cells) = rest
            .split_at_checked(operation.parameters.len())
            .ok_or_else(internal)?;
        Ok(Self {
            capability: *capability,
            source_node: u32::try_from(*source_node).map_err(|_| internal())?,
            result_class: u32::try_from(*result_class).map_err(|_| internal())?,
            arguments,
            cells,
        })
    }
}

fn internal() -> Trap {
    Trap::named("internalFault")
}

fn operation_at(descriptor: u32) -> Result<&'static EffectOperation, Trap> {
    usize::try_from(descriptor)
        .ok()
        .and_then(|index| EFFECT_OPERATIONS.get(index))
        .ok_or_else(internal)
}

pub fn effect_operation_index(identity: &str) -> Option<u32> {
    EFFECT_OPERATIONS
        .iter()
        .position(|operation| operation.identity == identity)
        .and_then(|index| u32::try_from(index).ok())
}

pub fn effect_operation_cells(identity: &str) -> Option<(usize, usize)> {
    EFFECT_OPERATIONS
        .iter()
        .find(|operation| operation.identity == identity)
        .map(|operation| (operation.parameters.len(), result_cell_count(operation)))
}

fn result_cell_count(operation: &EffectOperation) -> usize {
    if operation.fallible { 3 } else { 1 }
}

fn perform_effect(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    frame: &EffectFrame<'_>,
) -> Result<u64, Trap> {
    let arguments = decode_arguments(entry, operation, frame.arguments)?;
    let reply = request_reply(entry, operation, frame, arguments)?;
    store_reply(entry, operation, frame, &reply)?;
    echo_console(entry, operation, &reply, frame.arguments)?;
    Ok(0)
}

fn store_reply(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    frame: &EffectFrame<'_>,
    reply: &HostReply,
) -> Result<(), Trap> {
    let roots = entry.roots()?;
    let results = pseudolearn_runtime::host_reply_words(
        &mut entry.engine.heap,
        reply,
        (operation, frame.result_class),
        &roots,
    )?;
    for (cell, word) in frame.cells.iter().zip(results) {
        let cell = u32::try_from(*cell).map_err(|_| internal())?;
        store_word(entry, cell, word)?;
    }
    Ok(())
}

fn decode_arguments(
    entry: &Entry<'_>,
    operation: &EffectOperation,
    words: &[u64],
) -> Result<Vec<HostValue>, Trap> {
    operation
        .parameters
        .iter()
        .zip(words)
        .map(|(kind, word)| {
            pseudolearn_runtime::decode_host_value(&entry.engine.heap, *kind, *word)
                .map_err(Trap::from)
        })
        .collect()
}

fn request_reply(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    frame: &EffectFrame<'_>,
    arguments: Vec<HostValue>,
) -> Result<HostReply, Trap> {
    let capability = Handle(u32::try_from(frame.capability).map_err(|_| internal())?);
    if !operation.effect {
        return Ok(pseudolearn_runtime::local_effect(
            &entry.engine.heap,
            capability,
            operation,
            &arguments,
        )?);
    }
    let receiver = match operation.receiver {
        Some(_) => Some(pseudolearn_runtime::capability_token(&entry.engine.heap, capability)?.into()),
        None => None,
    };
    let channel = &mut entry.engine.effects;
    if channel.cancels_next_effect() {
        let _ = pseudolearn_runtime::begin_host_effect(
            &mut channel.session,
            operation,
            (receiver, arguments),
            frame.source_node,
        );
        channel.cancelled = true;
        channel.abort();
        return Err(Trap::exhausted_input());
    }
    pseudolearn_runtime::perform_host_effect(
        &mut channel.session,
        &mut channel.provider,
        operation,
        (receiver, arguments, frame.source_node),
    )
    .map_err(|error| channel.reject(error))
}

fn echo_console(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    reply: &HostReply,
    words: &[u64],
) -> Result<(), Trap> {
    if operation.identity != "console_write" || !matches!(reply, HostReply::Committed(_)) {
        return Ok(());
    }
    let (Some(EffectValueKind::Text), Some(word)) = (operation.parameters.first(), words.first())
    else {
        return Err(internal());
    };
    let handle = Handle(u32::try_from(*word).map_err(|_| internal())?);
    let text = pseudolearn_runtime::text_content(&entry.engine.heap, handle)?.to_owned();
    entry
        .engine
        .streams
        .output
        .write_all(text.as_bytes())
        .map_err(|_| Trap::named("resourceLimit"))
}
