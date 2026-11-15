use super::{TaskAgenda, TaskId, TaskState, TaskWaitReason};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TaskBlock {
    pub task: TaskId,
    pub reason: Option<TaskWaitReason>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TaskProgress {
    Runnable,
    AwaitingEffects(Vec<(TaskId, u64)>),
    Deadlocked(Vec<TaskBlock>),
    Completed,
}

pub fn task_progress(agenda: &TaskAgenda) -> TaskProgress {
    let mut blocked = Vec::new();
    let mut effects = Vec::new();
    for (task, entry) in &agenda.tasks {
        if entry.state.is_terminal() {
            continue;
        }
        if entry.state != TaskState::Waiting {
            return TaskProgress::Runnable;
        }
        if let Some(TaskWaitReason::Effect(sequence)) = entry.waiting {
            effects.push((*task, sequence));
        }
        blocked.push(TaskBlock {
            task: *task,
            reason: entry.waiting,
        });
    }
    if !effects.is_empty() {
        TaskProgress::AwaitingEffects(effects)
    } else if blocked.is_empty() {
        TaskProgress::Completed
    } else {
        TaskProgress::Deadlocked(blocked)
    }
}
