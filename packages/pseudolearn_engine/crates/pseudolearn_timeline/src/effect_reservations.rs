use pseudolearn_runtime::{EffectSession, ReplayError};
use pseudolearn_vm::{Machine, PendingEffectRequest};

pub fn sync_effect_reservations(
    session: &mut EffectSession,
    machine: &Machine<'_>,
) -> Result<(), ReplayError> {
    let mut sequences: Vec<u64> = machine
        .pending_effect_requests()
        .iter()
        .chain(machine.abandoned_effect_requests().iter())
        .map(|request| request.effect_seq)
        .collect();
    sequences.sort_unstable();
    session.reserve(&sequences)
}

pub fn prepare_effect_delivery(
    session: &mut EffectSession,
    machine: &Machine<'_>,
    pending: &PendingEffectRequest,
) -> Result<(), ReplayError> {
    sync_effect_reservations(session, machine)?;
    session.use_reservation(pending.effect_seq);
    session.set_current_task(pending.task_id);
    Ok(())
}
