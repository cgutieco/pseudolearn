use super::{Machine, TaskContext};
use crate::{Fault, evaluate::INVALID_BYTECODE};

impl Machine<'_> {
    pub(super) fn schedule_next(
        &mut self,
        preserve_current: bool,
        reexecute_current: bool,
    ) -> Result<(), Fault> {
        if preserve_current {
            let current = self.tasks.current;
            let context = TaskContext::capture(self, reexecute_current);
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
        self.tasks.current = next;
        context.restore(self);
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
                self.tasks.current = next;
                context.restore(self);
                if self.resume_cancellation() {
                    return Ok(true);
                }
            }
            self.finish_task_cancel(next)?;
        }
    }
}
