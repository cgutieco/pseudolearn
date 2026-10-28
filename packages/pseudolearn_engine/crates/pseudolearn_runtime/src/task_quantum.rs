use crate::TaskId;

pub const TASK_QUANTUM: u64 = 1024;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct TaskQuantum {
    current: Option<TaskId>,
    mass: u64,
}

impl TaskQuantum {
    pub fn charge(&mut self, task: TaskId, mass: u64) {
        if self.current != Some(task) {
            self.resumed(task);
        }
        self.mass = self.mass.saturating_add(mass);
    }

    pub fn at_backedge(&mut self, task: TaskId, ready: bool) -> bool {
        if self.current != Some(task) || self.mass < TASK_QUANTUM {
            return false;
        }
        self.mass = 0;
        ready
    }

    pub fn resumed(&mut self, task: TaskId) {
        self.current = Some(task);
        self.mass = 0;
    }
}
