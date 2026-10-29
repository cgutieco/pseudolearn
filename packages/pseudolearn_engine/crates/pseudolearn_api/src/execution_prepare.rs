#![forbid(unsafe_code)]

use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::CheckpointStore;
use pseudolearn_vm::{LoadedProgram, Machine, load};
use serde_json::Value;

pub(crate) const CHECKPOINT_LIMIT: usize = 128;

pub(crate) fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}

pub(crate) fn validate_execution_limits(request: &ExecuteRequest) -> Result<(), ApiError> {
    if request.limits.max_json_depth == Some(0) {
        return Err(usage("max_json_depth must be positive"));
    }
    if !network_limits(request).has_positive_values() {
        return Err(usage("network limits must be positive"));
    }
    Ok(())
}

pub(crate) fn network_limits(request: &ExecuteRequest) -> pseudolearn_runtime::NetworkLimits {
    let defaults = pseudolearn_runtime::NetworkLimits::default();
    pseudolearn_runtime::NetworkLimits {
        body_bytes: request
            .limits
            .max_http_body_bytes
            .unwrap_or(defaults.body_bytes),
        wire_bytes: request
            .limits
            .max_http_wire_bytes
            .unwrap_or(defaults.wire_bytes),
        header_bytes: request
            .limits
            .max_http_header_bytes
            .unwrap_or(defaults.header_bytes),
        headers: request.limits.max_http_headers.unwrap_or(defaults.headers),
        pending: request
            .limits
            .max_pending_network
            .unwrap_or(defaults.pending),
        timeout_nanos: request
            .limits
            .max_http_timeout_nanos
            .unwrap_or(defaults.timeout_nanos),
    }
}

pub(crate) fn initial_checkpoint(
    machine: &Machine<'_>,
) -> Result<(Value, CheckpointStore), ApiError> {
    let state = crate::execution_state::capture(machine);
    let mut store = CheckpointStore::new(CHECKPOINT_LIMIT);
    store
        .record(machine, 0)
        .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
    Ok((state, store))
}

pub(crate) fn prepare_program_and_warnings(
    request: &ExecuteRequest,
) -> Result<(LoadedProgram, Vec<ApiDiagnostic>), ApiError> {
    validate_execution_limits(request)?;
    let (module, warnings) = crate::ir_execution::compile_source_with_identity(
        &request.program,
        &request.profile,
        &request.strictness,
        request.source,
    )
    .map_err(|_| usage("analysis has errors"))?;
    let bytecode = pseudolearn_bytecode::compile_module(&module)
        .map_err(|fault| ApiError::InternalFault(format!("{fault:?}")))?;
    let program = load(&bytecode).map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
    Ok((program, warnings))
}
