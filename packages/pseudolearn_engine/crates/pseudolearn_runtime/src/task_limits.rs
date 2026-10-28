use super::{TaskAgenda, TaskAgendaError, TaskId};

pub const DEFAULT_TASK_LIMIT: u64 = 4_096;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct TaskLimit(pub u64);

impl Default for TaskLimit {
    fn default() -> Self {
        Self(DEFAULT_TASK_LIMIT)
    }
}

impl TaskAgenda {
    pub fn set_task_limit(&mut self, limit: u64) {
        self.task_limit = TaskLimit(limit);
    }

    pub fn live_task_count(&self) -> u64 {
        let live = self
            .tasks
            .iter()
            .filter(|(identifier, entry)| **identifier != TaskId(0) && !entry.state.is_terminal())
            .count();
        u64::try_from(live).unwrap_or(u64::MAX)
    }

    pub(super) fn ensure_task_capacity(&self) -> Result<(), TaskAgendaError> {
        if self.live_task_count() >= self.task_limit.0 {
            return Err(TaskAgendaError::LimitExceeded);
        }
        Ok(())
    }
}
