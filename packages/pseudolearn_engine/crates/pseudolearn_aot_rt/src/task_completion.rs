use crate::guard::Entry;
use crate::task_scheduler::{finish_task_cancel, task_fault};
use crate::task_state::AotTasks;
use crate::task_values::TaskValue;
use crate::trap::Trap;
use pseudolearn_runtime::{TaskId, TaskScopeId, TaskState, TaskWaitReason};

pub(crate) fn finish_task(entry: &mut Entry<'_>) {
    if let Err(trap) = complete(entry) {
        let status = entry.fail(trap);
        crate::task_scheduler::terminate(entry, status);
    }
}

fn complete(entry: &mut Entry<'_>) -> Result<(), Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let task = tasks.current;
    if tasks.agenda.state(task) == Some(TaskState::Cleaning) {
        finish_task_cancel(tasks, task)?;
    } else {
        let (failure, values) = tasks.outcomes.remove(&task).unwrap_or((false, Vec::new()));
        if failure {
            fail_current_task(tasks, values)?;
        } else {
            tasks.results.insert(task, values.first().copied());
            tasks.task_values.insert(task, values);
            tasks
                .agenda
                .execution()
                .complete(task)
                .map_err(task_fault)?;
        }
    }
    tasks.cancel_points.remove(&task);
    tasks.cleanup_depths.remove(&task);
    tasks.suspended.remove(&task);
    tasks.task_storage.remove(&task);
    entry.engine.roots = Vec::new();
    entry.engine.cells = Vec::new();
    let next = crate::task_scheduler::schedule_next(entry)?;
    crate::task_threads::hand_to(entry, next)
}

fn fail_current_task(tasks: &mut AotTasks, error: Vec<TaskValue>) -> Result<(), Trap> {
    let task = tasks.current;
    let internal = || Trap::named("internalFault");
    let scope = pseudolearn_runtime::task_scope(&tasks.agenda, task).ok_or_else(internal)?;
    let owner = pseudolearn_runtime::scope_owner(&tasks.agenda, scope).ok_or_else(internal)?;
    let waiting = pseudolearn_runtime::task_wait(&tasks.agenda, owner);
    tasks.failures.entry(scope).or_default().record(task, error);
    let cancelled = tasks.agenda.execution().fail(task).map_err(task_fault)?;
    for sibling in cancelled {
        tasks.forget_channel_waits(sibling);
        crate::task_effects::abandon(tasks, sibling);
    }
    cancel_nested_scopes(tasks, scope)?;
    interrupt_scope_owner(tasks, (scope, owner), waiting)
}

fn interrupt_scope_owner(
    tasks: &mut AotTasks,
    (scope, owner): (TaskScopeId, TaskId),
    waiting: Option<TaskWaitReason>,
) -> Result<(), Trap> {
    if waiting == Some(TaskWaitReason::Scope(scope)) {
        return Ok(());
    }
    tasks.aborted_scopes.insert(owner, scope);
    tasks.forget_channel_waits(owner);
    crate::task_effects::abandon(tasks, owner);
    if tasks.agenda.state(owner) == Some(TaskState::Waiting) {
        pseudolearn_runtime::interrupt_owner(&mut tasks.agenda, owner).map_err(task_fault)?;
    }
    Ok(())
}

fn cancel_nested_scopes(tasks: &mut AotTasks, scope: TaskScopeId) -> Result<(), Trap> {
    let nested: Vec<TaskScopeId> = tasks
        .scope_parents
        .keys()
        .copied()
        .filter(|candidate| descends_from(tasks, *candidate, scope))
        .collect();
    for inner in nested {
        for child in pseudolearn_runtime::scope_children(&tasks.agenda, inner) {
            let cancelled = tasks
                .agenda
                .cancellation()
                .request_subtree(child)
                .map_err(task_fault)?;
            for task in cancelled {
                tasks.forget_channel_waits(task);
                crate::task_effects::abandon(tasks, task);
            }
        }
    }
    Ok(())
}

fn descends_from(tasks: &AotTasks, mut candidate: TaskScopeId, scope: TaskScopeId) -> bool {
    while let Some(Some(parent)) = tasks.scope_parents.get(&candidate) {
        if *parent == scope {
            return true;
        }
        candidate = *parent;
    }
    false
}
