use pseudolearn_vm::{Machine, RunExit, machine_events, machine_output};
use serde_json::{Value, json};

pub(super) struct AdvanceResponseInput<'borrow, 'program> {
    pub machine: &'borrow Machine<'program>,
    pub start: usize,
    pub terminal: Option<&'borrow RunExit>,
    pub profile: &'borrow str,
    pub warnings: &'borrow [crate::ApiDiagnostic],
    pub view: Option<&'borrow crate::program_view::ProgramView>,
    pub source: Option<crate::ApiSourceIdentity>,
}

pub(super) fn advance_response(input: AdvanceResponseInput<'_, '_>) -> Value {
    let events = machine_events(input.machine)
        .get(input.start..)
        .unwrap_or_default()
        .iter()
        .map(|event| crate::execution_wire::event_with_source(event, input.view))
        .collect::<Vec<_>>();
    let termination = input
        .terminal
        .map(crate::execution_wire::termination)
        .unwrap_or(json!({"kind":"running"}));
    let mut diagnostics = input.warnings.to_vec();
    diagnostics.extend(
        input
            .machine
            .execution_diagnostics()
            .iter()
            .map(|trap| crate::execution_wire::diagnostic(trap, input.profile, input.source)),
    );
    if let Some(RunExit::Trap(trap)) = input.terminal {
        diagnostics.push(crate::execution_wire::diagnostic(
            trap,
            input.profile,
            input.source,
        ));
    }
    json!({"events":events,"output":machine_output(input.machine),"termination":termination,
        "inputs_consumed":input.machine.input_consumed_count(),"diagnostics":diagnostics})
}
