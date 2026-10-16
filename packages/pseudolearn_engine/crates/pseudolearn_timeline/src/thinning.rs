use crate::checkpoint::Checkpoint;
use crate::shadow::fuse_undo_segments;

#[derive(Clone, Debug, PartialEq)]
pub struct ThinningManager {
    pub checkpoints: Vec<Checkpoint>,
    pub max_checkpoints: usize,
    pub declared_horizon: usize,
}

impl ThinningManager {
    pub fn new(max_checkpoints: usize) -> Self {
        Self {
            checkpoints: Vec::new(),
            max_checkpoints: max_checkpoints.max(4),
            declared_horizon: 0,
        }
    }

    pub fn checkpoints_count(&self) -> usize {
        self.checkpoints.len()
    }

    pub fn horizon(&self) -> usize {
        self.declared_horizon
    }

    pub fn find_candidate_checkpoint(&self, target_event: usize) -> Option<&Checkpoint> {
        let mut candidate = None;
        for checkpoint in &self.checkpoints {
            if checkpoint.event_index <= target_event {
                candidate = Some(checkpoint);
            } else {
                break;
            }
        }
        candidate
    }

    pub fn push_checkpoint(&mut self, checkpoint: Checkpoint) {
        if self.checkpoints.is_empty() {
            self.declared_horizon = checkpoint.event_index;
        }
        if self.checkpoints.len() >= self.max_checkpoints {
            self.execute_thinning_step();
        }
        self.checkpoints.push(checkpoint);
    }

    fn execute_thinning_step(&mut self) {
        if self.checkpoints.is_empty() {
            return;
        }
        let removed = self.checkpoints.remove(0);
        if let Some(first) = self.checkpoints.first_mut() {
            first.undo_segment = fuse_undo_segments(&removed.undo_segment, &first.undo_segment);
            self.declared_horizon = first.event_index;
        }
    }
}
