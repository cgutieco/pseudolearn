use crate::{ApiDiagnostic, ExecuteRequest, ExecuteResponse};
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
    warnings: Vec<ApiDiagnostic>,
}

pub fn prepare_program(
    request: &ExecuteRequest,
) -> Result<PreparedProgram, Vec<crate::ApiDiagnostic>> {
    let (module, warnings) = crate::ir_execution::compile_source_with_identity(
        &request.program,
        &request.profile,
        &request.strictness,
        request.source,
    )?;
    let bytecode = pseudolearn_bytecode::compile_module(&module)
        .map_err(|_| crate::diagnostic_conversion::internal_fault().diagnostics)?;
    let program =
        load(&bytecode).map_err(|_| crate::diagnostic_conversion::internal_fault().diagnostics)?;
    Ok(PreparedProgram { program, warnings })
}

pub fn execute_prepared(prepared: &PreparedProgram, request: &ExecuteRequest) -> ExecuteResponse {
    let program = &prepared.program;
    let warnings = &prepared.warnings;
    if request.state_at.is_none() && request.state_page.is_none() {
        return execute_bulk(program, warnings, request);
    }
    let options = options(request);
    let mut machine = match create_machine(program, Fuel::unlimited(), options) {
        Ok(machine) => machine,
        Err(trap) => {
            let mut response = failure(&trap, &request.profile, request.source);
            response.diagnostics = with_compile_warnings(warnings, response.diagnostics);
            return response;
        }
    };
    run_request(&mut machine, request, warnings)
}

pub(crate) fn run_request(
    machine: &mut Machine<'_>,
    request: &ExecuteRequest,
    warnings: &[ApiDiagnostic],
) -> ExecuteResponse {
    let captured = crate::execution_capture::run_capturing(machine, request);
    let page_failed = request.state_page.is_some() && !matches!(captured.page, Some(Ok(_)));
    let state_at = match captured.page {
        Some(Ok(page)) => Some(page),
        _ => captured.state,
    };
    let exit = captured.exit;
    let view = event_view(request);
    ExecuteResponse {
        kind: "execute".to_owned(),
        output: machine_output(machine).to_owned(),
        termination: if page_failed {
            json!({"kind":"failed","code":"usage"})
        } else {
            crate::execution_wire::termination(&exit)
        },
        diagnostics: with_compile_warnings(
            warnings,
            diagnostics(machine, &exit, &request.profile, request.source),
        ),
        events: if request.observe == "events" {
            machine_events(machine)
                .iter()
                .map(|event| crate::execution_wire::event_with_source(event, view.as_ref()))
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
            collection_minimum: defaults.memory.collection_minimum,
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

fn diagnostics(
    machine: &Machine<'_>,
    exit: &RunExit,
    locale: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> Vec<crate::ApiDiagnostic> {
    let mut diagnostics: Vec<_> = machine
        .execution_diagnostics()
        .iter()
        .map(|trap| crate::execution_wire::diagnostic(trap, locale, source))
        .collect();
    if let RunExit::Trap(trap) = exit {
        diagnostics.push(crate::execution_wire::diagnostic(trap, locale, source));
    }
    diagnostics
}

fn with_compile_warnings(
    warnings: &[ApiDiagnostic],
    diagnostics: Vec<ApiDiagnostic>,
) -> Vec<ApiDiagnostic> {
    let mut combined = warnings.to_vec();
    combined.extend(diagnostics);
    combined
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

fn failure(
    trap: &pseudolearn_vm::VmTrap,
    locale: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> ExecuteResponse {
    let mut response = rejected(vec![crate::execution_wire::diagnostic(
        trap, locale, source,
    )]);
    response.termination = json!({"kind":"failed","code":trap.code});
    response
}

fn execute_bulk(
    program: &pseudolearn_vm::LoadedProgram,
    warnings: &[ApiDiagnostic],
    request: &ExecuteRequest,
) -> ExecuteResponse {
    let result = pseudolearn_vm::run_with_options(program, Fuel::unlimited(), options(request));
    let mut diagnostics: Vec<_> = result
        .diagnostics
        .iter()
        .map(|trap| crate::execution_wire::diagnostic(trap, &request.profile, request.source))
        .collect();
    if let RunExit::Trap(trap) = &result.exit {
        diagnostics.push(crate::execution_wire::diagnostic(
            trap,
            &request.profile,
            request.source,
        ));
    }
    let diagnostics = with_compile_warnings(warnings, diagnostics);
    let view = event_view(request);
    ExecuteResponse {
        kind: "execute".to_owned(),
        output: result.output,
        termination: crate::execution_wire::termination(&result.exit),
        diagnostics,
        events: if request.observe == "events" {
            result
                .events
                .iter()
                .map(|event| crate::execution_wire::event_with_source(event, view.as_ref()))
                .collect()
        } else {
            Vec::new()
        },
        inputs_consumed: result.inputs_consumed,
        state_at: None,
    }
}

fn event_view(request: &ExecuteRequest) -> Option<crate::program_view::ProgramView> {
    if request.observe != "events" {
        return None;
    }
    let analysis = crate::AnalyzeRequest {
        program: request.program.clone(),
        profile: request.profile.clone(),
        strictness: request.strictness.clone(),
        source: request.source,
    };
    crate::program_view::ProgramView::build(&analysis, "rev0".to_owned()).ok()
}
