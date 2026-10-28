use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{
    TaskAgenda, TaskAgendaError, TaskId, TaskScopeId, TaskScopeJoin, TaskState,
};
use std::collections::BTreeMap;

use super::{Flow, Machine, TaskContext};
use crate::{Fault, RunExit, RuntimeValue, evaluate::INVALID_BYTECODE};

pub(crate) struct VmTasks {
    agenda: TaskAgenda,
    current: TaskId,
    contexts: BTreeMap<TaskId, TaskContext>,
    results: BTreeMap<TaskId, Option<RuntimeValue>>,
}

impl Default for VmTasks {
    fn default() -> Self {
        let (agenda, current) = TaskAgenda::with_running_root();
        Self {
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

    pub(crate) fn current_is_running(&self) -> bool {
        self.agenda.state(self.current) == Some(TaskState::Running)
    }
}

impl Machine<'_> {
    pub(crate) fn open_task_scope(&mut self, destination: u16) -> Result<Flow, Fault> {
        let scope = self
            .tasks
            .agenda
            .create_scope(self.tasks.current)
            .map_err(task_fault)?;
        self.set_scalar(destination, scope.0)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn spawn_task(
        &mut self,
        scope_register: u16,
        site_index: u32,
    ) -> Result<Flow, Fault> {
        let scope = TaskScopeId(self.scalar(scope_register)?);
        let (context, destination) = self.create_task_context(site_index)?;
        let task = self.tasks.agenda.spawn(scope).map_err(task_fault)?;
        self.tasks.contexts.insert(task, context);
        self.set_scalar(destination.index, task.0)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn await_task(
        &mut self,
        task_register: u16,
        destination: Register,
    ) -> Result<Flow, Fault> {
        let task = TaskId(self.scalar(task_register)?);
        match self.tasks.agenda.state(task).ok_or(INVALID_BYTECODE)? {
            TaskState::Completed => {
                let value = self
                    .tasks
                    .results
                    .get(&task)
                    .copied()
                    .flatten()
                    .ok_or(INVALID_BYTECODE)?;
                self.store_task_result(destination, value)?;
                Ok(Flow::Continue)
            }
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
            TaskScopeJoin::Joined => Ok(Flow::Continue),
            TaskScopeJoin::Waiting(_) => {
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
        }
    }

    pub(crate) fn yield_task(&mut self) -> Result<Flow, Fault> {
        if !self.tasks.agenda.has_ready() {
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

    pub(super) fn complete_task(
        &mut self,
        value: Option<RuntimeValue>,
    ) -> Result<Option<RunExit>, Fault> {
        if self.tasks.current == TaskId(0) {
            return Ok(Some(RunExit::Completed(value)));
        }
        let completed = self.tasks.current;
        self.tasks.results.insert(completed, value);
        self.tasks
            .agenda
            .execution()
            .complete(completed)
            .map_err(task_fault)?;
        self.schedule_next(false, false)?;
        Ok(None)
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

    fn schedule_next(
        &mut self,
        preserve_current: bool,
        reexecute_current: bool,
    ) -> Result<(), Fault> {
        if preserve_current {
            let current = self.tasks.current;
            let context = TaskContext::capture(self, reexecute_current);
            self.tasks.contexts.insert(current, context);
        }
        let next = self
            .tasks
            .agenda
            .execution()
            .take_ready()
            .map_err(task_fault)?
            .ok_or("taskDeadlock")?;
        let context = self.tasks.contexts.remove(&next).ok_or(INVALID_BYTECODE)?;
        self.tasks.current = next;
        context.restore(self);
        Ok(())
    }
}

fn task_fault(error: TaskAgendaError) -> Fault {
    match error {
        TaskAgendaError::IdentityExhausted => "taskLimitExceeded",
        TaskAgendaError::UnknownScope
        | TaskAgendaError::UnknownTask
        | TaskAgendaError::InvalidTransition => INVALID_BYTECODE,
    }
}
