use crate::TaskId;
use std::collections::BTreeSet;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TaskFailure<Error> {
    pub first: Error,
    pub associated: Vec<Error>,
    pub cancelled: u64,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TaskFailures<Error> {
    errors: Vec<Error>,
    completed: BTreeSet<TaskId>,
    cancelled: BTreeSet<TaskId>,
}

impl<Error> Default for TaskFailures<Error> {
    fn default() -> Self {
        Self {
            errors: Vec::new(),
            completed: BTreeSet::new(),
            cancelled: BTreeSet::new(),
        }
    }
}

impl<Error> TaskFailures<Error> {
    pub fn record(&mut self, task: TaskId, error: Error) -> bool {
        if self.cancelled.contains(&task) || !self.completed.insert(task) {
            return false;
        }
        let first = self.errors.is_empty();
        self.errors.push(error);
        first
    }

    pub fn cancel(&mut self, task: TaskId) -> bool {
        !self.completed.contains(&task) && self.cancelled.insert(task)
    }

    pub fn errors(&self) -> &[Error] {
        &self.errors
    }

    pub fn finish(self) -> Option<TaskFailure<Error>> {
        let mut errors = self.errors.into_iter();
        Some(TaskFailure {
            first: errors.next()?,
            associated: errors.collect(),
            cancelled: u64::try_from(self.cancelled.len()).ok()?,
        })
    }
}
