use crate::cells::store_word;
use crate::context::AotRuntimeContext;
use crate::effect_channel::EffectChannel;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::trap::Trap;
use pseudolearn_runtime::{
    EFFECT_OPERATIONS, EffectOperation, EffectValueKind, Handle, HostReply, HostValue,
};
use std::io::Write;

pub(crate) const HEADER_WORDS: usize = 3;

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

pub(crate) struct EffectFrame<'words> {
    pub(crate) capability: u64,
    pub(crate) source_node: u32,
    result_class: u32,
    pub(crate) arguments: &'words [u64],
    cells: &'words [u64],
}

impl<'words> EffectFrame<'words> {
    pub(crate) fn split(operation: &EffectOperation, words: &'words [u64]) -> Result<Self, Trap> {
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

pub(crate) fn operation_at(descriptor: u32) -> Result<&'static EffectOperation, Trap> {
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

pub(crate) fn result_cell_count(operation: &EffectOperation) -> usize {
    operation.result_cell_count()
}

pub(crate) fn perform_effect(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    frame: &EffectFrame<'_>,
) -> Result<u64, Trap> {
    if !operation.effect {
        let receiver = Handle(u32::try_from(frame.capability).map_err(|_| internal())?);
        let mut roots = entry.roots()?;
        roots
            .try_reserve(frame.arguments.len().saturating_add(1))
            .map_err(|_| pseudolearn_runtime::MemoryError::Resource)?;
        roots.push(receiver);
        for (word, kind) in frame.arguments.iter().zip(operation.parameters) {
            if !EffectOperation::is_scalar(*kind) {
                roots.push(Handle(u32::try_from(*word).map_err(|_| internal())?));
            }
        }
        let call = pseudolearn_library::LocalJsonViewCall::new(
            receiver,
            operation,
            frame.arguments,
            &roots,
        );
        if let Some(value) = pseudolearn_library::local_json_view(&mut entry.engine.heap, call)? {
            store_local_view(entry, frame, value)?;
            return Ok(0);
        }
    }
    let arguments = decode_arguments(entry, operation, frame.arguments)?;
    let reply = request_reply(entry, operation, frame, arguments)?;
    store_reply(entry, operation, frame, &reply)?;
    echo_console(entry, operation, &reply, frame.arguments)?;
    Ok(0)
}

fn store_local_view(
    entry: &mut Entry<'_>,
    frame: &EffectFrame<'_>,
    value: u64,
) -> Result<(), Trap> {
    let [cell] = frame.cells else {
        return Err(internal());
    };
    store_word(entry, u32::try_from(*cell).map_err(|_| internal())?, value)
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

pub(crate) fn decode_arguments(
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
        return local_effect_reply(entry, capability, operation, &arguments);
    }
    let receiver = match operation.receiver {
        Some(_) => {
            Some(pseudolearn_runtime::capability_token(&entry.engine.heap, capability)?.into())
        }
        None => None,
    };
    let rejected = prepare_task_delivery(entry)?;
    let channel = &mut entry.engine.effects;
    let invocation = (receiver, arguments, frame.source_node);
    if rejected {
        return crate::task_effect_await::reject_for_limit(channel, operation, invocation);
    }
    host_reply(channel, operation, invocation)
}

fn host_reply(
    channel: &mut EffectChannel,
    operation: &EffectOperation,
    (receiver, arguments, source): (
        Option<pseudolearn_runtime::HostCapability>,
        Vec<HostValue>,
        u32,
    ),
) -> Result<HostReply, Trap> {
    if channel.cancels_next_effect() {
        let _ = pseudolearn_runtime::begin_host_effect(
            &mut channel.session,
            operation,
            (receiver, arguments),
            source,
        );
        channel.cancelled = true;
        channel.abort();
        return Err(Trap::exhausted_input());
    }
    pseudolearn_runtime::perform_host_effect(
        &mut channel.session,
        &mut channel.provider,
        operation,
        (receiver, arguments, source),
    )
    .map_err(|error| channel.reject(error))
}

fn prepare_task_delivery(entry: &mut Entry<'_>) -> Result<bool, Trap> {
    match entry.engine.tasks.as_deref_mut() {
        Some(tasks) => crate::task_effects::prepare_delivery(tasks, &mut entry.engine.effects)
            .map_err(|_| internal()),
        None => Ok(false),
    }
}

fn local_effect_reply(
    entry: &Entry<'_>,
    receiver: Handle,
    operation: &EffectOperation,
    arguments: &[HostValue],
) -> Result<HostReply, Trap> {
    local_reply(pseudolearn_library::LocalOperationRequest {
        heap: &entry.engine.heap,
        receiver,
        operation,
        arguments,
        maximum_json_depth: configured_json_depth(&entry.engine.effects),
    })
    .map_err(|trap| crate::effect_text_faults::with_text_position(trap, arguments))
}

fn local_reply(request: pseudolearn_library::LocalOperationRequest<'_>) -> Result<HostReply, Trap> {
    match pseudolearn_library::local_operation(request)? {
        Some(value) => Ok(HostReply::Committed(value)),
        None => pseudolearn_runtime::local_effect(
            request.heap,
            request.receiver,
            request.operation,
            request.arguments,
        )
        .map_err(Trap::from),
    }
}

fn configured_json_depth(effects: &EffectChannel) -> usize {
    effects
        .session()
        .tape()
        .identity
        .limits
        .get("max_json_depth")
        .and_then(|depth| usize::try_from(*depth).ok())
        .unwrap_or(pseudolearn_runtime::DEFAULT_JSON_DEPTH)
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
