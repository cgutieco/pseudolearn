use super::Machine;
use crate::{Fault, RunExit, RuntimeValue, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{TaskId, TaskState, TaskWaitReason, TaskWake};

impl Machine<'_> {
    pub(super) fn complete_step(
        &mut self,
        value: Option<RuntimeValue>,
        position: usize,
    ) -> Option<RunExit> {
        match self.complete_task(value) {
            Ok(exit) => exit,
            Err(fault) => {
                let trap = self.trap_context(fault, position);
                self.record_failure(&trap);
                Some(RunExit::Trap(trap))
            }
        }
    }

    pub(super) fn complete_task(
        &mut self,
        value: Option<RuntimeValue>,
    ) -> Result<Option<RunExit>, Fault> {
        if self.tasks.current == TaskId(0) {
            return Ok(Some(RunExit::Completed(value)));
        }
        let task = self.tasks.current;
        if self.tasks.agenda.state(task) == Some(TaskState::Cleaning) {
            self.finish_task_cancel(task)?;
        } else {
            let (failure, values) = self
                .tasks
                .outcomes
                .remove(&task)
                .unwrap_or((false, value.into_iter().collect()));
            if failure {
                self.fail_current_task(values)?;
            } else {
                self.tasks.results.insert(task, values.first().copied());
                self.tasks.task_values.insert(task, values);
                self.tasks
                    .agenda
                    .execution()
                    .complete(task)
                    .map_err(super::tasks::task_fault)?;
            }
        }
        self.tasks.continuations.remove(&task);
        self.tasks.task_storage.remove(&task);
        self.tasks.cancel_points.remove(&task);
        self.tasks.cleanup_depths.remove(&task);
        self.schedule_next(false, false)?;
        Ok(None)
    }

    fn fail_current_task(&mut self, error: Vec<RuntimeValue>) -> Result<(), Fault> {
        let task = self.tasks.current;
        let scope =
            pseudolearn_runtime::task_scope(&self.tasks.agenda, task).ok_or(INVALID_BYTECODE)?;
        let owner =
            pseudolearn_runtime::scope_owner(&self.tasks.agenda, scope).ok_or(INVALID_BYTECODE)?;
        let waiting = pseudolearn_runtime::task_wait(&self.tasks.agenda, owner);
        self.tasks
            .failures
            .entry(scope)
            .or_default()
            .record(task, error);
        let cancelled = self
            .tasks
            .agenda
            .execution()
            .fail(task)
            .map_err(super::tasks::task_fault)?;
        for sibling in cancelled {
            self.tasks.channels.cancel(sibling);
            self.tasks.channel_replies.remove(&sibling);
            self.tasks.pending_effects.remove(&sibling);
        }
        self.cancel_nested_scopes(scope)?;
        self.interrupt_scope_owner((scope, owner), waiting)?;
        Ok(())
    }

    pub(super) fn finish_task_cancel(&mut self, task: TaskId) -> Result<(), Fault> {
        self.tasks
            .agenda
            .cancellation()
            .finish(task)
            .map_err(super::tasks::task_fault)?;
        self.tasks.continuations.remove(&task);
        self.tasks.task_storage.remove(&task);
        self.tasks.channels.cancel(task);
        self.tasks.pending_effects.remove(&task);
        self.tasks.channel_replies.remove(&task);
        self.tasks.transport_values.remove(&task);
        if let Some(scope) = pseudolearn_runtime::task_scope(&self.tasks.agenda, task) {
            self.tasks.failures.entry(scope).or_default().cancel(task);
        }
        Ok(())
    }
    fn interrupt_scope_owner(
        &mut self,
        (scope, owner): (pseudolearn_runtime::TaskScopeId, TaskId),
        waiting: Option<TaskWaitReason>,
    ) -> Result<(), Fault> {
        if waiting != Some(TaskWaitReason::Scope(scope)) {
            self.tasks.aborted_scopes.insert(owner, scope);
            self.tasks.channels.cancel(owner);
            self.tasks.channel_replies.remove(&owner);
            self.tasks.pending_effects.remove(&owner);
            if self.tasks.agenda.state(owner) == Some(TaskState::Waiting) {
                let wake = pseudolearn_runtime::interrupt_owner(&mut self.tasks.agenda, owner)
                    .map_err(super::tasks::task_fault)?;
                if let TaskWake::Effect(_) = wake {
                    self.effect_result = None;
                }
            }
        }
        Ok(())
    }
}
