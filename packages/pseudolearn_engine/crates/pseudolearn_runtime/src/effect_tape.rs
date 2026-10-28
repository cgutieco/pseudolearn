use crate::ReproducibilityStatus;

pub const TAPE_SCHEMA_V1: &str = "pseudolearn.tape/v1";

#[derive(Clone, Debug, Eq, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ExecutionIdentity {
    pub strictness: String,
    pub limits: std::collections::BTreeMap<String, u64>,
    pub source_digest: String,
    pub package_graph_digest: String,
    pub profile: String,
    pub seed: i64,
    pub statement_limit: Option<u64>,
    pub permissions: Vec<String>,
}

impl ExecutionIdentity {
    pub fn matches(&self, other: &Self) -> bool {
        self.strictness == other.strictness
            && self.limits == other.limits
            && self.source_digest == other.source_digest
            && self.package_graph_digest == other.package_graph_digest
            && self.profile == other.profile
            && self.seed == other.seed
            && self.statement_limit == other.statement_limit
            && self.permissions == other.permissions
    }
}

#[derive(Clone, Debug, Eq, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TapeEntry {
    pub effect_seq: u64,
    pub task_id: u64,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub delivery_seq: Option<u64>,
    pub source_node_id: u32,
    pub capability_kind: String,
    pub operation: String,
    pub request_digest: String,
    pub secret_reference: Option<String>,
    pub outcome: String,
    pub payload_bytes: Vec<u8>,
    pub entry_hash: String,
}

#[derive(Clone, Debug, Eq, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct EffectTape {
    #[serde(rename = "format")]
    pub version: String,
    pub identity: ExecutionIdentity,
    pub status: ReproducibilityStatus,
    pub entries: Vec<TapeEntry>,
    #[serde(rename = "policy")]
    pub budget: crate::tape_privacy::TapeBudget,
}

impl EffectTape {
    pub fn new(identity: ExecutionIdentity) -> Self {
        Self::with_budget(identity, crate::tape_privacy::DEFAULT_MAX_TAPE_BYTES)
    }

    pub fn with_budget(identity: ExecutionIdentity, max_tape_bytes: usize) -> Self {
        let mut tape = Self {
            version: TAPE_SCHEMA_V1.to_owned(),
            identity,
            status: ReproducibilityStatus::Reproducible,
            entries: Vec::new(),
            budget: crate::tape_privacy::TapeBudget::new(max_tape_bytes),
        };
        tape.budget.current_bytes = crate::tape_codec::encoded_size(&tape);
        tape
    }

    pub fn append(&mut self, mut entry: TapeEntry) {
        if self.status == ReproducibilityStatus::NonReproducibleTruncated {
            return;
        }
        let position = u64::try_from(self.entries.len())
            .unwrap_or(u64::MAX)
            .saturating_add(1);
        entry.delivery_seq = (entry.effect_seq != position).then_some(position);
        if entry.secret_reference.is_some() {
            entry.payload_bytes.clear();
        }
        let previous = self
            .entries
            .last()
            .map(|entry| entry.entry_hash.clone())
            .unwrap_or_else(|| crate::tape_codec::identity_hash(&self.identity));
        entry.entry_hash = crate::tape_codec::tape_entry_hash(&previous, &entry);
        let status = self.status_after(&entry);
        let added = crate::tape_accounting::entry_bytes(&entry)
            .saturating_add(usize::from(!self.entries.is_empty()));
        let next = self
            .budget
            .current_bytes
            .saturating_add(added)
            .saturating_sub(self.status.as_str().len())
            .saturating_add(status.as_str().len());
        if next > self.budget.max_bytes {
            crate::tape_accounting::truncate(self);
            return;
        }
        self.budget.current_bytes = next;
        self.status = status;
        self.entries.push(entry);
    }

    fn status_after(&self, entry: &TapeEntry) -> ReproducibilityStatus {
        match entry.outcome.as_str() {
            "uncertain" => ReproducibilityStatus::UncertainExternalState,
            "abandoned" if crate::tape_delivery::operation_may_write(&entry.operation) => {
                ReproducibilityStatus::UncertainExternalState
            }
            _ if entry.secret_reference.is_some()
                && self.status != ReproducibilityStatus::UncertainExternalState =>
            {
                ReproducibilityStatus::NonReproducibleRedacted
            }
            _ => self.status,
        }
    }

    pub fn is_reproducible(&self) -> bool {
        self.status.is_reproducible()
    }

    pub fn entries(&self) -> &[TapeEntry] {
        &self.entries
    }

    pub fn mark_incomplete(&mut self) {
        crate::tape_accounting::set_status(self, ReproducibilityStatus::Incomplete);
    }
}
