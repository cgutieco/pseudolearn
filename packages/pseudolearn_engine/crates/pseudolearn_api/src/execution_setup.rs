use crate::{ApiError, ExecuteRequest, execution_resource::usage};
use pseudolearn_timeline::ExecutionMode;
use pseudolearn_vm::{Fuel, LoadedProgram, Machine, RunOptions, TwinMode, create_owned_machine};
use serde_json::Value;
use std::sync::{Arc, atomic::AtomicBool};

pub(super) struct PreparedExecution {
    pub network_limits: pseudolearn_runtime::NetworkLimits,
    pub execution_mode: ExecutionMode,
    pub effects: pseudolearn_runtime::EffectSession,
    pub host: crate::FakeHostProvider,
    pub detached_effects: bool,
    pub cancel_on_effect: Option<u64>,
    pub cancelled: Arc<AtomicBool>,
}

pub(super) struct InitializedMachine {
    pub program: LoadedProgram,
    pub machine: Machine<'static>,
    pub initial_state: Value,
    pub store: pseudolearn_timeline::CheckpointStore,
    pub options: RunOptions,
}

pub(super) fn prepare(
    request: &ExecuteRequest,
    program: LoadedProgram,
) -> Result<(PreparedExecution, InitializedMachine), ApiError> {
    let prepared = prepare_execution(request)?;
    let initialized = initialize_machine(request, program, &prepared)?;
    Ok((prepared, initialized))
}

fn prepare_execution(request: &ExecuteRequest) -> Result<PreparedExecution, ApiError> {
    crate::execution_prepare::validate_execution_limits(request)?;
    let network_limits = crate::execution_prepare::network_limits(request);
    let execution_mode = crate::tape_wire::parse_execution_mode(request.execution_mode.as_deref())?;
    crate::tape_wire::validate_replay_tape(request, execution_mode)?;
    let mut effects =
        crate::execution_resource::execution_effects::prepare_session(request, execution_mode)?;
    pseudolearn_runtime::configure_network_limits(&mut effects, network_limits);
    pseudolearn_runtime::configure_host_authority(&mut effects, request.host.as_ref())
        .map_err(|error| usage(error.code()))?;
    let host = crate::execution_resource::execution_effects::prepare_host(request, execution_mode)?;
    let detached_effects = host_setting(request, "detached")
        .and_then(Value::as_bool)
        .unwrap_or(false);
    let cancel_on_effect =
        host_setting(request, "cancel_on_awaiting_effect").and_then(Value::as_u64);
    Ok(PreparedExecution {
        network_limits,
        execution_mode,
        effects,
        host,
        detached_effects,
        cancel_on_effect,
        cancelled: Arc::new(AtomicBool::new(false)),
    })
}

fn host_setting<'request>(request: &'request ExecuteRequest, key: &str) -> Option<&'request Value> {
    request.host.as_ref()?.get(key)
}

fn initialize_machine(
    request: &ExecuteRequest,
    program: LoadedProgram,
    prepared: &PreparedExecution,
) -> Result<InitializedMachine, ApiError> {
    let mut options = crate::execution::options(request);
    options.twin_mode = TwinMode::Probed;
    options.cancelled = Some(prepared.cancelled.clone());
    let mut machine = create_owned_machine(program.clone(), Fuel::unlimited(), options.clone())
        .map_err(|trap| usage(trap.code))?;
    crate::execution_resource::execution_effects::configure_machine(
        &mut machine,
        request,
        &prepared.effects,
    );
    let (initial_state, store) = crate::execution_prepare::initial_checkpoint(&machine)?;
    Ok(InitializedMachine {
        program,
        machine,
        initial_state,
        store,
        options,
    })
}
