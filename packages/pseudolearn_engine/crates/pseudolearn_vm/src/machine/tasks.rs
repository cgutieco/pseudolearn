use pseudolearn_runtime::{TaskAgenda, TaskAgendaError, TaskId, TaskScopeId, TaskState};
use std::collections::BTreeMap;

use super::TaskContext;
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};

#[derive(Clone, Debug, PartialEq)]
pub struct VmTasks {
    pub(super) enabled: bool,
    pub(super) continuations: BTreeMap<TaskId, Vec<super::task_spill::SpilledFrame>>,
    pub(super) task_storage: BTreeMap<TaskId, pseudolearn_runtime::Handle>,
    pub(super) cleanup_depths: BTreeMap<TaskId, usize>,
    pub(super) scope_parents: BTreeMap<TaskScopeId, Option<TaskScopeId>>,
    pub(super) scope_stacks: BTreeMap<TaskId, Vec<TaskScopeId>>,
    pub(super) channel_storage:
        BTreeMap<pseudolearn_runtime::TaskChannelId, pseudolearn_runtime::Handle>,
    pub(super) pending_effects: BTreeMap<TaskId, crate::PendingEffectRequest>,
    pub(super) abandoned_requests: Vec<crate::PendingEffectRequest>,
    pub(super) delivery_order: Vec<u64>,
    pub(super) known_ready: Vec<TaskId>,
    pub(super) delivered_effects: u64,
    pub(super) pending_delivery: Option<crate::PendingEffectRequest>,
    pub(super) outcomes: BTreeMap<TaskId, (bool, Vec<RuntimeValue>)>,
    pub(super) failures:
        BTreeMap<TaskScopeId, pseudolearn_runtime::TaskFailures<Vec<RuntimeValue>>>,
    pub(super) task_values: BTreeMap<TaskId, Vec<RuntimeValue>>,
    pub(super) cancel_points: BTreeMap<TaskId, BTreeMap<usize, super::task_resume::TaskResume>>,
    pub(super) scope_resumes: BTreeMap<TaskScopeId, super::task_resume::TaskResume>,
    pub(super) aborted_scopes: BTreeMap<TaskId, TaskScopeId>,
    pub(super) channels: pseudolearn_runtime::TaskChannels<Vec<RuntimeValue>>,
    pub(super) channel_replies:
        BTreeMap<TaskId, pseudolearn_runtime::ChannelReply<Vec<RuntimeValue>>>,
    pub(super) transport_values: BTreeMap<TaskId, Option<Vec<RuntimeValue>>>,
    pub(super) quantum: pseudolearn_runtime::TaskQuantum,
    pub(super) agenda: TaskAgenda,
    pub(super) current: TaskId,
    pub(super) contexts: BTreeMap<TaskId, TaskContext>,
    pub(super) results: BTreeMap<TaskId, Option<RuntimeValue>>,
}

impl Default for VmTasks {
    fn default() -> Self {
        Self {
            enabled: false,
            continuations: BTreeMap::new(),
            task_storage: BTreeMap::new(),
            cleanup_depths: BTreeMap::new(),
            scope_parents: BTreeMap::new(),
            scope_stacks: BTreeMap::new(),
            channel_storage: BTreeMap::new(),
            pending_effects: BTreeMap::new(),
            abandoned_requests: Vec::new(),
            delivery_order: Vec::new(),
            known_ready: Vec::new(),
            delivered_effects: 0,
            pending_delivery: None,
            outcomes: BTreeMap::new(),
            failures: BTreeMap::new(),
            task_values: BTreeMap::new(),
            cancel_points: BTreeMap::new(),
            scope_resumes: BTreeMap::new(),
            aborted_scopes: BTreeMap::new(),
            channels: pseudolearn_runtime::TaskChannels::default(),
            channel_replies: BTreeMap::new(),
            transport_values: BTreeMap::new(),
            quantum: pseudolearn_runtime::TaskQuantum::default(),
            agenda: TaskAgenda::default(),
            current: TaskId(0),
            contexts: BTreeMap::new(),
            results: BTreeMap::new(),
        }
    }
}

impl VmTasks {
    pub(super) fn abandon_pending_effect(&mut self, task: TaskId) {
        if let Some(request) = self.pending_effects.remove(&task) {
            self.abandoned_requests.push(request);
        }
    }

    pub(super) fn delivery_rank(&self, sequence: u64) -> (usize, u64) {
        let rank = self
            .delivery_order
            .iter()
            .position(|candidate| *candidate == sequence)
            .unwrap_or(usize::MAX);
        (rank, sequence)
    }

    pub(super) fn with_task_limit(limit: u64, enabled: bool) -> Self {
        let mut tasks = Self {
            enabled,
            ..Self::default()
        };
        if enabled {
            let (agenda, current) = TaskAgenda::with_running_root();
            tasks.agenda = agenda;
            tasks.current = current;
        }
        tasks.agenda.set_task_limit(limit);
        tasks
    }

    pub(super) fn contexts(&self) -> impl Iterator<Item = &TaskContext> {
        self.contexts.values()
    }

    pub(super) fn blocked_locations(&self, probed: bool) -> Vec<crate::TaskBlockedLocation> {
        self.contexts
            .iter()
            .filter(|(task, _)| self.agenda.state(**task) == Some(TaskState::Waiting))
            .map(|(task, context)| crate::TaskBlockedLocation {
                task_id: task.0,
                span: context.current.span(context.root_position, probed),
            })
            .collect()
    }

    pub(crate) fn current_is_running(&self) -> bool {
        self.agenda
            .state(self.current)
            .is_some_and(|state| matches!(state, TaskState::Running | TaskState::Cleaning))
    }
}

pub(super) fn task_fault(error: TaskAgendaError) -> Fault {
    match error {
        TaskAgendaError::IdentityExhausted | TaskAgendaError::LimitExceeded => "taskLimitExceeded",
        TaskAgendaError::UnknownScope
        | TaskAgendaError::UnknownTask
        | TaskAgendaError::InvalidTransition => INVALID_BYTECODE,
    }
}
