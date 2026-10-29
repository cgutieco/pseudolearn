use pseudolearn_runtime::{TaskId, TaskState};

use super::tasks::VmTasks;

#[test]
fn task_free_state_has_no_root_agenda_entry() {
    let tasks = VmTasks::with_task_limit(10, false);

    assert!(!tasks.enabled);
    assert_eq!(tasks.agenda.state(TaskId(0)), None);
}

#[test]
fn task_runtime_starts_with_a_running_root() {
    let tasks = VmTasks::with_task_limit(10, true);

    assert!(tasks.enabled);
    assert_eq!(tasks.agenda.state(TaskId(0)), Some(TaskState::Running));
}
