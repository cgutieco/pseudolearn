use super::{Flow, Machine};
use crate::{Fault, PendingEffectRequest, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{TaskId, TaskProgress};

impl Machine<'_> {
    pub(super) fn wait_task_effect(
        &mut self,
        request: PendingEffectRequest,
    ) -> Result<Flow, Fault> {
        let task = self.tasks.current;
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_effect(task, request.effect_seq)
            .map_err(super::tasks::task_fault)?;
        self.tasks.pending_effects.insert(task, request);
        self.schedule_next(true, true)?;
        Ok(Flow::Continue)
    }

    pub(super) fn schedule_pending_effect(&mut self) -> Result<Option<TaskId>, Fault> {
        let TaskProgress::AwaitingEffects(effects) =
            pseudolearn_runtime::task_progress(&self.tasks.agenda)
        else {
            return Ok(None);
        };
        let (task, _) = effects
            .into_iter()
            .min_by_key(|(_, sequence)| *sequence)
            .ok_or(INVALID_BYTECODE)?;
        let request = self
            .tasks
            .pending_effects
            .get(&task)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
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
        self.tasks.pending_delivery = Some(request);
        Ok(Some(task))
    }
}
