use crate::{ExecuteRequest, ExecuteResponse, compile_source_to_module};
use pseudolearn_runtime::{CollectionPolicy, MemoryOptions};
use pseudolearn_vm::{
    Fuel, Machine, RunExit, RunOptions, TwinMode, create_machine, load, machine_events,
    machine_output,
};
use serde_json::json;

pub fn execute_program(request: &ExecuteRequest) -> ExecuteResponse {
    match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| execute(request))) {
        Ok(response) => response,
        Err(_) => rejected(crate::diagnostic_conversion::internal_fault().diagnostics),
    }
}

fn execute(request: &ExecuteRequest) -> ExecuteResponse {
    let prepared = match prepare_program(request) {
        Ok(prepared) => prepared,
        Err(diagnostics) => return rejected(diagnostics),
    };
    execute_prepared(&prepared, request)
}

pub struct PreparedProgram {
    program: pseudolearn_vm::LoadedProgram,
}

pub fn prepare_program(
    request: &ExecuteRequest,
) -> Result<PreparedProgram, Vec<crate::ApiDiagnostic>> {
    let module = compile_source_to_module(&request.program, &request.profile, &request.strictness)?;
    let bytecode = pseudolearn_bytecode::compile_module(&module)
        .map_err(|_| crate::diagnostic_conversion::internal_fault().diagnostics)?;
    let program =
        load(&bytecode).map_err(|_| crate::diagnostic_conversion::internal_fault().diagnostics)?;
    Ok(PreparedProgram { program })
}

pub fn execute_prepared(prepared: &PreparedProgram, request: &ExecuteRequest) -> ExecuteResponse {
    let program = &prepared.program;
    if request.state_at.is_none() {
        return execute_bulk(program, request);
    }
    let options = options(request);
    let mut machine = match create_machine(program, Fuel::unlimited(), options) {
        Ok(machine) => machine,
        Err(trap) => return failure(&trap, &request.profile),
    };
    run_request(&mut machine, request)
}

pub(crate) fn run_request(machine: &mut Machine<'_>, request: &ExecuteRequest) -> ExecuteResponse {
    let mut state_at = None;
    let maximum = u64::MAX;
    let mut exit = RunExit::LimitReached {
        kind: pseudolearn_vm::LimitKind::Time,
    };
    let mut previous_count = 0;
    for _ in 0..maximum {
        let outcome = machine.step_instruction();
        let count = machine_events(machine).len();
        if request.state_at == Some(count.saturating_sub(1)) && count > previous_count {
            state_at = Some(crate::execution_state::capture(machine));
        }
        previous_count = count;
        if let Some(outcome) = outcome {
            exit = outcome;
            break;
        }
    }
    ExecuteResponse {
        kind: "execute".to_owned(),
        output: machine_output(machine).to_owned(),
        termination: crate::execution_wire::termination(&exit),
        diagnostics: diagnostics(machine, &exit, &request.profile),
        events: if request.observe == "events" {
            machine_events(machine)
                .iter()
                .map(crate::execution_wire::event)
                .collect()
        } else {
            Vec::new()
        },
        inputs_consumed: machine.input_consumed_count(),
        state_at,
    }
}

pub(crate) fn options(request: &ExecuteRequest) -> RunOptions {
    let defaults = RunOptions::default();
    let observed = request.observe == "events"
        || request.state_at.is_some()
        || request.cancel_at_statement.is_some()
        || request.cancel_at_poll.is_some()
        || request.limits.statements.is_some();
    RunOptions {
        seed: request.seed,
        depth: request.limits.depth.unwrap_or(defaults.depth),
        memory: MemoryOptions {
            cells: request.limits.cells.unwrap_or(defaults.memory.cells),
            collection: if request.gc_stress {
                CollectionPolicy::Forced
            } else {
                CollectionPolicy::Automatic
            },
        },
        inputs: request.inputs.clone(),
        statement_limit: request.limits.statements,
        cancel_at_statement: request.cancel_at_statement,
        cancel_at_poll: request.cancel_at_poll,
        twin_mode: if observed {
            TwinMode::Probed
        } else {
            TwinMode::Fast
        },
        ..defaults
    }
}

fn diagnostics(machine: &Machine<'_>, exit: &RunExit, locale: &str) -> Vec<crate::ApiDiagnostic> {
    let mut diagnostics: Vec<_> = machine
        .execution_diagnostics()
        .iter()
        .map(|trap| crate::execution_wire::diagnostic(trap, locale))
        .collect();
    if let RunExit::Trap(trap) = exit {
        diagnostics.push(crate::execution_wire::diagnostic(trap, locale));
    }
    diagnostics
}

fn rejected(diagnostics: Vec<crate::ApiDiagnostic>) -> ExecuteResponse {
    ExecuteResponse {
        kind: "execute".to_owned(),
        output: String::new(),
        termination: json!({"kind":"failed","code":"analysisFailed"}),
        diagnostics,
        events: Vec::new(),
        inputs_consumed: 0,
        state_at: None,
    }
}

fn failure(trap: &pseudolearn_vm::VmTrap, locale: &str) -> ExecuteResponse {
    let mut response = rejected(vec![crate::execution_wire::diagnostic(trap, locale)]);
    response.termination = json!({"kind":"failed","code":trap.code});
    response
}

fn execute_bulk(
    program: &pseudolearn_vm::LoadedProgram,
    request: &ExecuteRequest,
) -> ExecuteResponse {
    let result = pseudolearn_vm::run_with_options(program, Fuel::unlimited(), options(request));
    let mut diagnostics: Vec<_> = result
        .diagnostics
        .iter()
        .map(|trap| crate::execution_wire::diagnostic(trap, &request.profile))
        .collect();
    if let RunExit::Trap(trap) = &result.exit {
        diagnostics.push(crate::execution_wire::diagnostic(trap, &request.profile));
    }
    ExecuteResponse {
        kind: "execute".to_owned(),
        output: result.output,
        termination: crate::execution_wire::termination(&result.exit),
        diagnostics,
        events: if request.observe == "events" {
            result
                .events
                .iter()
                .map(crate::execution_wire::event)
                .collect()
        } else {
            Vec::new()
        },
        inputs_consumed: result.inputs_consumed,
        state_at: None,
    }
}
