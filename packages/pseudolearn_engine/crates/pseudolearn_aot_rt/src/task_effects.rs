use crate::effect_channel::EffectChannel;
use crate::task_state::{AotTasks, AwaitedEffect};
use crate::trap::Trap;
use pseudolearn_runtime::{ReplayError, TaskId, TaskProgress};

pub(crate) fn schedule_pending_effect(tasks: &mut AotTasks) -> Result<Option<TaskId>, Trap> {
    let TaskProgress::AwaitingEffects(effects) = pseudolearn_runtime::task_progress(&tasks.agenda)
    else {
        return Ok(None);
    };
    let order = &tasks.delivery_order;
    let rank = |sequence: u64| {
        let position = order
            .iter()
            .position(|candidate| *candidate == sequence)
            .unwrap_or(usize::MAX);
        (position, sequence)
    };
    let Some((task, sequence)) = effects
        .into_iter()
        .min_by_key(|(_, sequence)| rank(*sequence))
    else {
        return Ok(None);
    };
    mark_excess_network(tasks);
    let mut execution = tasks.agenda.execution();
    execution
        .resume(task)
        .map_err(crate::task_scheduler::task_fault)?;
    execution
        .begin(task)
        .map_err(crate::task_scheduler::task_fault)?;
    tasks.pending_effects.remove(&task);
    tasks.delivering.insert(task, sequence);
    Ok(Some(task))
}

fn mark_excess_network(tasks: &mut AotTasks) {
    let maximum = tasks.pending_network;
    let requests: Vec<u64> = tasks
        .pending_effects
        .values()
        .filter(|effect| effect.request.operation == "network_send")
        .map(|effect| effect.sequence)
        .collect();
    for (index, sequence) in requests.into_iter().enumerate() {
        let count = u64::try_from(index).unwrap_or(u64::MAX).saturating_add(1);
        if pseudolearn_runtime::pending_limit_exceeded(count, maximum) {
            tasks.limit_rejected.insert(sequence);
        }
    }
}

pub(crate) fn reserve_pending(
    tasks: &AotTasks,
    channel: &mut EffectChannel,
) -> Result<(), ReplayError> {
    let mut sequences: Vec<u64> = tasks
        .pending_effects
        .values()
        .chain(tasks.abandoned_effects.iter())
        .map(|effect| effect.sequence)
        .collect();
    sequences.sort_unstable();
    channel.session.reserve(&sequences)
}

pub(crate) fn abandon(tasks: &mut AotTasks, task: TaskId) {
    if let Some(effect) = tasks.pending_effects.remove(&task) {
        tasks.abandoned_effects.push(effect);
    }
}

pub(crate) fn prepare_delivery(
    tasks: &mut AotTasks,
    channel: &mut EffectChannel,
) -> Result<bool, ReplayError> {
    let current = tasks.current;
    let sequence = match tasks.delivering.remove(&current) {
        Some(sequence) => sequence,
        None => {
            tasks.vm_sequence = tasks.vm_sequence.saturating_add(1);
            tasks.vm_sequence
        }
    };
    let mut sequences: Vec<u64> = tasks
        .pending_effects
        .values()
        .chain(tasks.abandoned_effects.iter())
        .map(|effect| effect.sequence)
        .chain(std::iter::once(sequence))
        .collect();
    sequences.sort_unstable();
    channel.session.reserve(&sequences)?;
    channel.session.use_reservation(sequence);
    channel.session.set_current_task(current.0);
    Ok(tasks.limit_rejected.remove(&sequence))
}

pub(crate) fn seal_abandoned(
    tasks: &AotTasks,
    channel: &mut EffectChannel,
) -> Result<(), ReplayError> {
    let mut sequences: Vec<u64> = tasks
        .pending_effects
        .values()
        .chain(tasks.abandoned_effects.iter())
        .map(|effect| effect.sequence)
        .collect();
    sequences.sort_unstable();
    channel.session.reserve(&sequences)?;
    let abandoned = tasks
        .abandoned_effects
        .iter()
        .map(AwaitedEffect::abandoned)
        .collect();
    channel.session.seal_abandoned(abandoned)
}
