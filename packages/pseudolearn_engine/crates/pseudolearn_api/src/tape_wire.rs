use crate::execution_resource::usage;
use crate::{ApiError, ExecuteRequest};
use pseudolearn_timeline::{
    EffectTape, ExecutionIdentity, ExecutionMode, ReplayError, TAPE_SCHEMA_V1, TapeEntry,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};

pub fn build_identity(request: &ExecuteRequest) -> ExecutionIdentity {
    let mut hasher = Sha256::new();
    hasher.update(request.program.as_bytes());
    let source_digest = format!("{:x}", hasher.finalize());
    ExecutionIdentity {
        source_digest,
        package_graph_digest: "none".to_owned(),
        profile: request.profile.clone(),
        seed: request.seed,
        statement_limit: request.limits.statements,
        permissions: vec![
            "consola".to_owned(),
            "argumentos".to_owned(),
            "reloj".to_owned(),
        ],
    }
}

pub fn parse_execution_mode(name: Option<&str>) -> Result<ExecutionMode, ApiError> {
    match name {
        None | Some("live_record") => Ok(ExecutionMode::LiveRecord),
        Some("replay_from_tape") => Ok(ExecutionMode::ReplayFromTape),
        Some("history_seek") => Ok(ExecutionMode::HistorySeek),
        Some(unknown) => Err(usage(&format!("unknown execution mode: {unknown}"))),
    }
}

pub fn validate_replay_tape(
    request: &ExecuteRequest,
    execution_mode: ExecutionMode,
) -> Result<(), ApiError> {
    if !matches!(execution_mode, ExecutionMode::ReplayFromTape) {
        return Ok(());
    }
    let tape_value = request
        .effect_tape
        .as_ref()
        .ok_or_else(|| usage("missing effect tape for replay"))?;
    let tape = tape_from_value(tape_value)?;
    let provider =
        pseudolearn_timeline::TapeReplayProvider::new(tape).map_err(replay_error_to_api)?;
    let identity = build_identity(request);
    provider
        .validate_identity(&identity)
        .map_err(replay_error_to_api)
}

pub fn replay_error_to_api(error: ReplayError) -> ApiError {
    ApiError::InvalidProtocol(error.code().to_owned())
}

pub fn compute_entry_hash(
    previous_hash: &str,
    sequence: u64,
    operation: &str,
    payload: &[u8],
) -> String {
    let mut hasher = Sha256::new();
    hasher.update(previous_hash.as_bytes());
    hasher.update(b":");
    hasher.update(sequence.to_string().as_bytes());
    hasher.update(b":");
    hasher.update(operation.as_bytes());
    hasher.update(b":");
    hasher.update(payload);
    format!("{:x}", hasher.finalize())
}

pub fn tape_to_value(tape: &EffectTape) -> Value {
    let entries_value: Vec<Value> = tape.entries().iter().map(entry_to_value).collect();
    json!({
        "format": tape.version,
        "identity": identity_to_value(&tape.identity),
        "status": tape.status.as_str(),
        "entries": entries_value,
    })
}

pub fn tape_from_value(value: &Value) -> Result<EffectTape, ApiError> {
    let format = value
        .get("format")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing tape format"))?;
    if format != TAPE_SCHEMA_V1 {
        return Err(ApiError::UnsupportedVersion(format.to_owned()));
    }
    let identity_value = value
        .get("identity")
        .ok_or_else(|| usage("missing tape identity"))?;
    let identity = parse_identity(identity_value)?;
    let mut tape = EffectTape::new(identity);
    let status_str = value.get("status").and_then(Value::as_str);
    if matches!(status_str, Some(candidate) if candidate != "reproducible") {
        tape.mark_incomplete();
    }
    if let Some(entries_array) = value.get("entries").and_then(Value::as_array) {
        for entry_object in entries_array {
            tape.append(parse_entry(entry_object)?);
        }
    }
    Ok(tape)
}

fn identity_to_value(identity: &ExecutionIdentity) -> Value {
    json!({
        "source_digest": identity.source_digest,
        "package_graph_digest": identity.package_graph_digest,
        "profile": identity.profile,
        "seed": identity.seed,
        "statement_limit": identity.statement_limit,
        "permissions": identity.permissions,
    })
}

fn entry_to_value(entry: &TapeEntry) -> Value {
    json!({
        "effect_seq": entry.effect_seq,
        "task_id": entry.task_id,
        "source_node_id": entry.source_node_id,
        "capability_kind": entry.capability_kind,
        "operation": entry.operation,
        "request_digest": entry.request_digest,
        "secret_reference": entry.secret_reference,
        "outcome": entry.outcome,
        "payload_bytes": entry.payload_bytes,
        "entry_hash": entry.entry_hash,
    })
}

fn parse_identity(value: &Value) -> Result<ExecutionIdentity, ApiError> {
    let source_digest = value
        .get("source_digest")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing source digest"))?
        .to_owned();
    let package_graph_digest = value
        .get("package_graph_digest")
        .and_then(Value::as_str)
        .unwrap_or("none")
        .to_owned();
    let profile = value
        .get("profile")
        .and_then(Value::as_str)
        .unwrap_or("es")
        .to_owned();
    let seed = value.get("seed").and_then(Value::as_i64).unwrap_or(0);
    let statement_limit = value.get("statement_limit").and_then(Value::as_u64);
    let permissions = parse_string_list(value.get("permissions"));
    Ok(ExecutionIdentity {
        source_digest,
        package_graph_digest,
        profile,
        seed,
        statement_limit,
        permissions,
    })
}

fn parse_string_list(value: Option<&Value>) -> Vec<String> {
    match value.and_then(Value::as_array) {
        Some(array) => array
            .iter()
            .filter_map(Value::as_str)
            .map(ToOwned::to_owned)
            .collect(),
        None => Vec::new(),
    }
}

fn parse_entry(value: &Value) -> Result<TapeEntry, ApiError> {
    let effect_seq = value
        .get("effect_seq")
        .and_then(Value::as_u64)
        .ok_or_else(|| usage("missing effect_seq"))?;
    let task_id = value.get("task_id").and_then(Value::as_u64).unwrap_or(0);
    let source_node_id = value
        .get("source_node_id")
        .and_then(Value::as_u64)
        .and_then(|node_identifier| u32::try_from(node_identifier).ok())
        .unwrap_or(0);
    Ok(TapeEntry {
        effect_seq,
        task_id,
        source_node_id,
        capability_kind: string_field(value, "capability_kind", ""),
        operation: string_field(value, "operation", ""),
        request_digest: string_field(value, "request_digest", ""),
        secret_reference: value
            .get("secret_reference")
            .and_then(Value::as_str)
            .map(ToOwned::to_owned),
        outcome: string_field(value, "outcome", "committed"),
        payload_bytes: parse_payload_bytes(value.get("payload_bytes")),
        entry_hash: string_field(value, "entry_hash", ""),
    })
}

fn string_field(value: &Value, name: &str, default_str: &str) -> String {
    value
        .get(name)
        .and_then(Value::as_str)
        .unwrap_or(default_str)
        .to_owned()
}

fn parse_payload_bytes(value: Option<&Value>) -> Vec<u8> {
    match value.and_then(Value::as_array) {
        Some(array) => array
            .iter()
            .filter_map(Value::as_u64)
            .filter_map(|single_byte| u8::try_from(single_byte).ok())
            .collect(),
        None => Vec::new(),
    }
}
