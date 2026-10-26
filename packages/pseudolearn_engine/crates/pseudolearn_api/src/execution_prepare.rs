#![forbid(unsafe_code)]

use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::CheckpointStore;
use pseudolearn_vm::{LoadedProgram, Machine, load};
use serde_json::Value;

pub(crate) const CHECKPOINT_LIMIT: usize = 128;

pub(crate) fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
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
