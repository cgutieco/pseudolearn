use crate::TimelineError;
use pseudolearn_runtime::{
    EffectRecord, EffectSession, EffectTape, HostEffectProvider, HostEffectRequest, HostReply,
    IoError, perform_host_effect,
};
use pseudolearn_vm::{
    LoadedProgram, Machine, MachineImage, PendingEffectRequest, RunExit, RunOptions,
    machine_event_count, machine_output, resume_machine,
};

pub fn replay_machine_with_effects<'program>(
    program: &'program LoadedProgram,
    image: MachineImage,
    target: usize,
    configuration: (&RunOptions, &EffectTape),
) -> Result<Machine<'program>, TimelineError> {
    let (options, tape) = configuration;
    let target_count = target.checked_add(1).ok_or(TimelineError::ReplayFailure)?;
    if image.state.event_count > target_count {
        return Err(TimelineError::ReplayFailure);
    }
    let mut effects = history_effects(&image, tape)?;
    let mut machine = resume_machine(program, image, options.clone())
        .map_err(|_| TimelineError::ReplayFailure)?;
    machine.replace_input_tape(options.inputs.clone());
    while machine_event_count(&machine) < target_count {
        let exit = machine.step_instruction();
        effects.observe(&machine, options)?;
        if let Some(RunExit::AwaitingEffect(pending)) = &exit {
            effects.resolve(&mut machine, pending)?;
        }
        let reached = machine_event_count(&machine) >= target_count;
        pseudolearn_vm::clear_machine_events(&mut machine);
        if reached {
            break;
        }
        if exit.is_some() && !matches!(exit, Some(RunExit::AwaitingEffect(_))) {
            return Err(TimelineError::ReplayFailure);
        }
    }
    if machine_event_count(&machine) != target_count {
        return Err(TimelineError::ReplayFailure);
    }
    Ok(machine)
}

fn history_effects(image: &MachineImage, tape: &EffectTape) -> Result<HistoryEffects, TimelineError> {
    let checkpoint = image
        .state
        .effect_checkpoint
        .as_deref()
        .cloned()
        .unwrap_or_default();
    let session = pseudolearn_runtime::replay_effect_checkpoint(tape, &checkpoint)
        .map_err(|_| TimelineError::ReplayFailure)?;
    Ok(HistoryEffects {
        session,
        output_cursor: image.state.output_length,
        input_cursor: image.state.input_index,
        completing: false,
    })
}

struct HistoryEffects {
    session: EffectSession,
    output_cursor: usize,
    input_cursor: usize,
    completing: bool,
}

impl HistoryEffects {
    fn observe(
        &mut self,
        machine: &Machine<'_>,
        options: &RunOptions,
    ) -> Result<(), TimelineError> {
        let output = machine_output(machine);
        if !self.completing
            && let Some(text) = output
                .get(self.output_cursor..)
                .filter(|text| !text.is_empty())
        {
            self.session
                .resolve(
                    console("write", text.as_bytes().to_vec()),
                    text.as_bytes().to_vec(),
                    "committed",
                )
                .map_err(|_| TimelineError::ReplayFailure)?;
        }
        self.output_cursor = output.len();
        self.completing = false;
        while self.input_cursor < machine.input_consumed_count() {
            let input = options
                .inputs
                .get(self.input_cursor)
                .ok_or(TimelineError::ReplayFailure)?;
            self.session
                .resolve(
                    console("read", Vec::new()),
                    input.as_bytes().to_vec(),
                    "committed",
                )
                .map_err(|_| TimelineError::ReplayFailure)?;
            self.input_cursor = self.input_cursor.saturating_add(1);
        }
        Ok(())
    }

    fn resolve(
        &mut self,
        machine: &mut Machine<'_>,
        request: &PendingEffectRequest,
    ) -> Result<(), TimelineError> {
        let operation = pseudolearn_runtime::effect_operation(&request.operation)
            .ok_or(TimelineError::ReplayFailure)?;
        let mut disconnected = DisconnectedHost { calls: 0 };
        let reply = perform_host_effect(
            &mut self.session,
            &mut disconnected,
            operation,
            (
                request.receiver.clone(),
                request.arguments.clone(),
                request.source_node_id.ok_or(TimelineError::ReplayFailure)?,
            ),
        )
        .map_err(|_| TimelineError::ReplayFailure)?;
        if disconnected.calls != 0 {
            return Err(TimelineError::ReplayFailure);
        }
        machine.supply_effect_result(reply);
        self.completing = true;
        Ok(())
    }
}

struct DisconnectedHost {
    calls: usize,
}

impl HostEffectProvider for DisconnectedHost {
    fn perform(&mut self, _request: &HostEffectRequest) -> HostReply {
        self.calls = self.calls.saturating_add(1);
        HostReply::failure(IoError::permission_denied())
    }
    fn close_all(&mut self) {}
}

fn console(operation: &str, arguments: Vec<u8>) -> EffectRecord {
    EffectRecord {
        capability_kind: "console".to_owned(),
        operation: operation.to_owned(),
        arguments,
        source_node_id: 0,
    }
}
