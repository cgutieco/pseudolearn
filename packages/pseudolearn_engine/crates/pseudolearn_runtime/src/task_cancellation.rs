use super::{TaskAgenda, TaskAgendaError, TaskId};

pub struct TaskCancellation<'agenda> {
    pub(super) agenda: &'agenda mut TaskAgenda,
}

impl TaskCancellation<'_> {
    pub fn request(&mut self, task: TaskId) -> Result<bool, TaskAgendaError> {
        self.agenda.request_cancel(task)
    }

    pub fn begin_cleanup(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda.begin_cleanup(task)
    }

    pub fn finish(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda.transition(
            task,
            super::TaskState::Cleaning,
            super::TaskState::Cancelled,
        )
    }

    pub fn order(&self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        self.agenda.cancellation_order(task)
    }

    pub fn request_subtree(&mut self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        let order = self.agenda.cancellation_order(task)?;
        let mut requested = Vec::new();
        for child in order {
            if self.agenda.request_cancel(child)? {
                requested.push(child);
            }
        }
        Ok(requested)
    }

    pub fn abandoned_effects(&self) -> &[(TaskId, u64)] {
        &self.agenda.abandoned_effects
    }
}
