use super::Machine;
use crate::Fault;
use pseudolearn_runtime::TaskScopeId;

impl Machine<'_> {
    pub(super) fn cancel_nested_scopes(&mut self, scope: TaskScopeId) -> Result<(), Fault> {
        let scopes = self
            .tasks
            .scope_parents
            .keys()
            .copied()
            .filter(|candidate| self.tasks.scope_descends_from(*candidate, scope))
            .collect::<Vec<_>>();
        for nested in scopes {
            for child in pseudolearn_runtime::scope_children(&self.tasks.agenda, nested) {
                let cancelled = self
                    .tasks
                    .agenda
                    .cancellation()
                    .request_subtree(child)
                    .map_err(super::tasks::task_fault)?;
                for task in cancelled {
                    let origin = self.tasks.current.0;
                    self.event_cancel_requested(task, "parent_cancelled", origin);
                    self.tasks.channels.cancel(task);
                    self.tasks.abandon_pending_effect(task);
                    self.tasks.channel_replies.remove(&task);
                }
            }
        }
        Ok(())
    }
}

impl super::tasks::VmTasks {
    fn scope_descends_from(&self, mut candidate: TaskScopeId, scope: TaskScopeId) -> bool {
        while let Some(Some(parent)) = self.scope_parents.get(&candidate) {
            if *parent == scope {
                return true;
            }
            candidate = *parent;
        }
        false
    }
}
