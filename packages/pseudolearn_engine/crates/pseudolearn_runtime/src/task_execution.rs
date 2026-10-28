use super::{TaskAgenda, TaskAgendaError, TaskId, TaskState};

pub struct TaskExecution<'agenda> {
    pub(super) agenda: &'agenda mut TaskAgenda,
}

impl TaskExecution<'_> {
    pub fn begin(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda
            .transition(task, TaskState::Ready, TaskState::Running)
    }

    pub fn wait_for_effect(
        &mut self,
        task: TaskId,
        effect_sequence: u64,
    ) -> Result<(), TaskAgendaError> {
        let entry = self
            .agenda
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if entry.state != TaskState::Running {
            return Err(TaskAgendaError::InvalidTransition);
        }
        entry.state = TaskState::Waiting;
        entry.waiting_effect = Some(effect_sequence);
        Ok(())
    }

    pub fn resume(&mut self, task: TaskId) -> Result<Option<u64>, TaskAgendaError> {
        let entry = self
            .agenda
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if entry.state != TaskState::Waiting {
            return Err(TaskAgendaError::InvalidTransition);
        }
        entry.state = TaskState::Ready;
        Ok(entry.waiting_effect.take())
    }

    pub fn complete(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda
            .transition(task, TaskState::Running, TaskState::Completed)
    }

    pub fn yield_task(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda
            .transition(task, TaskState::Running, TaskState::Ready)
    }

    pub fn fail(&mut self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        self.agenda.fail_task(task)
    }
}
