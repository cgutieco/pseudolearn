use super::{abandon, schedule_pending_effect, seal_abandoned};
use crate::context::AotRuntimeContext;
use crate::effect_channel::EffectChannel;
use crate::task_state::{AotTasks, AwaitedEffect};
use pseudolearn_runtime::{HostEffectRequest, TaskId};

extern "C" fn no_dispatch(_context: *mut AotRuntimeContext, _function: u32, _values: *const u64) {}

fn request(sequence: u64, operation: &str) -> HostEffectRequest {
    HostEffectRequest {
        effect_seq: sequence,
        operation: operation.to_owned(),
        receiver: None,
        arguments: Vec::new(),
        result_capability: None,
        source_node_id: 0,
    }
}

fn awaiting(operations: &[&str]) -> Result<(AotTasks, Vec<TaskId>), String> {
    let mut tasks = AotTasks::new(no_dispatch, 16, 16);
    let root = tasks.current;
    let scope = tasks
        .agenda
        .create_scope(root)
        .map_err(|error| format!("{error:?}"))?;
    let mut spawned = Vec::new();
    for _ in operations {
        spawned.push(
            tasks
                .agenda
                .spawn(scope)
                .map_err(|error| format!("{error:?}"))?,
        );
    }
    let mut execution = tasks.agenda.execution();
    execution
        .waiting()
        .for_scope(root, scope)
        .map_err(|error| format!("{error:?}"))?;
    for (index, (task, operation)) in spawned.iter().zip(operations).enumerate() {
        let sequence = u64::try_from(index).unwrap_or(0).saturating_add(1);
        let mut execution = tasks.agenda.execution();
        execution
            .take_ready()
            .map_err(|error| format!("{error:?}"))?;
        execution
            .waiting()
            .for_effect(*task, sequence)
            .map_err(|error| format!("{error:?}"))?;
        tasks.pending_effects.insert(
            *task,
            AwaitedEffect {
                sequence,
                task: *task,
                request: request(sequence, operation),
            },
        );
    }
    Ok((tasks, spawned))
}

fn delivery(tasks: &mut AotTasks) -> Result<Vec<u64>, String> {
    let mut delivered = Vec::new();
    while let Some(task) =
        schedule_pending_effect(tasks).map_err(|_| "scheduling trapped".to_owned())?
    {
        delivered.extend(tasks.delivering.get(&task).copied());
        tasks
            .agenda
            .execution()
            .complete(task)
            .map_err(|error| format!("{error:?}"))?;
    }
    Ok(delivered)
}

#[test]
fn effects_are_delivered_in_the_declared_permutation() -> Result<(), String> {
    let (mut tasks, _) = awaiting(&["clock_now", "clock_now", "clock_now"])?;
    tasks.delivery_order = vec![3, 1, 2];
    assert_eq!(delivery(&mut tasks)?, [3, 1, 2]);
    assert!(tasks.pending_effects.is_empty());
    Ok(())
}

#[test]
fn without_a_declared_order_effects_are_delivered_by_sequence() -> Result<(), String> {
    let (mut tasks, _) = awaiting(&["clock_now", "clock_now", "clock_now"])?;
    assert_eq!(delivery(&mut tasks)?, [1, 2, 3]);
    Ok(())
}

#[test]
fn sequences_missing_from_the_order_come_after_the_listed_ones() -> Result<(), String> {
    let (mut tasks, _) = awaiting(&["clock_now", "clock_now", "clock_now"])?;
    tasks.delivery_order = vec![2];
    assert_eq!(delivery(&mut tasks)?, [2, 1, 3]);
    Ok(())
}

#[test]
fn no_effect_is_delivered_while_another_task_can_run() -> Result<(), String> {
    let mut tasks = AotTasks::new(no_dispatch, 16, 16);
    assert_eq!(
        schedule_pending_effect(&mut tasks).map_err(|_| "scheduling trapped".to_owned())?,
        None
    );
    Ok(())
}

#[test]
fn network_requests_beyond_the_pending_limit_are_marked_for_rejection() -> Result<(), String> {
    let (mut tasks, _) = awaiting(&["network_send", "network_send", "clock_now"])?;
    tasks.pending_network = 1;
    schedule_pending_effect(&mut tasks).map_err(|_| "scheduling trapped".to_owned())?;
    assert_eq!(
        tasks.limit_rejected.iter().copied().collect::<Vec<_>>(),
        [2]
    );
    Ok(())
}

#[test]
fn an_abandoned_effect_is_sealed_instead_of_delivered() -> Result<(), String> {
    let (mut tasks, spawned) = awaiting(&["clock_now", "clock_now"])?;
    let first = *spawned.first().ok_or("no task")?;
    abandon(&mut tasks, first);
    assert_eq!(tasks.abandoned_effects.len(), 1);
    assert!(!tasks.pending_effects.contains_key(&first));
    let mut channel = EffectChannel::standalone();
    assert!(seal_abandoned(&tasks, &mut channel).is_ok());
    abandon(&mut tasks, first);
    assert_eq!(tasks.abandoned_effects.len(), 1);
    Ok(())
}
