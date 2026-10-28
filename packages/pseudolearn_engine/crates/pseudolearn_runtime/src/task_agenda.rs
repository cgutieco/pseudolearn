use std::collections::BTreeMap;
use std::collections::VecDeque;

#[path = "task_cancellation.rs"]
mod task_cancellation;
#[path = "task_execution.rs"]
mod task_execution;
#[path = "task_limits.rs"]
mod task_limits;
#[path = "task_summary.rs"]
mod task_summary;
#[path = "task_scheduling.rs"]
mod task_scheduling;
pub use task_limits::{DEFAULT_TASK_LIMIT, TaskLimit};
pub use task_summary::TaskSummary;

pub use task_cancellation::{
    TaskCancellation, interrupt_owner, scope_children, scope_owner, task_scope, task_wait,
};
pub use task_execution::{TaskExecution, TaskWaiting};

#[path = "task_deadlock.rs"]
mod task_deadlock;
pub use task_deadlock::{TaskBlock, TaskProgress, task_progress};

use crate::TaskState;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct TaskId(pub u64);

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct TaskScopeId(pub u64);

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct TaskChannelId(pub u64);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TaskWake {
    Effect(u64),
    Channel(TaskChannelId),
    Task(TaskId),
    Scope(TaskScopeId),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TaskWaitReason {
    Effect(u64),
    Channel(TaskChannelId),
    Task(TaskId),
    Scope(TaskScopeId),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TaskAgendaError {
    IdentityExhausted,
    InvalidTransition,
    LimitExceeded,
    UnknownScope,
    UnknownTask,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TaskScopeJoin {
    Joined,
    Waiting(Vec<TaskId>),
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct TaskEntry {
    parent: Option<TaskId>,
    scope: Option<TaskScopeId>,
    children: Vec<TaskId>,
    state: TaskState,
    waiting: Option<TaskWaitReason>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct ScopeEntry {
    owner: TaskId,
    children: Vec<TaskId>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct TaskAgenda {
    next_task: u64,
    next_scope: u64,
    task_limit: TaskLimit,
    tasks: BTreeMap<TaskId, TaskEntry>,
    scopes: BTreeMap<TaskScopeId, ScopeEntry>,
    abandoned_effects: Vec<(TaskId, u64)>,
    ready: VecDeque<TaskId>,
}

impl TaskAgenda {
    pub fn with_running_root() -> (Self, TaskId) {
        let root = TaskId(0);
        let mut tasks = BTreeMap::new();
        tasks.insert(root, entry(None, None, TaskState::Running));
        let agenda = Self {
            next_task: 1,
            tasks,
            ..Self::default()
        };
        (agenda, root)
    }

    pub fn create_scope(&mut self, owner: TaskId) -> Result<TaskScopeId, TaskAgendaError> {
        if !self.tasks.contains_key(&owner) {
            return Err(TaskAgendaError::UnknownTask);
        }
        let identifier = TaskScopeId(self.next_scope);
        self.next_scope = self
            .next_scope
            .checked_add(1)
            .ok_or(TaskAgendaError::IdentityExhausted)?;
        self.scopes.insert(
            identifier,
            ScopeEntry {
                owner,
                children: Vec::new(),
            },
        );
        Ok(identifier)
    }

    pub fn spawn(&mut self, scope: TaskScopeId) -> Result<TaskId, TaskAgendaError> {
        let owner = self
            .scopes
            .get(&scope)
            .map(|scope| scope.owner)
            .ok_or(TaskAgendaError::UnknownScope)?;
        self.ensure_task_capacity()?;
        let identifier = self.allocate_task()?;
        self.tasks.insert(
            identifier,
            entry(Some(owner), Some(scope), TaskState::Ready),
        );
        self.ready.push_back(identifier);
        if let Some(parent) = self.tasks.get_mut(&owner) {
            parent.children.push(identifier);
        }
        if let Some(scope_entry) = self.scopes.get_mut(&scope) {
            scope_entry.children.push(identifier);
        }
        Ok(identifier)
    }

    pub fn execution(&mut self) -> TaskExecution<'_> {
        TaskExecution { agenda: self }
    }

    pub fn cancellation(&mut self) -> TaskCancellation<'_> {
        TaskCancellation { agenda: self }
    }

    pub fn close_scope(&self, scope: TaskScopeId) -> Result<TaskScopeJoin, TaskAgendaError> {
        let scope_entry = self
            .scopes
            .get(&scope)
            .ok_or(TaskAgendaError::UnknownScope)?;
        let waiting: Vec<_> = scope_entry
            .children
            .iter()
            .copied()
            .filter(|child| !self.state(*child).is_some_and(TaskState::is_terminal))
            .collect();
        if waiting.is_empty() {
            Ok(TaskScopeJoin::Joined)
        } else {
            Ok(TaskScopeJoin::Waiting(waiting))
        }
    }

    pub fn state(&self, task: TaskId) -> Option<TaskState> {
        self.tasks.get(&task).map(|entry| entry.state)
    }

    fn allocate_task(&mut self) -> Result<TaskId, TaskAgendaError> {
        let identifier = TaskId(self.next_task);
        self.next_task = self
            .next_task
            .checked_add(1)
            .ok_or(TaskAgendaError::IdentityExhausted)?;
        Ok(identifier)
    }

    fn transition(
        &mut self,
        task: TaskId,
        expected: TaskState,
        next: TaskState,
    ) -> Result<(), TaskAgendaError> {
        let entry = self
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if entry.state != expected {
            return Err(TaskAgendaError::InvalidTransition);
        }
        entry.state = next;
        Ok(())
    }

    fn request_cancel(&mut self, task: TaskId) -> Result<bool, TaskAgendaError> {
        let entry = self
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if !entry.state.can_request_cancellation() {
            return Ok(false);
        }
        entry.state = TaskState::CancelRequested;
        if let Some(TaskWaitReason::Effect(effect)) = entry.waiting.take() {
            self.abandoned_effects.push((task, effect));
        } else {
            entry.waiting = None;
        }
        Ok(true)
    }

    fn begin_cleanup(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        let children = self
            .tasks
            .get(&task)
            .map(|entry| entry.children.clone())
            .ok_or(TaskAgendaError::UnknownTask)?;
        if children
            .iter()
            .any(|child| !self.state(*child).is_some_and(TaskState::is_terminal))
        {
            return Err(TaskAgendaError::InvalidTransition);
        }
        self.transition(task, TaskState::CancelRequested, TaskState::Cleaning)
    }

    fn cancellation_order(&self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        if !self.tasks.contains_key(&task) {
            return Err(TaskAgendaError::UnknownTask);
        }
        let mut order = Vec::new();
        self.append_descendants(task, &mut order);
        order.push(task);
        Ok(order)
    }

    fn append_descendants(&self, task: TaskId, order: &mut Vec<TaskId>) {
        let children = self
            .tasks
            .get(&task)
            .map(|entry| entry.children.clone())
            .unwrap_or_default();
        for child in children {
            self.append_descendants(child, order);
            order.push(child);
        }
    }

    fn fail_task(&mut self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        self.transition(task, TaskState::Running, TaskState::Failed)?;
        self.wake_completed_dependents(task)?;
        let scope = self.tasks.get(&task).and_then(|entry| entry.scope);
        let Some(scope) = scope else {
            return Ok(Vec::new());
        };
        let siblings = self
            .scopes
            .get(&scope)
            .map(|entry| entry.children.clone())
            .unwrap_or_default();
        let mut requested = Vec::new();
        for sibling in siblings.into_iter().filter(|sibling| *sibling != task) {
            for descendant in self.cancellation_order(sibling)? {
                if self.request_cancel(descendant)? {
                    requested.push(descendant);
                }
            }
        }
        Ok(requested)
    }
}

fn entry(parent: Option<TaskId>, scope: Option<TaskScopeId>, state: TaskState) -> TaskEntry {
    TaskEntry {
        parent,
        scope,
        children: Vec::new(),
        state,
        waiting: None,
    }
}
