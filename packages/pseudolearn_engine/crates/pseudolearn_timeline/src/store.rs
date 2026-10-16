use pseudolearn_vm::{
    Machine, MachineImage, advance_image, machine_statements_executed, revert_image,
    snapshot_machine_lean,
};

use crate::checkpoint::Checkpoint;
use crate::error::TimelineError;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct StoreBudget {
    pub max_checkpoints: usize,
    pub max_retained_slots: usize,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct CaptureCost {
    pub copied_slots: usize,
    pub copied_bank_slots: usize,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct StoreStats {
    pub checkpoints: usize,
    pub horizon: usize,
    pub retained_slots: usize,
    pub live_words: usize,
    pub last_cost: CaptureCost,
}

pub struct CheckpointStore {
    pub(crate) tip: Option<MachineImage>,
    pub(crate) checkpoints: Vec<Checkpoint>,
    pub(crate) budget: StoreBudget,
    pub(crate) declared_horizon: usize,
    pub(crate) last_cost: CaptureCost,
}

impl CheckpointStore {
    pub fn new(max_checkpoints: usize) -> Self {
        Self::with_budget(StoreBudget {
            max_checkpoints,
            max_retained_slots: usize::MAX,
        })
    }

    pub fn with_budget(budget: StoreBudget) -> Self {
        Self {
            tip: None,
            checkpoints: Vec::new(),
            budget: StoreBudget {
                max_checkpoints: budget.max_checkpoints.max(4),
                max_retained_slots: budget.max_retained_slots,
            },
            declared_horizon: 0,
            last_cost: CaptureCost::default(),
        }
    }

    pub fn has_checkpoints(&self) -> bool {
        !self.checkpoints.is_empty()
    }

    pub fn stats(&self) -> StoreStats {
        StoreStats {
            checkpoints: self.checkpoints.len(),
            horizon: self.declared_horizon,
            retained_slots: self.retained_slots(),
            live_words: self.live_words(),
            last_cost: self.last_cost,
        }
    }

    pub(crate) fn retained_slots(&self) -> usize {
        self.checkpoints
            .iter()
            .map(Checkpoint::retained_slots)
            .sum()
    }

    fn live_words(&self) -> usize {
        self.tip.as_ref().map_or(0, |image| {
            image
                .state
                .heap_used
                .saturating_add(image.state.scalar_watermark)
        })
    }

    pub fn record(
        &mut self,
        machine: &Machine<'_>,
        event_index: usize,
    ) -> Result<(), TimelineError> {
        let statement_index = machine_statements_executed(machine);
        match self.tip.as_mut() {
            None => {
                self.tip = Some(snapshot_machine_lean(machine));
                self.declared_horizon = event_index;
                self.last_cost = CaptureCost::default();
            }
            Some(tip) => {
                let undo = advance_image(tip, machine);
                self.last_cost = CaptureCost {
                    copied_slots: undo.copied_slots(),
                    copied_bank_slots: undo.bank_slots(),
                };
                let previous = self
                    .checkpoints
                    .last_mut()
                    .ok_or(TimelineError::ReplayFailure)?;
                previous.undo = Some(undo);
            }
        }
        self.checkpoints.push(Checkpoint {
            event_index,
            statement_index,
            undo: None,
        });
        self.thin_to_budget();
        Ok(())
    }

    fn candidate_position(&self, target_event: usize) -> Option<usize> {
        self.checkpoints
            .iter()
            .rposition(|checkpoint| checkpoint.event_index <= target_event)
    }

    pub fn image_at(&self, target_event: usize) -> Result<(MachineImage, usize), TimelineError> {
        let position = self
            .candidate_position(target_event)
            .ok_or(TimelineError::ReplayFailure)?;
        let mut image = self.tip.clone().ok_or(TimelineError::ReplayFailure)?;
        let undone = self
            .checkpoints
            .get(position..)
            .ok_or(TimelineError::ReplayFailure)?;
        for checkpoint in undone.iter().rev() {
            if let Some(undo) = &checkpoint.undo {
                revert_image(&mut image, undo).map_err(|_| TimelineError::ReplayFailure)?;
            }
        }
        let event_index = self
            .checkpoints
            .get(position)
            .map(|checkpoint| checkpoint.event_index)
            .ok_or(TimelineError::ReplayFailure)?;
        Ok((image, event_index))
    }
}
