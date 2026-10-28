use crate::{EffectTape, ExecutionIdentity, ReplayError, TapeEntry, TapeReplayProvider};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct EffectRecord {
    pub capability_kind: String,
    pub operation: String,
    pub arguments: Vec<u8>,
    pub source_node_id: u32,
}

pub fn console_record(operation: &str, arguments: Vec<u8>) -> EffectRecord {
    EffectRecord {
        capability_kind: "console".to_owned(),
        operation: operation.to_owned(),
        arguments,
        source_node_id: 0,
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct EffectSession {
    pub(crate) tape: EffectTape,
    pub(crate) replay: Option<TapeReplayProvider>,
    pub(crate) sequence: u64,
    pub(crate) authority: crate::effect_authority::EffectAuthority,
    pub(crate) secrets: crate::secret_policy::SecretPolicy,
    pub(crate) pending: Option<crate::host_session::PendingHostEffect>,
    pub(crate) current_task: u64,
    pub(crate) reserved: std::collections::BTreeMap<u64, u64>,
    pub(crate) active_reservation: Option<u64>,
}

impl EffectSession {
    pub fn new(identity: ExecutionIdentity, maximum: usize) -> Self {
        Self {
            tape: EffectTape::with_budget(identity, maximum),
            replay: None,
            sequence: 0,
            authority: Default::default(),
            pending: None,
            secrets: Default::default(),
            current_task: 0,
            reserved: Default::default(),
            active_reservation: None,
        }
    }

    pub fn from_tape(tape: EffectTape, identity: &ExecutionIdentity) -> Result<Self, ReplayError> {
        let replay = TapeReplayProvider::new(tape.clone())?;
        replay.validate_identity(identity)?;
        Ok(Self {
            tape,
            replay: Some(replay),
            sequence: 0,
            authority: Default::default(),
            pending: None,
            secrets: Default::default(),
            current_task: 0,
            reserved: Default::default(),
            active_reservation: None,
        })
    }

    pub fn resolve(
        &mut self,
        request: EffectRecord,
        payload: Vec<u8>,
        outcome: &str,
    ) -> Result<Vec<u8>, ReplayError> {
        let sequence = self
            .sequence
            .checked_add(1)
            .ok_or(ReplayError::Divergence)?;
        self.resolve_at(sequence, request, (payload, outcome))
    }

    pub(crate) fn replay_payload(
        &mut self,
        sequence: u64,
        (request, digest): (&EffectRecord, &str),
        outcome: &str,
    ) -> Result<Vec<u8>, ReplayError> {
        let replay = self.replay.as_mut().ok_or(ReplayError::Divergence)?;
        let entry = replay.next_effect(sequence, &request.operation)?;
        let matches = entry.capability_kind == request.capability_kind
            && entry.request_digest == digest
            && entry.source_node_id == request.source_node_id
            && entry.outcome == outcome;
        if !matches {
            return Err(ReplayError::Divergence);
        }
        Ok(entry.payload_bytes.clone())
    }

    pub(crate) fn record_entry(
        &mut self,
        sequence: u64,
        (request, request_digest, secret): (EffectRecord, String, Option<crate::SecretHandle>),
        (outcome, payload): (&str, &[u8]),
    ) {
        self.tape.append(TapeEntry {
            effect_seq: sequence,
            task_id: self.current_task,
            delivery_seq: None,
            source_node_id: request.source_node_id,
            capability_kind: request.capability_kind,
            operation: request.operation,
            request_digest,
            secret_reference: secret.map(|secret| secret.to_reference_string()),
            outcome: outcome.to_owned(),
            payload_bytes: payload.to_vec(),
            entry_hash: String::new(),
        });
    }

    pub fn is_replaying(&self) -> bool {
        self.replay.is_some()
    }

    pub fn tape(&self) -> &EffectTape {
        &self.tape
    }

    pub fn finish(&self) -> Result<(), ReplayError> {
        if self
            .replay
            .as_ref()
            .is_some_and(|replay| replay.remaining() != 0)
        {
            return Err(ReplayError::Divergence);
        }
        Ok(())
    }

    pub fn abort(&mut self) {
        self.tape.mark_incomplete();
        self.authority.table.close_all();
        self.pending = None;
    }
}
