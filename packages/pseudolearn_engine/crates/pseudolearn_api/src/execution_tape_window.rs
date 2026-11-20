use super::{ExecutionResource, usage};
use crate::ApiError;
use serde_json::Value;

impl ExecutionResource {
    pub(crate) fn advance(&mut self, maximum: usize) -> Result<Value, ApiError> {
        self.advance_with_tape_from(maximum, None)
    }

    pub(crate) fn advance_with_tape_from(
        &mut self,
        maximum: usize,
        tape_start: Option<usize>,
    ) -> Result<Value, ApiError> {
        if tape_start.is_some_and(|start| start > self.hosts.delivered_tape.len()) {
            return Err(usage("effect tape start beyond delivered entries"));
        }
        self.advance_batch(maximum, tape_start)
    }

    pub(super) fn unchanged_tape_prefix(&self, requested: usize) -> usize {
        let mut length = requested.min(self.effects.tape().entries().len());
        while length > 0 && !self.still_delivered(length) {
            length = length.saturating_sub(1);
        }
        length
    }

    pub(super) fn remember_delivered_tape(&mut self) {
        let kept = self.unchanged_tape_prefix(self.hosts.delivered_tape.len());
        self.hosts.delivered_tape.truncate(kept);
        let recorded = self
            .effects
            .tape()
            .entries()
            .get(kept..)
            .unwrap_or_default();
        self.hosts
            .delivered_tape
            .extend(recorded.iter().map(|entry| entry.entry_hash.clone()));
    }

    fn still_delivered(&self, length: usize) -> bool {
        let position = length.saturating_sub(1);
        self.effects
            .tape()
            .entries()
            .get(position)
            .map(|entry| &entry.entry_hash)
            == self.hosts.delivered_tape.get(position)
    }
}
