use super::ExecutionResource;
use pseudolearn_vm::{
    Machine, RunExit, machine_error_ranges, machine_events, machine_exit_code, machine_output,
};
use serde_json::{Value, json};

pub(super) struct AdvanceResponseInput<'borrow, 'program> {
    pub machine: &'borrow Machine<'program>,
    pub start: usize,
    pub terminal: Option<&'borrow RunExit>,
    pub profile: &'borrow str,
    pub warnings: &'borrow [crate::ApiDiagnostic],
    pub sources: &'borrow crate::execution_sources::ExecutionSources,
    pub source: Option<crate::ApiSourceIdentity>,
}

pub(super) fn advance_response(input: AdvanceResponseInput<'_, '_>) -> Value {
    let events = machine_events(input.machine)
        .get(input.start..)
        .unwrap_or_default()
        .iter()
        .map(|event| input.sources.event(event))
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
        "exit_code":machine_exit_code(input.machine),
        "error_ranges":machine_error_ranges(input.machine),
        "inputs_consumed":input.machine.input_consumed_count(),"diagnostics":diagnostics})
}

impl ExecutionResource {
    pub(super) fn tip_response(&self) -> Value {
        let mut response = advance_response(AdvanceResponseInput {
            machine: &self.machine,
            start: 0,
            terminal: self.terminal.as_ref(),
            profile: &self.profile,
            warnings: &self.warnings,
            sources: &self.sources,
            source: self.source,
        });
        if let Some(request) = &self.pending_input
            && let Some(fields) = response.as_object_mut()
        {
            fields.insert("pending_input".to_owned(), request.to_value());
        }
        response
    }

    pub(super) fn add_effect_observation(&self, response: &mut Value) {
        let Some(fields) = response.as_object_mut() else {
            return;
        };
        fields.insert(
            "effect_tape".to_owned(),
            crate::tape_wire::tape_to_value(self.effects.tape()),
        );
        if let Some(pending) = self.pending_host_value() {
            fields.insert("pending_effect".to_owned(), pending);
        }
        if let Some(list) = self.concurrent_pending_effects() {
            fields.insert("pending_effects".to_owned(), list);
        }
        fields.insert(
            "host_observation".to_owned(),
            json!({"calls":self.host.calls,"open_resources":self.host.live_resource_count()}),
        );
    }
}
