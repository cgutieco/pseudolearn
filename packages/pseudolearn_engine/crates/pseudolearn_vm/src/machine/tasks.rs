use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{
    TaskAgenda, TaskAgendaError, TaskId, TaskScopeId, TaskScopeJoin, TaskState,
};
use std::collections::BTreeMap;

use super::{Flow, Machine, TaskContext};
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};

#[derive(Clone, Debug, PartialEq)]
pub struct VmTasks {
    pub(super) continuations: BTreeMap<TaskId, Vec<super::task_spill::SpilledFrame>>,
    pub(super) task_storage: BTreeMap<TaskId, pseudolearn_runtime::Handle>,
    pub(super) cleanup_depths: BTreeMap<TaskId, usize>,
    pub(super) scope_parents: BTreeMap<TaskScopeId, Option<TaskScopeId>>,
    pub(super) scope_stacks: BTreeMap<TaskId, Vec<TaskScopeId>>,
    pub(super) channel_storage:
        BTreeMap<pseudolearn_runtime::TaskChannelId, pseudolearn_runtime::Handle>,
    pub(super) pending_effects: BTreeMap<TaskId, crate::PendingEffectRequest>,
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
        let (agenda, current) = TaskAgenda::with_running_root();
        Self {
            continuations: BTreeMap::new(),
            task_storage: BTreeMap::new(),
            cleanup_depths: BTreeMap::new(),
            scope_parents: BTreeMap::new(),
            scope_stacks: BTreeMap::new(),
            channel_storage: BTreeMap::new(),
            pending_effects: BTreeMap::new(),
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
            agenda,
            current,
            contexts: BTreeMap::new(),
            results: BTreeMap::new(),
        }
    }
}

impl VmTasks {
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

impl Machine<'_> {
    pub(crate) fn open_task_scope(&mut self, destination: u16) -> Result<Flow, Fault> {
        let scope = self
            .tasks
            .agenda
            .create_scope(self.tasks.current)
            .map_err(task_fault)?;
        let stack = self
            .tasks
            .scope_stacks
            .entry(self.tasks.current)
            .or_default();
        self.tasks
            .scope_parents
            .insert(scope, stack.last().copied());
        stack.push(scope);
        self.set_scalar(destination, scope.0)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn spawn_task(
        &mut self,
        scope_register: u16,
        site_index: u32,
    ) -> Result<Flow, Fault> {
        let scope = TaskScopeId(self.scalar(scope_register)?);
        let (mut context, destination) = self.create_task_context(site_index)?;
        let roots = self.memory_roots()?;
        context.spill(&mut self.heap, self.probed, (&roots, Vec::new()))?;
        let task = self.tasks.agenda.spawn(scope).map_err(task_fault)?;
        self.allocate_task_storage((task, scope.0), &context, &roots)?;
        self.tasks.contexts.insert(task, context);
        self.set_scalar(destination.index, task.0)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn await_task(
        &mut self,
        aggregate: bool,
        task_register: u16,
        destination: Register,
    ) -> Result<Flow, Fault> {
        let task = TaskId(self.scalar(task_register)?);
        match self.tasks.agenda.state(task).ok_or(INVALID_BYTECODE)? {
            TaskState::Completed => self.deliver_task_result(task, (destination, aggregate)),
            TaskState::Failed | TaskState::Cancelled => Err(INVALID_BYTECODE),
            _ => {
                self.cursor.program_counter = self
                    .cursor
                    .program_counter
                    .checked_sub(1)
                    .ok_or(INVALID_BYTECODE)?;
                self.tasks
                    .agenda
                    .execution()
                    .waiting()
                    .for_task(self.tasks.current, task)
                    .map_err(task_fault)?;
                self.schedule_next(true, true)?;
                Ok(Flow::Continue)
            }
        }
    }

    pub(crate) fn join_task_scope(&mut self, scope_register: u16) -> Result<Flow, Fault> {
        let scope = TaskScopeId(self.scalar(scope_register)?);
        match self.tasks.agenda.close_scope(scope).map_err(task_fault)? {
            TaskScopeJoin::Joined => {
                if let Some(stack) = self.tasks.scope_stacks.get_mut(&self.tasks.current)
                    && let Some(index) = stack.iter().position(|active| *active == scope)
                {
                    stack.truncate(index);
                }
                Ok(Flow::Continue)
            }
            TaskScopeJoin::Waiting(_) => self.wait_for_scope(scope),
        }
    }

    fn wait_for_scope(&mut self, scope: TaskScopeId) -> Result<Flow, Fault> {
        self.cursor.program_counter = self
            .cursor
            .program_counter
            .checked_sub(1)
            .ok_or(INVALID_BYTECODE)?;
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_scope(self.tasks.current, scope)
            .map_err(task_fault)?;
        self.schedule_next(true, true)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn yield_task(&mut self) -> Result<Flow, Fault> {
        if !self
            .tasks
            .quantum
            .at_backedge(self.tasks.current, self.tasks.agenda.has_ready())
        {
            return Ok(Flow::Continue);
        }
        self.tasks
            .agenda
            .execution()
            .yield_task(self.tasks.current)
            .map_err(task_fault)?;
        self.schedule_next(true, false)?;
        Ok(Flow::Continue)
    }

    fn deliver_task_result(
        &mut self,
        task: TaskId,
        (destination, aggregate): (Register, bool),
    ) -> Result<Flow, Fault> {
        let values = self.tasks.task_values.get(&task).cloned();
        if let Some(values) = values {
            self.tasks
                .transport_values
                .insert(self.tasks.current, Some(values));
        }
        let value = self
            .tasks
            .results
            .get(&task)
            .copied()
            .flatten()
            .unwrap_or(RuntimeValue::Scalar(0));
        self.store_task_result(
            destination,
            if aggregate {
                RuntimeValue::Scalar(0)
            } else {
                value
            },
        )?;
        Ok(Flow::Continue)
    }

    fn store_task_result(
        &mut self,
        destination: Register,
        value: RuntimeValue,
    ) -> Result<(), Fault> {
        match (destination.class, value) {
            (RegisterClass::Scalar, RuntimeValue::Scalar(word)) => {
                self.set_scalar(destination.index, word)
            }
            (RegisterClass::Reference, RuntimeValue::Reference(handle)) => {
                self.set_reference(destination.index, handle)
            }
            _ => Err(INVALID_BYTECODE),
        }
    }
}

pub(super) fn task_fault(error: TaskAgendaError) -> Fault {
    match error {
        TaskAgendaError::IdentityExhausted => "taskLimitExceeded",
        TaskAgendaError::UnknownScope
        | TaskAgendaError::UnknownTask
        | TaskAgendaError::InvalidTransition => INVALID_BYTECODE,
    }
}
