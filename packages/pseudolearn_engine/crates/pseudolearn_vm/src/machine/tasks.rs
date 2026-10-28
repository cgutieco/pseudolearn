use pseudolearn_runtime::{TaskAgenda, TaskId, TaskState};

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct VmTasks {
    agenda: TaskAgenda,
    current: TaskId,
}

impl Default for VmTasks {
    fn default() -> Self {
        let (agenda, current) = TaskAgenda::with_running_root();
        Self { agenda, current }
    }
}

impl VmTasks {
    pub(crate) fn current_is_running(&self) -> bool {
        self.agenda.state(self.current) == Some(TaskState::Running)
    }
}
