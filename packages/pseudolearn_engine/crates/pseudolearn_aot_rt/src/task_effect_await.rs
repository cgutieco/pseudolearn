use crate::context::AotRuntimeContext;
use crate::effects::{
    EffectFrame, HEADER_WORDS, decode_arguments, operation_at, perform_effect, result_cell_count,
};
use crate::guard::{Entry, borrow_slice};
use crate::task_blocking::{Step, blocking_entry};
use crate::task_state::AwaitedEffect;
use crate::trap::Trap;
use pseudolearn_runtime::{EffectOperation, Handle, HostEffectRequest};

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_effect_await(
    context: *mut AotRuntimeContext,
    site: u32,
    descriptor: u32,
    buffer: *const u64,
) -> u32 {
    blocking_entry(context, site, |entry| await_step(entry, descriptor, buffer))
}

fn await_step(entry: &mut Entry<'_>, descriptor: u32, buffer: *const u64) -> Result<Step, Trap> {
    let operation = operation_at(descriptor)?;
    let count = HEADER_WORDS
        .saturating_add(operation.parameters.len())
        .saturating_add(result_cell_count(operation));
    let words = borrow_slice(buffer, count).ok_or_else(|| Trap::named("internalFault"))?;
    let frame = EffectFrame::split(operation, words)?;
    let ready = entry
        .engine
        .tasks
        .as_deref()
        .is_none_or(|tasks| !operation.effect || tasks.delivering.contains_key(&tasks.current));
    if ready {
        perform_effect(entry, operation, &frame)?;
        return Ok(Step::Done(0));
    }
    register(entry, operation, &frame)?;
    Ok(Step::Block)
}

fn register(
    entry: &mut Entry<'_>,
    operation: &'static EffectOperation,
    frame: &EffectFrame<'_>,
) -> Result<(), Trap> {
    let arguments = decode_arguments(entry, operation, frame.arguments)?;
    let receiver = receiver_of(entry, operation, frame)?;
    let tasks = entry.engine.tasks_mut()?;
    tasks.vm_sequence = tasks.vm_sequence.saturating_add(1);
    let sequence = tasks.vm_sequence;
    let current = tasks.current;
    tasks.pending_effects.insert(
        current,
        AwaitedEffect {
            sequence,
            task: current,
            request: HostEffectRequest {
                effect_seq: sequence,
                operation: operation.identity.to_owned(),
                receiver,
                arguments,
                result_capability: None,
                source_node_id: frame.source_node,
            },
        },
    );
    tasks
        .agenda
        .execution()
        .waiting()
        .for_effect(current, sequence)
        .map_err(crate::task_scheduler::task_fault)?;
    let tasks = entry
        .engine
        .tasks
        .as_deref()
        .ok_or_else(|| Trap::named("internalFault"))?;
    crate::task_effects::reserve_pending(tasks, &mut entry.engine.effects)
        .map_err(|_| Trap::named("internalFault"))
}

fn receiver_of(
    entry: &Entry<'_>,
    operation: &EffectOperation,
    frame: &EffectFrame<'_>,
) -> Result<Option<pseudolearn_runtime::HostCapability>, Trap> {
    if operation.receiver.is_none() {
        return Ok(None);
    }
    let capability =
        Handle(u32::try_from(frame.capability).map_err(|_| Trap::named("internalFault"))?);
    Ok(Some(
        pseudolearn_runtime::capability_token(&entry.engine.heap, capability)?.into(),
    ))
}

pub(crate) fn reject_for_limit(
    channel: &mut crate::effect_channel::EffectChannel,
    operation: &EffectOperation,
    (receiver, arguments, source): (
        Option<pseudolearn_runtime::HostCapability>,
        Vec<pseudolearn_runtime::HostValue>,
        u32,
    ),
) -> Result<pseudolearn_runtime::HostReply, Trap> {
    let request = pseudolearn_runtime::begin_host_effect(
        &mut channel.session,
        operation,
        (receiver, arguments),
        source,
    )
    .map_err(|error| channel.reject(error))?;
    let failure = pseudolearn_runtime::HostReply::failure(pseudolearn_runtime::IoError::from_kind(
        pseudolearn_abi::IoErrorKind::LimitExceeded,
    ));
    pseudolearn_runtime::resolve_host_effect(&mut channel.session, request.effect_seq, failure)
        .map_err(|error| channel.reject(error))
}
