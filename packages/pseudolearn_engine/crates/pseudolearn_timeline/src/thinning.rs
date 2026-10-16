use pseudolearn_vm::compose_machine_deltas;

use crate::checkpoint::Checkpoint;
use crate::store::CheckpointStore;

impl CheckpointStore {
    pub(crate) fn thin_to_budget(&mut self) {
        while self.over_budget() {
            if self.checkpoints.len() > 2 {
                self.remove_sparsest_interior();
            } else if !self.drop_oldest() {
                break;
            }
        }
    }

    fn over_budget(&self) -> bool {
        self.checkpoints.len() > self.budget.max_checkpoints
            || (self.checkpoints.len() > 1
                && self.retained_slots() > self.budget.max_retained_slots)
    }

    fn remove_sparsest_interior(&mut self) {
        let Some(removed) = self.sparsest_interior_position() else {
            return;
        };
        let Some(older_position) = removed.checked_sub(1) else {
            return;
        };
        let removed_checkpoint = self.checkpoints.remove(removed);
        if let (Some(removed_undo), Some(older)) = (
            removed_checkpoint.undo,
            self.checkpoints.get_mut(older_position),
        ) {
            older.undo = match older.undo.take() {
                Some(older_undo) => Some(compose_machine_deltas(&removed_undo, &older_undo)),
                None => Some(removed_undo),
            };
        }
    }

    fn sparsest_interior_position(&self) -> Option<usize> {
        let newest = self.checkpoints.last()?.event_index;
        let mut best: Option<(usize, u64, u64)> = None;
        for position in 1..self.checkpoints.len().saturating_sub(1) {
            let before = self.checkpoints.get(position.checked_sub(1)?)?;
            let current = self.checkpoints.get(position)?;
            let after = self.checkpoints.get(position.checked_add(1)?)?;
            let gap = event_distance(after, before);
            let age = u64::try_from(newest.saturating_sub(current.event_index))
                .unwrap_or(u64::MAX)
                .saturating_add(1);
            let better = best.is_none_or(|(_, best_gap, best_age)| {
                gap.saturating_mul(best_age) < best_gap.saturating_mul(age)
            });
            if better {
                best = Some((position, gap, age));
            }
        }
        best.map(|(position, _, _)| position)
    }

    fn drop_oldest(&mut self) -> bool {
        if self.checkpoints.len() < 2 {
            return false;
        }
        self.checkpoints.remove(0);
        self.declared_horizon = self
            .checkpoints
            .first()
            .map_or(self.declared_horizon, |first| first.event_index);
        true
    }
}

fn event_distance(later: &Checkpoint, earlier: &Checkpoint) -> u64 {
    u64::try_from(later.event_index.saturating_sub(earlier.event_index)).unwrap_or(u64::MAX)
}
