use pseudolearn_abi::CapabilityKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum EffectPhase {
    Requested,
    Resolved,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CommitOutcome {
    Committed,
    Failed,
    Uncertain,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ReproducibilityStatus {
    Reproducible,
    UncertainExternalState,
    Incomplete,
    NonReproducibleRedacted,
    NonReproducibleTruncated,
}

impl ReproducibilityStatus {
    pub fn is_reproducible(self) -> bool {
        matches!(self, Self::Reproducible)
    }

    pub fn as_str(self) -> &'static str {
        match self {
            Self::Reproducible => "reproducible",
            Self::UncertainExternalState => "uncertain_external_state",
            Self::Incomplete => "incomplete",
            Self::NonReproducibleRedacted => "non_reproducible_redacted",
            Self::NonReproducibleTruncated => "non_reproducible_truncated",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RightsMask {
    pub read: bool,
    pub write: bool,
    pub execute: bool,
}

impl RightsMask {
    pub const READ_ONLY: Self = Self {
        read: true,
        write: false,
        execute: false,
    };
    pub const READ_WRITE: Self = Self {
        read: true,
        write: true,
        execute: false,
    };
    pub const EXECUTE_ONLY: Self = Self {
        read: false,
        write: false,
        execute: true,
    };

    pub fn is_subset_of(self, parent: Self) -> bool {
        (!self.read || parent.read)
            && (!self.write || parent.write)
            && (!self.execute || parent.execute)
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct CapabilityToken {
    pub slot: u32,
    pub generation: u64,
    pub rights: RightsMask,
    pub kind: CapabilityKind,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CapabilityEntry {
    pub kind: CapabilityKind,
    pub generation: u64,
    pub rights: RightsMask,
    pub closed: bool,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CapabilityError {
    Closed,
    AccessDenied,
    NotFound,
    InvalidToken,
    AmplificationDenied,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct CapabilityTable {
    entries: Vec<CapabilityEntry>,
}

impl CapabilityTable {
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
        }
    }

    pub fn allocate(&mut self, kind: CapabilityKind, rights: RightsMask) -> CapabilityToken {
        let slot = u32::try_from(self.entries.len()).unwrap_or(u32::MAX);
        let generation = 1;
        self.entries.push(CapabilityEntry {
            kind,
            generation,
            rights,
            closed: false,
        });
        CapabilityToken {
            slot,
            generation,
            rights,
            kind,
        }
    }

    pub fn validate(&self, token: &CapabilityToken) -> Result<&CapabilityEntry, CapabilityError> {
        let index = usize::try_from(token.slot).map_err(|_| CapabilityError::InvalidToken)?;
        let entry = self.entries.get(index).ok_or(CapabilityError::NotFound)?;
        if entry.closed || entry.generation != token.generation {
            return Err(CapabilityError::Closed);
        }
        if entry.kind != token.kind {
            return Err(CapabilityError::InvalidToken);
        }
        Ok(entry)
    }

    pub fn close(&mut self, token: &CapabilityToken) -> Result<(), CapabilityError> {
        let index = usize::try_from(token.slot).map_err(|_| CapabilityError::InvalidToken)?;
        let entry = self.entries.get_mut(index).ok_or(CapabilityError::NotFound)?;
        if entry.closed || entry.generation != token.generation {
            return Err(CapabilityError::Closed);
        }
        entry.closed = true;
        entry.generation = entry.generation.saturating_add(1);
        Ok(())
    }

    pub fn close_all(&mut self) {
        for entry in &mut self.entries {
            entry.closed = true;
            entry.generation = entry.generation.saturating_add(1);
        }
    }
}
