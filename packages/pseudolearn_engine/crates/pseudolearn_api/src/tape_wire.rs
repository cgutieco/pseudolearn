use crate::execution_resource::usage;
use crate::{ApiError, ExecuteRequest};
use pseudolearn_timeline::{
    EffectTape, ExecutionIdentity, ExecutionMode, ReplayError, TAPE_SCHEMA_V1,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};

fn package_graph_digest(request: &ExecuteRequest, source_digest: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(b"pseudolearn.package-graph/v1\nunits=1\nsource=");
    hasher.update(source_digest.as_bytes());
    if let Some(identity) = request.source.filter(|identity| identity.is_valid()) {
        hasher.update(format!(
            "\nproject={}\nrevision={}\nsource_id={}",
            identity.project_id, identity.revision_id, identity.source_id
        ));
    }
    format!("{:x}", hasher.finalize())
}

pub fn build_identity(request: &ExecuteRequest) -> ExecutionIdentity {
    let mut hasher = Sha256::new();
    hasher.update(request.program.as_bytes());
    let source_digest = format!("{:x}", hasher.finalize());
    let options = crate::execution::options(request);
    let limits = [
        ("depth".to_owned(), u64::try_from(options.depth).unwrap_or(u64::MAX)),
        ("cells".to_owned(), options.memory.cells),
        ("statements".to_owned(), options.statement_limit.unwrap_or(u64::MAX)),
        ("micro_steps".to_owned(), request.limits.micro_steps.unwrap_or(u64::MAX)),
    ].into_iter().collect();
    ExecutionIdentity {
        strictness: request.strictness.clone(),
        limits,
        package_graph_digest: package_graph_digest(request, &source_digest),
        source_digest,
        profile: request.profile.clone(),
        seed: request.seed,
        statement_limit: request.limits.statements,
        permissions: pseudolearn_runtime::effective_permissions(request.host.as_ref()).into_iter().collect(),
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
    json!(tape)
}

pub fn tape_from_value(value: &Value) -> Result<EffectTape, ApiError> {
    let format = value.get("format").and_then(Value::as_str)
        .ok_or_else(|| usage("missing tape format"))?;
    if format != TAPE_SCHEMA_V1 {
        return Err(ApiError::UnsupportedVersion(format.to_owned()));
    }
    let bytes = serde_json::to_vec(value).map_err(|error| usage(&error.to_string()))?;
    pseudolearn_runtime::decode_effect_tape(&bytes).map_err(replay_error_to_api)
}
