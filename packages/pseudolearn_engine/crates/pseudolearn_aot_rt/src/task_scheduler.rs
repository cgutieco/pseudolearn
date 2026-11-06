use crate::guard::Entry;
use crate::task_state::{AotTasks, Wakeup};
use crate::trap::Trap;
use pseudolearn_runtime::{TaskAgendaError, TaskId};
use std::cell::Cell;

thread_local! {
    static TERMINATED: Cell<bool> = const { Cell::new(false) };
}

pub(crate) fn task_fault(error: TaskAgendaError) -> Trap {
    match error {
        TaskAgendaError::IdentityExhausted | TaskAgendaError::LimitExceeded => {
            Trap::named("taskLimitExceeded")
        }
        _ => Trap::named("internalFault"),
    }
}

pub(crate) fn schedule_next(entry: &mut Entry<'_>) -> Result<TaskId, Trap> {
    if let Some(task) = schedule_cleanup(entry)? {
        return Ok(task);
    }
    let tasks = entry.engine.tasks_mut()?;
    let next = match tasks.agenda.execution().take_ready().map_err(task_fault)? {
        Some(task) => task,
        None => match crate::task_effects::schedule_pending_effect(tasks)? {
            Some(task) => task,
            None => return Err(crate::task_deadlock::deadlock(entry)),
        },
    };
    let tasks = entry.engine.tasks_mut()?;
    enter(tasks, next);
    if let Some(scope) = tasks.aborted_scopes.remove(&next)
        && let Some(landing) = tasks.scope_resumes.remove(&scope)
    {
        tasks.wakeups.insert(next, Wakeup::Land(landing));
    }
    Ok(next)
}

fn enter(tasks: &mut AotTasks, next: TaskId) {
    tasks.quantum.resumed(next);
    tasks.current = next;
}

fn schedule_cleanup(entry: &mut Entry<'_>) -> Result<Option<TaskId>, Trap> {
    loop {
        let tasks = entry.engine.tasks_mut()?;
        let Some(next) = tasks
            .agenda
            .cancellation()
            .take_cleanup()
            .map_err(task_fault)?
        else {
            return Ok(None);
        };
        let started = tasks.suspended.contains_key(&next);
        let point = tasks
            .cancel_points
            .get_mut(&next)
            .and_then(|points| points.pop_last())
            .map(|(_, point)| point);
        if let (true, Some(point)) = (started, point) {
            enter(tasks, next);
            tasks.cleanup_depths.insert(next, point.depth);
            tasks.wakeups.insert(next, Wakeup::Land(point));
            return Ok(Some(next));
        }
        finish_task_cancel(tasks, next)?;
        dismiss(tasks, next);
    }
}

pub(crate) fn dismiss(tasks: &mut AotTasks, task: TaskId) {
    tasks.pending_starts.remove(&task);
    if tasks.suspended.remove(&task).is_some() {
        tasks.baton.dismiss(task.0);
    }
}

pub(crate) fn finish_task_cancel(tasks: &mut AotTasks, task: TaskId) -> Result<(), Trap> {
    tasks
        .agenda
        .cancellation()
        .finish(task)
        .map_err(task_fault)?;
    tasks.forget_channel_waits(task);
    tasks.transport_values.remove(&task);
    tasks.cancel_points.remove(&task);
    tasks.cleanup_depths.remove(&task);
    tasks.task_storage.remove(&task);
    crate::task_effects::abandon(tasks, task);
    if let Some(scope) = pseudolearn_runtime::task_scope(&tasks.agenda, task) {
        tasks.failures.entry(scope).or_default().cancel(task);
    }
    Ok(())
}

pub(crate) fn terminate(entry: &mut Entry<'_>, status: u32) {
    let Some(tasks) = entry.engine.tasks.as_deref_mut() else {
        return;
    };
    if tasks.current == TaskId(0) || tasks.termination.is_some() {
        return;
    }
    tasks.termination = Some(status);
    tasks.wakeups.insert(TaskId(0), Wakeup::Terminate(status));
    tasks.current = TaskId(0);
    TERMINATED.with(|flag| flag.set(true));
    tasks.baton.hand_to(0);
}

pub(crate) fn already_terminated() -> bool {
    TERMINATED.with(Cell::get)
}
