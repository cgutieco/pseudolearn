use super::{Machine, TaskContext};
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::TaskId;

impl Machine<'_> {
    pub fn select_pending_effect(&mut self, effect_sequence: u64) -> Result<(), &'static str> {
        let request = self
            .tasks
            .pending_effects
            .values()
            .find(|request| request.effect_seq == effect_sequence)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
        let target = TaskId(request.task_id);
        if self.tasks.current == target {
            return Ok(());
        }
        let current = self.tasks.current;
        let current_request = self
            .tasks
            .pending_effects
            .get(&current)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
        self.park_effect_task(current, current_request.effect_seq)?;
        self.resume_effect_task(target)
    }

    fn park_effect_task(&mut self, task: TaskId, effect_sequence: u64) -> Result<(), Fault> {
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_effect(task, effect_sequence)
            .map_err(super::tasks::task_fault)?;
        self.event_task_suspended("effect", effect_sequence);
        let context = TaskContext::capture(self, true)?;
        self.tasks.contexts.insert(task, context);
        Ok(())
    }

    fn resume_effect_task(&mut self, task: TaskId) -> Result<(), Fault> {
        self.tasks
            .agenda
            .execution()
            .resume(task)
            .map_err(super::tasks::task_fault)?;
        self.tasks
            .agenda
            .execution()
            .begin(task)
            .map_err(super::tasks::task_fault)?;
        let context = self.tasks.contexts.remove(&task).ok_or(INVALID_BYTECODE)?;
        self.tasks.quantum.resumed(task);
        self.tasks.current = task;
        self.sync_ready_events("resume");
        self.clear_task_continuation(task)?;
        context.restore(self)?;
        self.event_task_resumed();
        self.apply_aborted_scope(task)
    }

    pub(super) fn schedule_next(
        &mut self,
        preserve_current: bool,
        reexecute_current: bool,
    ) -> Result<(), Fault> {
        if preserve_current {
            let current = self.tasks.current;
            let context = TaskContext::capture(self, reexecute_current)?;
            self.link_task_continuation(current, &context)?;
            self.tasks.contexts.insert(current, context);
        }
        if self.schedule_cleanup()? {
            return Ok(());
        }
        let next = self
            .tasks
            .agenda
            .execution()
            .take_ready()
            .map_err(super::tasks::task_fault)?;
        let next = match next {
            Some(task) => task,
            None => self.schedule_pending_effect()?.ok_or("taskDeadlock")?,
        };
        let context = self.tasks.contexts.remove(&next).ok_or(INVALID_BYTECODE)?;
        self.tasks.quantum.resumed(next);
        self.tasks.current = next;
        self.sync_ready_events("resume");
        self.clear_task_continuation(next)?;
        context.restore(self)?;
        self.event_task_resumed();
        self.apply_aborted_scope(next)
    }

    fn apply_aborted_scope(&mut self, next: pseudolearn_runtime::TaskId) -> Result<(), Fault> {
        if let Some(scope) = self.tasks.aborted_scopes.remove(&next) {
            let resume = self
                .tasks
                .scope_resumes
                .remove(&scope)
                .ok_or(INVALID_BYTECODE)?;
            resume.apply(self);
        }
        Ok(())
    }

    fn schedule_cleanup(&mut self) -> Result<bool, Fault> {
        loop {
            let next = self
                .tasks
                .agenda
                .cancellation()
                .take_cleanup()
                .map_err(super::tasks::task_fault)?;
            let Some(next) = next else { return Ok(false) };
            if let Some(context) = self.tasks.contexts.remove(&next) {
                self.tasks.quantum.resumed(next);
                self.tasks.current = next;
                self.clear_task_continuation(next)?;
                context.restore(self)?;
                self.event_task_resumed();
                if self.resume_cancellation() {
                    return Ok(true);
                }
            }
            self.finish_task_cancel(next)?;
        }
    }
}
