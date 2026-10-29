use crate::execution_resource::usage;
use crate::{ApiError, ExecuteRequest};
use pseudolearn_timeline::{
    EffectTape, ExecutionIdentity, ExecutionMode, ReplayError, TAPE_SCHEMA_V1,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;

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
    let limits = identity_limits(request);
    ExecutionIdentity {
        strictness: request.strictness.clone(),
        limits,
        package_graph_digest: package_graph_digest(request, &source_digest),
        source_digest,
        profile: request.profile.clone(),
        seed: request.seed,
        statement_limit: request.limits.statements,
        permissions: pseudolearn_runtime::effective_permissions(request.host.as_ref())
            .into_iter()
            .collect(),
    }
}

fn identity_limits(request: &ExecuteRequest) -> BTreeMap<String, u64> {
    let options = crate::execution::options(request);
    let mut limits: BTreeMap<String, u64> = [
        (
            "depth".to_owned(),
            u64::try_from(options.depth).unwrap_or(u64::MAX),
        ),
        ("cells".to_owned(), options.memory.cells),
        (
            "statements".to_owned(),
            options.statement_limit.unwrap_or(u64::MAX),
        ),
        (
            "micro_steps".to_owned(),
            request.limits.micro_steps.unwrap_or(u64::MAX),
        ),
    ]
    .into_iter()
    .collect();
    limits.extend(
        request
            .limits
            .tasks
            .map(|tasks| ("tasks".to_owned(), tasks)),
    );
    limits.extend(request.limits.max_json_depth.and_then(|depth| {
        u64::try_from(depth)
            .ok()
            .map(|depth| ("max_json_depth".to_owned(), depth))
    }));
    limits.extend(network_limit_entries(request));
    limits
}

fn network_limit_entries(request: &ExecuteRequest) -> impl Iterator<Item = (String, u64)> + '_ {
    [
        ("max_http_body_bytes", request.limits.max_http_body_bytes),
        ("max_http_wire_bytes", request.limits.max_http_wire_bytes),
        (
            "max_http_header_bytes",
            request.limits.max_http_header_bytes,
        ),
        ("max_http_headers", request.limits.max_http_headers),
        ("max_pending_network", request.limits.max_pending_network),
        (
            "max_http_timeout_nanos",
            request.limits.max_http_timeout_nanos,
        ),
    ]
    .into_iter()
    .filter_map(|(name, value)| value.map(|value| (name.to_owned(), value)))
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

pub fn tape_to_value(tape: &EffectTape) -> Value {
    json!(tape)
}

pub fn tape_from_value(value: &Value) -> Result<EffectTape, ApiError> {
    let format = value
        .get("format")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing tape format"))?;
    if format != TAPE_SCHEMA_V1 {
        return Err(ApiError::UnsupportedVersion(format.to_owned()));
    }
    let bytes = serde_json::to_vec(value).map_err(|error| usage(&error.to_string()))?;
    pseudolearn_runtime::decode_effect_tape(&bytes).map_err(replay_error_to_api)
}
