use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::task_blocking::{Step, blocking_entry, packet_values};
use crate::task_scheduler::task_fault;
use crate::task_state::PendingStart;
use crate::trap::Trap;
use pseudolearn_runtime::{TaskId, TaskScopeId, TaskScopeJoin, TaskState};

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_scope_open(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        let tasks = entry.engine.tasks_mut()?;
        let current = tasks.current;
        let scope = tasks.agenda.create_scope(current).map_err(task_fault)?;
        let parent = tasks
            .scope_stacks
            .get(&current)
            .and_then(|stack| stack.last().copied());
        tasks.scope_parents.insert(scope, parent);
        tasks.scope_stacks.entry(current).or_default().push(scope);
        Ok(scope.0)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_spawn(
    context: *mut AotRuntimeContext,
    site: u32,
    scope: u64,
    packet: *const u64,
) -> u32 {
    let function = borrow_slice(packet, 1).and_then(|words| words.first().copied());
    run_entry(context, site, |entry| {
        let function = function
            .and_then(|word| u32::try_from(word).ok())
            .ok_or_else(|| Trap::named("internalFault"))?;
        let arguments = packet_values(packet.wrapping_add(1))?;
        let task = spawn_storage(entry, (scope, function), &arguments)?;
        let tasks = entry.engine.tasks_mut()?;
        tasks.pending_starts.insert(
            task,
            PendingStart {
                function,
                arguments,
            },
        );
        Ok(task.0)
    })
}

fn spawn_storage(
    entry: &mut Entry<'_>,
    (scope, function): (u64, u32),
    arguments: &[crate::task_values::TaskValue],
) -> Result<TaskId, Trap> {
    let mut roots = entry.roots()?;
    roots.extend(arguments.iter().filter_map(|value| value.root()));
    let continuation = entry_continuation(entry, function, (arguments, &roots))?;
    roots.push(continuation);
    let tasks = entry.engine.tasks_mut()?;
    let parent = tasks.current.0;
    let task = tasks.agenda.spawn(TaskScopeId(scope)).map_err(task_fault)?;
    let storage = pseudolearn_runtime::task_storage::new_task_storage(
        &mut entry.engine.heap,
        pseudolearn_runtime::task_storage::TaskStorage {
            identity: task.0,
            parent,
            scope,
            continuation,
        },
        &roots,
    )?;
    entry.engine.tasks_mut()?.task_storage.insert(task, storage);
    Ok(task)
}

fn entry_continuation(
    entry: &mut Entry<'_>,
    function: u32,
    (arguments, roots): (
        &[crate::task_values::TaskValue],
        &[pseudolearn_runtime::Handle],
    ),
) -> Result<pseudolearn_runtime::Handle, Trap> {
    let scalars: Vec<u64> = arguments
        .iter()
        .filter(|value| value.root().is_none())
        .map(|value| value.word())
        .collect();
    let references: Vec<pseudolearn_runtime::Handle> =
        arguments.iter().filter_map(|value| value.root()).collect();
    let values = pseudolearn_runtime::continuation::ContinuationValues {
        function: u64::from(function),
        state: 0,
        parent: pseudolearn_runtime::Handle(0),
        scalars: &scalars,
        references: &references,
    };
    Ok(pseudolearn_runtime::continuation::new_continuation(
        &mut entry.engine.heap,
        values,
        roots,
    )?)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_await(
    context: *mut AotRuntimeContext,
    site: u32,
    task: u64,
    aggregate: u32,
) -> u32 {
    blocking_entry(context, site, |entry| {
        await_step(entry, TaskId(task), aggregate != 0)
    })
}

fn await_step(entry: &mut Entry<'_>, task: TaskId, aggregate: bool) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    match tasks.agenda.state(task) {
        Some(TaskState::Completed) => {
            if let Some(values) = tasks.task_values.get(&task).cloned() {
                tasks.transport_values.insert(current, Some(values));
            }
            let word = tasks
                .results
                .get(&task)
                .copied()
                .flatten()
                .map_or(0, crate::task_values::TaskValue::word);
            Ok(Step::Done(if aggregate { 0 } else { word }))
        }
        Some(TaskState::Failed | TaskState::Cancelled) | None => Err(Trap::named("internalFault")),
        Some(_) => {
            tasks
                .agenda
                .execution()
                .waiting()
                .for_task(current, task)
                .map_err(task_fault)?;
            Ok(Step::Block)
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_scope_join(
    context: *mut AotRuntimeContext,
    site: u32,
    scope: u64,
) -> u32 {
    blocking_entry(context, site, |entry| join_step(entry, TaskScopeId(scope)))
}

fn join_step(entry: &mut Entry<'_>, scope: TaskScopeId) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    match tasks.agenda.close_scope(scope).map_err(task_fault)? {
        TaskScopeJoin::Joined => {
            if let Some(stack) = tasks.scope_stacks.get_mut(&current)
                && let Some(index) = stack.iter().position(|active| *active == scope)
            {
                stack.truncate(index);
            }
            Ok(Step::Done(0))
        }
        TaskScopeJoin::Waiting(_) => {
            tasks
                .agenda
                .execution()
                .waiting()
                .for_scope(current, scope)
                .map_err(task_fault)?;
            Ok(Step::Block)
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_yield(context: *mut AotRuntimeContext, site: u32) -> u32 {
    blocking_entry(context, site, yield_step)
}

pub(crate) fn quantum_spent(mass: i64) -> bool {
    u64::try_from(mass).is_ok_and(|spent| spent >= pseudolearn_runtime::TASK_QUANTUM)
}

pub(crate) fn cedes_turn(mass: i64, others_ready: bool) -> bool {
    quantum_spent(mass) && others_ready
}

fn yield_step(entry: &mut Entry<'_>) -> Result<Step, Trap> {
    if !quantum_spent(entry.context.quantum_mass) {
        return Ok(Step::Done(0));
    }
    let mass = entry.context.quantum_mass;
    entry.context.quantum_mass = 0;
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    if !cedes_turn(mass, tasks.agenda.has_ready()) {
        return Ok(Step::Done(0));
    }
    tasks
        .agenda
        .execution()
        .yield_task(current)
        .map_err(task_fault)?;
    Ok(Step::BlockThenDone(0))
}

#[cfg(test)]
#[path = "task_entries_tests.rs"]
mod task_entries_tests;
