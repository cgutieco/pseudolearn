use crate::effect_tape::{EffectTape, ExecutionIdentity, TapeEntry};

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum ExecutionMode {
    #[default]
    LiveRecord,
    ReplayFromTape,
    HistorySeek,
}

impl ExecutionMode {
    pub fn allows_external_host(self) -> bool {
        matches!(self, Self::LiveRecord)
    }

    pub fn as_str(self) -> &'static str {
        match self {
            Self::LiveRecord => "live_record",
            Self::ReplayFromTape => "replay_from_tape",
            Self::HistorySeek => "history_seek",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ReplayError {
    IdentityMismatch,
    Divergence,
    TruncatedTape,
    CorruptedTape,
    NonReproducible,
}

impl ReplayError {
    pub fn code(self) -> &'static str {
        match self {
            Self::IdentityMismatch => "replay_identity_mismatch",
            Self::Divergence => "replay_divergence",
            Self::TruncatedTape => "replay_truncated_tape",
            Self::CorruptedTape => "replay_corrupted_tape",
            Self::NonReproducible => "replay_non_reproducible",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TapeReplayProvider {
    tape: EffectTape,
    cursor: usize,
}

impl TapeReplayProvider {
    pub fn new(tape: EffectTape) -> Result<Self, ReplayError> {
        if !tape.is_reproducible() {
            return Err(ReplayError::NonReproducible);
        }
        Ok(Self { tape, cursor: 0 })
    }

    pub fn validate_identity(&self, candidate: &ExecutionIdentity) -> Result<(), ReplayError> {
        if self.tape.identity.matches(candidate) {
            Ok(())
        } else {
            Err(ReplayError::IdentityMismatch)
        }
    }

    pub fn next_effect(
        &mut self,
        expected_sequence: u64,
        expected_operation: &str,
    ) -> Result<&TapeEntry, ReplayError> {
        let entry = self
            .tape
            .entries
            .get(self.cursor)
            .ok_or(ReplayError::TruncatedTape)?;
        if entry.effect_seq != expected_sequence || entry.operation != expected_operation {
            return Err(ReplayError::Divergence);
        }
        self.cursor = self.cursor.saturating_add(1);
        Ok(entry)
    }

    pub fn cursor(&self) -> usize {
        self.cursor
    }

    pub fn remaining(&self) -> usize {
        self.tape.entries.len().saturating_sub(self.cursor)
    }
}
