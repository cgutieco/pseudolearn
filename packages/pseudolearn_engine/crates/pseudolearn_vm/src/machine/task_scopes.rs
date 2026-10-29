use pseudolearn_bytecode::Register;
use pseudolearn_runtime::{TaskId, TaskScopeId, TaskScopeJoin, TaskState};

use super::{Flow, Machine, tasks::task_fault};
use crate::{Fault, evaluate::INVALID_BYTECODE};

impl Machine<'_> {
    pub(crate) fn open_task_scope(&mut self, destination: u16) -> Result<Flow, Fault> {
        let current = self.tasks.current;
        let scope = self
            .tasks
            .agenda
            .create_scope(current)
            .map_err(task_fault)?;
        let parent = self
            .tasks
            .scope_stacks
            .get(&current)
            .and_then(|stack| stack.last().copied());
        self.tasks.scope_parents.insert(scope, parent);
        self.tasks
            .scope_stacks
            .entry(current)
            .or_default()
            .push(scope);
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
        self.event_task_spawned(task, scope.0);
        self.sync_ready_events("spawn");
        Ok(Flow::Continue)
    }

    pub(crate) fn await_task(
        &mut self,
        aggregate: bool,
        task_register: u16,
        destination: Register,
    ) -> Result<Flow, Fault> {
        let task = TaskId(self.scalar(task_register)?);
        let current = self.tasks.current;
        match self.tasks.agenda.state(task).ok_or(INVALID_BYTECODE)? {
            TaskState::Completed => self.deliver_task_result(task, (destination, aggregate)),
            TaskState::Failed | TaskState::Cancelled => Err(INVALID_BYTECODE),
            _ => self.wait_for_task(current, task),
        }
    }

    fn wait_for_task(&mut self, current: TaskId, task: TaskId) -> Result<Flow, Fault> {
        self.cursor.program_counter = self
            .cursor
            .program_counter
            .checked_sub(1)
            .ok_or(INVALID_BYTECODE)?;
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_task(current, task)
            .map_err(task_fault)?;
        self.event_task_suspended("task", task.0);
        self.schedule_next(true, true)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn join_task_scope(&mut self, scope_register: u16) -> Result<Flow, Fault> {
        let scope = TaskScopeId(self.scalar(scope_register)?);
        let current = self.tasks.current;
        match self.tasks.agenda.close_scope(scope).map_err(task_fault)? {
            TaskScopeJoin::Joined => {
                let failed = self
                    .tasks
                    .failures
                    .get(&scope)
                    .is_some_and(|failures| !failures.errors().is_empty());
                self.event_scope_joined(failed);
                if let Some(stack) = self.tasks.scope_stacks.get_mut(&current)
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
        let current = self.tasks.current;
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_scope(current, scope)
            .map_err(task_fault)?;
        self.event_task_suspended("join", scope.0);
        self.schedule_next(true, true)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn yield_task(&mut self) -> Result<Flow, Fault> {
        let current = self.tasks.current;
        let has_ready = self.tasks.agenda.has_ready();
        if !self.tasks.quantum.at_backedge(current, has_ready) {
            return Ok(Flow::Continue);
        }
        self.tasks
            .agenda
            .execution()
            .yield_task(current)
            .map_err(task_fault)?;
        self.sync_ready_events("yield");
        self.schedule_next(true, false)?;
        Ok(Flow::Continue)
    }
}
