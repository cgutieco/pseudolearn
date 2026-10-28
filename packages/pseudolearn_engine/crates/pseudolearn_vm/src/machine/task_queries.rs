use super::Machine;

impl Machine<'_> {
    pub fn set_delivery_order(&mut self, order: Vec<u64>) {
        self.tasks.delivery_order = order;
    }

    pub fn task_summaries(&self) -> Vec<pseudolearn_runtime::TaskSummary> {
        self.tasks.agenda.summaries()
    }

    pub fn current_task_id(&self) -> u64 {
        self.tasks.current.0
    }

    pub fn pending_effect_requests(&self) -> Vec<crate::PendingEffectRequest> {
        let mut requests: Vec<_> = self.tasks.pending_effects.values().cloned().collect();
        requests.sort_by_key(|request| request.effect_seq);
        requests
    }

    pub fn abandoned_effect_requests(&self) -> Vec<crate::PendingEffectRequest> {
        self.tasks.abandoned_requests.clone()
    }
}
