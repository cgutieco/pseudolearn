use crate::TaskId;
use std::collections::VecDeque;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct WaitQueue<Value> {
    entries: VecDeque<(TaskId, Value)>,
}

impl<Value> Default for WaitQueue<Value> {
    fn default() -> Self {
        Self {
            entries: VecDeque::new(),
        }
    }
}

impl<Value> WaitQueue<Value> {
    pub(crate) fn push(&mut self, task: TaskId, value: Value) {
        self.entries.push_back((task, value));
    }

    pub(crate) fn pop(&mut self) -> Option<(TaskId, Value)> {
        self.entries.pop_front()
    }

    pub(crate) fn values(&self) -> impl Iterator<Item = &Value> {
        self.entries.iter().map(|(_, value)| value)
    }

    pub(crate) fn remove(&mut self, task: TaskId) {
        self.entries.retain(|(waiting, _)| *waiting != task);
    }
}
