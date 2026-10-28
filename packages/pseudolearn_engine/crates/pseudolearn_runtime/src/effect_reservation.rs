use crate::{EffectRecord, EffectSession, ReplayError};
use sha2::{Digest, Sha256};

impl EffectSession {
    pub fn set_current_task(&mut self, task: u64) {
        self.current_task = task;
    }

    pub fn reserve(&mut self, vm_sequences: &[u64]) -> Result<(), ReplayError> {
        for vm_sequence in vm_sequences {
            if self.reserved.contains_key(vm_sequence) {
                continue;
            }
            self.sequence = self
                .sequence
                .checked_add(1)
                .ok_or(ReplayError::Divergence)?;
            self.reserved.insert(*vm_sequence, self.sequence);
        }
        Ok(())
    }

    pub fn reserved_sequence(&self, vm_sequence: u64) -> Option<u64> {
        self.reserved.get(&vm_sequence).copied()
    }

    pub(crate) fn next_request_sequence(&mut self) -> Result<u64, ReplayError> {
        match self.active_reservation.take() {
            Some(reserved) => Ok(reserved),
            None => self.sequence.checked_add(1).ok_or(ReplayError::Divergence),
        }
    }

    pub fn use_reservation(&mut self, vm_sequence: u64) {
        self.active_reservation = self.reserved.remove(&vm_sequence);
    }

    pub(crate) fn reservation_for(&mut self, vm_sequence: u64) -> u64 {
        if let Some(sequence) = self.reserved.remove(&vm_sequence) {
            return sequence;
        }
        self.sequence = self.sequence.saturating_add(1);
        self.sequence
    }

    pub fn resolve_at(
        &mut self,
        sequence: u64,
        request: EffectRecord,
        (payload, outcome): (Vec<u8>, &str),
    ) -> Result<Vec<u8>, ReplayError> {
        let secret = self.secrets.reference(&request.arguments, &payload);
        let request_digest = secret
            .as_ref()
            .map(|secret| secret.value_hmac.clone())
            .unwrap_or_else(|| format!("{:x}", Sha256::digest(&request.arguments)));
        let payload = if self.replay.is_some() {
            self.replay_payload(sequence, (&request, &request_digest), outcome)?
        } else {
            self.record_entry(
                sequence,
                (request, request_digest, secret),
                (outcome, &payload),
            );
            payload
        };
        self.sequence = self.sequence.max(sequence);
        Ok(payload)
    }
}
