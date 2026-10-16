use crate::{ApiError, ExecuteRequest};
use pseudolearn_vm::{
    Fuel, LoadedProgram, Machine, MachineImage, RunExit, RunOptions, TwinMode, create_machine,
    load, machine_events, machine_output, resume_machine, suspend_machine, take_machine_events,
};
use serde_json::{Value, json};
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
};

const CHECKPOINT_STRIDE: usize = 256;
const CHECKPOINT_LIMIT: usize = 128;

pub(crate) struct ExecutionResource {
    program: LoadedProgram,
    image: Option<MachineImage>,
    initial: Arc<MachineImage>,
    replay_base: Arc<MachineImage>,
    checkpoints: Vec<(usize, Arc<MachineImage>)>,
    checkpoint_stride: usize,
    retained_start: usize,
    options: RunOptions,
    terminal: Option<RunExit>,
    delivered: usize,
    retained_events: usize,
    cancelled: Arc<AtomicBool>,
    profile: String,
}

impl ExecutionResource {
    pub(crate) fn start(request: &ExecuteRequest) -> Result<Self, ApiError> {
        let module = crate::compile_source_to_module(
            &request.program,
            &request.profile,
            &request.strictness,
        )
        .map_err(|_| usage("analysis has errors"))?;
        let bytecode = pseudolearn_bytecode::compile_module(&module)
            .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
        let program =
            load(&bytecode).map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
        let cancelled = Arc::new(AtomicBool::new(false));
        let mut options = crate::execution::options(request);
        options.twin_mode = TwinMode::Probed;
        options.cancelled = Some(cancelled.clone());
        let machine = create_machine(&program, Fuel::unlimited(), options.clone())
            .map_err(|trap| usage(trap.code))?;
        let image = suspend_machine(machine);
        let shared = Arc::new(image.clone());
        Ok(Self {
            program,
            initial: shared.clone(),
            replay_base: shared,
            checkpoints: Vec::new(),
            checkpoint_stride: CHECKPOINT_STRIDE,
            retained_start: 0,
            image: Some(image),
            options,
            terminal: None,
            delivered: 0,
            retained_events: usize::MAX,
            cancelled,
            profile: request.profile.clone(),
        })
    }

    pub(crate) fn advance(&mut self, maximum: usize) -> Result<Value, ApiError> {
        if maximum == 0 {
            return Err(usage("batch size must be positive"));
        }
        let image = self
            .image
            .take()
            .ok_or_else(|| usage("execution unavailable"))?;
        let mut machine = resume_machine(&self.program, image, self.options.clone())
            .map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
        if self.terminal.is_none() {
            loop {
                if let Some(exit) = machine.step_instruction() {
                    self.terminal = Some(exit);
                    break;
                }
                if machine_events(&machine).len() >= maximum {
                    break;
                }
            }
        }
        let response = advance_response(&machine, 0, self.terminal.as_ref(), &self.profile);
        self.delivered = self
            .delivered
            .checked_add(take_machine_events(&mut machine).len())
            .ok_or_else(|| usage("event counter exhausted"))?;
        let suspended = suspend_machine(machine);
        self.record_checkpoint(&suspended);
        self.image = Some(suspended);
        self.trim_history()?;
        Ok(response)
    }

    pub(crate) fn input(&mut self, text: String) -> Result<(), ApiError> {
        if !matches!(self.terminal, Some(RunExit::AwaitingInput)) {
            return Err(usage("execution is not awaiting input"));
        }
        self.options.inputs.push(text.clone());
        let image = self
            .image
            .take()
            .ok_or_else(|| usage("execution unavailable"))?;
        let mut machine = resume_machine(&self.program, image, self.options.clone())
            .map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
        machine.supply_input(text);
        self.image = Some(suspend_machine(machine));
        self.terminal = None;
        Ok(())
    }

    pub(crate) fn cancel(&self) {
        self.cancelled.store(true, Ordering::Relaxed);
    }

    pub(crate) fn state(&self, event: usize) -> Result<Value, ApiError> {
        let machine = self.machine_at(event)?;
        Ok(crate::execution_state::capture(&machine))
    }

