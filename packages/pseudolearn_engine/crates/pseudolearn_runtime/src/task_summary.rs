use super::{TaskAgenda, TaskWaitReason};
use crate::TaskState;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TaskSummary {
    pub task: u64,
    pub parent: Option<u64>,
    pub state: &'static str,
    pub cause: Option<&'static str>,
    pub target: Option<u64>,
}

fn state_name(state: TaskState) -> &'static str {
    match state {
        TaskState::Ready => "ready",
        TaskState::Running => "running",
        TaskState::Waiting => "waiting",
        TaskState::CancelRequested => "cancel_requested",
        TaskState::Cleaning => "cleaning",
        TaskState::Completed => "completed",
        TaskState::Failed => "failed",
        TaskState::Cancelled => "cancelled",
    }
}

fn cause_of(reason: TaskWaitReason) -> (&'static str, u64) {
    match reason {
        TaskWaitReason::Effect(sequence) => ("effect", sequence),
        TaskWaitReason::Channel(channel) => ("channel", channel.0),
        TaskWaitReason::Task(task) => ("task", task.0),
        TaskWaitReason::Scope(scope) => ("join", scope.0),
    }
}

impl TaskAgenda {
    pub fn summaries(&self) -> Vec<TaskSummary> {
        self.tasks
            .iter()
            .map(|(identifier, entry)| {
                let wait = entry.waiting.map(cause_of);
                TaskSummary {
                    task: identifier.0,
                    parent: entry.parent.map(|parent| parent.0),
                    state: state_name(entry.state),
                    cause: wait.map(|(cause, _)| cause),
                    target: wait.map(|(_, target)| target),
                }
            })
            .collect()
    }
}
