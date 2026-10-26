use pseudolearn_runtime::ReproducibilityStatus;

pub const TAPE_SCHEMA_V1: &str = "pseudolearn.tape/v1";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutionIdentity {
    pub source_digest: String,
    pub package_graph_digest: String,
    pub profile: String,
    pub seed: i64,
    pub statement_limit: Option<u64>,
    pub permissions: Vec<String>,
}

impl ExecutionIdentity {
    pub fn matches(&self, other: &Self) -> bool {
        self.source_digest == other.source_digest
            && self.package_graph_digest == other.package_graph_digest
            && self.profile == other.profile
            && self.seed == other.seed
            && self.statement_limit == other.statement_limit
            && self.permissions == other.permissions
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TapeEntry {
    pub effect_seq: u64,
    pub task_id: u64,
    pub source_node_id: u32,
    pub capability_kind: String,
    pub operation: String,
    pub request_digest: String,
    pub secret_reference: Option<String>,
    pub outcome: String,
    pub payload_bytes: Vec<u8>,
    pub entry_hash: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct EffectTape {
    pub version: String,
    pub identity: ExecutionIdentity,
    pub status: ReproducibilityStatus,
    pub entries: Vec<TapeEntry>,
}

impl EffectTape {
    pub fn new(identity: ExecutionIdentity) -> Self {
        Self {
            version: TAPE_SCHEMA_V1.to_owned(),
            identity,
            status: ReproducibilityStatus::Reproducible,
            entries: Vec::new(),
        }
    }

    pub fn append(&mut self, entry: TapeEntry) {
        if entry.outcome == "uncertain" {
            self.status = ReproducibilityStatus::UncertainExternalState;
        }
        self.entries.push(entry);
    }

    pub fn is_reproducible(&self) -> bool {
        self.status.is_reproducible()
    }

    pub fn entries(&self) -> &[TapeEntry] {
        &self.entries
    }

    pub fn mark_incomplete(&mut self) {
        self.status = ReproducibilityStatus::Incomplete;
    }
}