    pub(crate) fn query(
        &self,
        event: usize,
        operation: &str,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        crate::execution_state::query(&self.machine_at(event)?, operation, arguments)
    }

    pub(crate) fn horizon(&self) -> Value {
        json!({"first":self.retained_start,"last":self.delivered.saturating_sub(1)})
    }

    pub(crate) fn configure_retention(&mut self, events: usize) -> Result<(), ApiError> {
        if events == 0 {
            return Err(usage("retention must be positive"));
        }
        self.retained_events = events;
        self.trim_history()
    }

    pub(crate) fn initial_state(&self) -> Result<Value, ApiError> {
        let machine = resume_machine(&self.program, (*self.initial).clone(), self.options.clone())
            .map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
        Ok(crate::execution_state::capture(&machine))
    }

    fn machine_at(&self, event: usize) -> Result<Machine<'_>, ApiError> {
        if event >= self.delivered || event < self.retained_start {
            return Err(usage("event outside retained horizon"));
        }
        self.replay_to_count(event.checked_add(1).ok_or_else(|| usage("invalid event"))?)
    }

    fn record_checkpoint(&mut self, image: &MachineImage) {
        let last = self
            .checkpoints
            .last()
            .map_or(self.retained_start, |(count, _)| *count);
        if self.delivered < last.saturating_add(self.checkpoint_stride) {
            return;
        }
        self.checkpoints
            .push((self.delivered, Arc::new(image.clone())));
        if self.checkpoints.len() > CHECKPOINT_LIMIT {
            let mut position = 0_usize;
            self.checkpoints.retain(|_| {
                position = position.saturating_add(1);
                position % 2 == 1
            });
            self.checkpoint_stride = self.checkpoint_stride.saturating_mul(2);
        }
    }

    fn replay_start(&self, target: usize) -> (usize, Arc<MachineImage>) {
        self.checkpoints
            .iter()
            .rev()
            .find(|(count, _)| *count < target && *count >= self.retained_start)
            .map_or_else(
                || (self.retained_start, self.replay_base.clone()),
                |(count, image)| (*count, image.clone()),
            )
    }

    fn replay_to_count(&self, target: usize) -> Result<Machine<'_>, ApiError> {
        let mut options = self.options.clone();
        options.cancelled = None;
        let (start, image) = self.replay_start(target);
        let mut machine = resume_machine(&self.program, (*image).clone(), options)
            .map_err(|trap| ApiError::InternalFault(trap.code.to_owned()))?;
        machine.replace_input_tape(self.options.inputs.clone());
        let mut count = start;
        while count < target {
            let exit = machine.step_instruction();
            count = count
                .checked_add(take_machine_events(&mut machine).len())
                .ok_or_else(|| usage("event counter exhausted"))?;
            if exit.is_some() && count < target {
                return Err(usage("unreachable event"));
            }
        }
        Ok(machine)
    }

    fn trim_history(&mut self) -> Result<(), ApiError> {
        let first = self.delivered.saturating_sub(self.retained_events);
        if first > self.retained_start {
            let machine = self.replay_to_count(first)?;
            let base = suspend_machine(machine);
            self.replay_base = Arc::new(base);
            self.retained_start = first;
            self.checkpoints.retain(|(count, _)| *count >= first);
        }
        Ok(())
    }
}

fn advance_response(
    machine: &Machine<'_>,
    start: usize,
    terminal: Option<&RunExit>,
    profile: &str,
) -> Value {
    let events: Vec<_> = machine_events(machine)
        .get(start..)
        .unwrap_or_default()
        .iter()
        .map(crate::execution_wire::event)
        .collect();
    let termination = terminal
        .map(crate::execution_wire::termination)
        .unwrap_or(json!({"kind":"running"}));
    let mut diagnostics: Vec<_> = machine
        .execution_diagnostics()
        .iter()
        .map(|trap| crate::execution_wire::diagnostic(trap, profile))
        .collect();
    if let Some(RunExit::Trap(trap)) = terminal {
        diagnostics.push(crate::execution_wire::diagnostic(trap, profile));
    }
    json!({"events":events,"output":machine_output(machine),"termination":termination,
        "inputs_consumed":machine.input_consumed_count(),"diagnostics":diagnostics})
}

pub(crate) fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}
