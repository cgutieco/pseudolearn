use crate::{
    EffectRecord, EffectSession, HostCapability, HostEffectProvider, HostEffectRequest, HostReply,
    HostValue, IoError, ReplayError,
};
use pseudolearn_abi::EffectOperation;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct PendingHostEffect {
    request: HostEffectRequest,
    rejected: Option<IoError>,
    previous_status: crate::ReproducibilityStatus,
    recorded: bool,
}

pub fn configure_host_authority(
    session: &mut EffectSession,
    host: Option<&serde_json::Value>,
) -> Result<(), IoError> {
    session.authority.permissions = crate::effect_authority::effective_permissions(host);
    session.secrets = crate::secret_policy::SecretPolicy::from_host(host)?;
    Ok(())
}

pub fn begin_host_effect(
    session: &mut EffectSession,
    operation: &EffectOperation,
    invocation: (Option<HostCapability>, Vec<HostValue>),
    source: u32,
) -> Result<HostEffectRequest, ReplayError> {
    let (receiver, arguments) = invocation;
    if session.pending.is_some() {
        return Err(ReplayError::Divergence);
    }
    let mut request = HostEffectRequest {
        effect_seq: session
            .sequence
            .checked_add(1)
            .ok_or(ReplayError::Divergence)?,
        operation: operation.identity.to_owned(),
        receiver,
        arguments,
        result_capability: None,
        source_node_id: source,
    };
    let rejected =
        crate::effect_authority::prepare(&mut session.authority, operation, &mut request).err();
    let previous_status = session.tape.status;
    let recorded = record_requested(session, &request, operation)?;
    session.pending = Some(PendingHostEffect {
        request: request.clone(),
        rejected,
        previous_status,
        recorded,
    });
    Ok(request)
}

pub fn resolve_host_effect(
    session: &mut EffectSession,
    sequence: u64,
    reply: HostReply,
) -> Result<HostReply, ReplayError> {
    let pending = session
        .pending
        .as_ref()
        .ok_or(ReplayError::Divergence)?
        .clone();
    if pending.request.effect_seq != sequence {
        return Err(ReplayError::Divergence);
    }
    let operation = pseudolearn_abi::effect_operation(&pending.request.operation)
        .ok_or(ReplayError::Divergence)?;
    let reply = pending.rejected.map(HostReply::failure).unwrap_or(reply);
    crate::host_validation::reply(operation, &pending.request, &reply)?;
    let bytes = serde_json::to_vec(&reply).map_err(|_| ReplayError::CorruptedTape)?;
    let arguments = request_arguments(&pending.request)?;
    if session.replay.is_none() && pending.recorded {
        crate::tape_accounting::pop(&mut session.tape);
        crate::tape_accounting::set_status(&mut session.tape, pending.previous_status);
    }
    let bytes = session.resolve(
        EffectRecord {
            capability_kind: capability_kind(operation),
            operation: operation.identity.to_owned(),
            arguments,
            source_node_id: pending.request.source_node_id,
        },
        bytes,
        reply.outcome(),
    )?;
    let reply: HostReply =
        serde_json::from_slice(&bytes).map_err(|_| ReplayError::CorruptedTape)?;
    settle_authority(session, &pending.request, &reply);
    session.pending = None;
    Ok(reply)
}

pub fn perform_host_effect(
    session: &mut EffectSession,
    provider: &mut dyn HostEffectProvider,
    operation: &EffectOperation,
    invocation: (Option<HostCapability>, Vec<HostValue>, u32),
) -> Result<HostReply, ReplayError> {
    let (receiver, arguments, source) = invocation;
    let request = begin_host_effect(session, operation, (receiver, arguments), source)?;
    let reply = if let Some(replay) = session.replay.as_ref() {
        let entry = replay.peek().ok_or(ReplayError::TruncatedTape)?;
        serde_json::from_slice(&entry.payload_bytes).map_err(|_| ReplayError::CorruptedTape)?
    } else if let Some(error) = session
        .pending
        .as_ref()
        .and_then(|pending| pending.rejected)
    {
        HostReply::failure(error)
    } else {
        provider.perform(&request)
    };
    resolve_host_effect(session, request.effect_seq, reply)
}

fn settle_authority(session: &mut EffectSession, request: &HostEffectRequest, reply: &HostReply) {
    let closed = if matches!(reply, HostReply::Committed(_)) {
        matches!(request.operation.as_str(), "file_close" | "directory_close")
            .then_some(request.receiver.as_ref())
            .flatten()
    } else {
        request.result_capability.as_ref()
    };
    if let Some(token) = closed.and_then(|token| token.token().ok()) {
        let _closed = session.authority.table.close(&token);
    }
}

fn request_arguments(request: &HostEffectRequest) -> Result<Vec<u8>, ReplayError> {
    serde_json::to_vec(&(
        &request.receiver,
        &request.arguments,
        &request.result_capability,
    ))
    .map_err(|_| ReplayError::CorruptedTape)
}

fn capability_kind(operation: &EffectOperation) -> String {
    operation
        .receiver
        .map_or("host".to_owned(), |kind| format!("{kind:?}"))
}

fn record_requested(
    session: &mut EffectSession,
    request: &HostEffectRequest,
    operation: &EffectOperation,
) -> Result<bool, ReplayError> {
    if session.replay.is_some() {
        return Ok(false);
    }
    use sha2::Digest;
    let arguments = request_arguments(request)?;
    let secret = session.secrets.reference(&arguments, &[]);
    let digest = secret
        .as_ref()
        .map(|secret| secret.value_hmac.clone())
        .unwrap_or_else(|| format!("{:x}", sha2::Sha256::digest(arguments)));
    let count = session.tape.entries.len();
    session.tape.append(crate::TapeEntry {
        effect_seq: request.effect_seq,
        task_id: 0,
        source_node_id: request.source_node_id,
        capability_kind: capability_kind(operation),
        operation: request.operation.clone(),
        request_digest: digest,
        secret_reference: secret.map(|secret| secret.to_reference_string()),
        outcome: "requested".to_owned(),
        payload_bytes: Vec::new(),
        entry_hash: String::new(),
    });
    let recorded = session.tape.entries.len() > count;
    if recorded {
        session.tape.mark_incomplete();
    }
    Ok(recorded)
}
