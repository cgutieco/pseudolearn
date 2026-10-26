pub(crate) use crate::execution_prepare::{
    CHECKPOINT_LIMIT, initial_checkpoint, prepare_program_and_warnings, usage,
};
use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::{CheckpointStore, replay_machine_to_event};
use pseudolearn_vm::{
    Fuel, LoadedProgram, Machine, RunExit, RunOptions, TwinMode, create_owned_machine,
    machine_event_count, machine_events, machine_output, take_machine_events,
};
use serde_json::{Value, json};
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
};

#[cfg(test)]
#[path = "execution_resource_tests.rs"]
mod execution_resource_tests;

const CHECKPOINT_STRIDE: usize = 256;

pub(crate) struct ExecutionResource {
    program: LoadedProgram,
    machine: Machine<'static>,
    initial_state: Value,
    store: CheckpointStore,
    checkpoint_stride: usize,
    last_checkpoint_count: usize,
    retained_start: usize,
    options: RunOptions,
    terminal: Option<RunExit>,
    delivered: usize,
    retained_events: usize,
    cancelled: Arc<AtomicBool>,
    profile: String,
    warnings: Vec<ApiDiagnostic>,
    view: Option<crate::program_view::ProgramView>,
    source: Option<crate::ApiSourceIdentity>,
    execution_mode: pseudolearn_timeline::ExecutionMode,
}

impl ExecutionResource {
    pub(crate) fn start(request: &ExecuteRequest) -> Result<Self, ApiError> {
        let execution_mode =
            crate::tape_wire::parse_execution_mode(request.execution_mode.as_deref())?;
        crate::tape_wire::validate_replay_tape(request, execution_mode)?;
        let (program, warnings) = prepare_program_and_warnings(request)?;
        let cancelled = Arc::new(AtomicBool::new(false));
        let mut options = crate::execution::options(request);
        options.twin_mode = TwinMode::Probed;
        options.cancelled = Some(cancelled.clone());
        let machine = create_owned_machine(program.clone(), Fuel::unlimited(), options.clone())
            .map_err(|trap| usage(trap.code))?;
        let (initial_state, store) = initial_checkpoint(&machine)?;
        Ok(Self {
            program,
            machine,
            initial_state,
            store,
            checkpoint_stride: CHECKPOINT_STRIDE,
            last_checkpoint_count: 0,
            retained_start: 0,
            options,
            terminal: None,
            delivered: 0,
            retained_events: usize::MAX,
            cancelled,
            profile: request.profile.clone(),
            warnings,
            view: None,
            source: request.source,
            execution_mode,
        })
    }

    pub(crate) fn use_locale(&mut self, locale: String) {
        self.profile = locale;
    }

    pub(crate) fn attach_view(&mut self, view: crate::program_view::ProgramView) {
        self.view = Some(view);
    }

    pub(crate) fn advance(&mut self, maximum: usize) -> Result<Value, ApiError> {
        if maximum == 0 {
            return Err(usage("batch size must be positive"));
        }
        if self.terminal.is_none() {
            let initial_count = machine_event_count(&self.machine);
            loop {
                if let Some(exit) = self.machine.step_instruction() {
                    self.terminal = Some(exit);
                    break;
                }
                let emitted = machine_event_count(&self.machine).saturating_sub(initial_count);
                if emitted >= maximum {
                    break;
                }
            }
        }
        let response = advance_response(AdvanceResponseInput {
            machine: &self.machine,
            start: 0,
            terminal: self.terminal.as_ref(),
            profile: &self.profile,
            warnings: &self.warnings,
            view: self.view.as_ref(),
            source: self.source,
        });
        self.delivered = machine_event_count(&self.machine);
        take_machine_events(&mut self.machine);
        self.record_checkpoint()?;
        self.trim_history()?;
        Ok(response)
    }

    pub(crate) fn input(&mut self, text: String) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external input rejected in replay or seek mode"));
        }
        if !matches!(self.terminal, Some(RunExit::AwaitingInput)) {
            return Err(usage("execution is not awaiting input"));
        }
        self.options.inputs.push(text.clone());
        self.machine.supply_input(text);
        self.terminal = None;
        Ok(())
    }

    pub(crate) fn effect_result(&mut self, result: Value) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external effect result rejected in replay mode"));
        }
        if !matches!(self.terminal, Some(RunExit::AwaitingEffect(_))) {
            return Err(usage("execution is not awaiting effect"));
        }
        let runtime_value = match result {
            Value::Number(number) => {
                if let Some(integer_payload) = number.as_i64() {
                    pseudolearn_vm::RuntimeValue::Scalar(u64::from_ne_bytes(integer_payload.to_ne_bytes()))
                } else if let Some(floating_payload) = number.as_f64() {
                    pseudolearn_vm::RuntimeValue::Scalar(u64::from_ne_bytes(floating_payload.to_ne_bytes()))
                } else {
                    pseudolearn_vm::RuntimeValue::Scalar(0)
                }
            }
            Value::Bool(boolean_payload) => {
                pseudolearn_vm::RuntimeValue::Scalar(u64::from(boolean_payload))
            }
            _ => pseudolearn_vm::RuntimeValue::Scalar(0),
        };
        self.machine.supply_effect_result(runtime_value);
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

    pub(crate) fn query_page(&self, arguments: &Value, scope: &str) -> Result<Value, ApiError> {
        let request = crate::state_pages::PageRequest::parse(arguments)?;
        let revision = self.view.as_ref().map_or("", |view| view.revision());
        let machine = self.machine_at(request.event)?;
        crate::state_pages::page(&machine, &request, &format!("{scope}|{revision}"))
    }

    pub(crate) fn horizon(&self) -> Value {
        let first = self.retained_start.max(self.store.stats().horizon);
        json!({"first":first,"last":self.delivered.saturating_sub(1)})
    }

    pub(crate) fn configure_retention(&mut self, events: usize) -> Result<(), ApiError> {
        if events == 0 {
            return Err(usage("retention must be positive"));
        }
        self.retained_events = events;
        self.trim_history()
    }

    pub(crate) fn initial_state(&self) -> Result<Value, ApiError> {
        Ok(self.initial_state.clone())
    }

    fn record_checkpoint(&mut self) -> Result<(), ApiError> {
        let event_count = machine_event_count(&self.machine);
        if event_count
            < self
                .last_checkpoint_count
                .saturating_add(self.checkpoint_stride)
        {
            return Ok(());
        }
        self.store
            .record(&self.machine, event_count.saturating_sub(1))
            .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
        self.last_checkpoint_count = event_count;
        self.retained_start = self.retained_start.max(self.store.stats().horizon);
        Ok(())
    }

    fn machine_at(&self, event: usize) -> Result<Machine<'_>, ApiError> {
        if event >= self.delivered || event < self.retained_start.max(self.store.stats().horizon) {
            return Err(usage("event outside retained horizon"));
        }
        let (image, _) = self
            .store
            .image_at(event)
            .map_err(|_| usage("event outside retained horizon"))?;
        let mut options = self.options.clone();
        options.cancelled = None;
        let machine = replay_machine_to_event(&self.program, image, event, &options)
            .map_err(|_| usage("unreachable event"))?;
        Ok(machine)
    }

    fn trim_history(&mut self) -> Result<(), ApiError> {
        let first = self.delivered.saturating_sub(self.retained_events);
        if first > self.retained_start {
            let base = self.machine_at(first)?;
            let mut store = CheckpointStore::new(CHECKPOINT_LIMIT);
            store
                .record(&base, first)
                .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
            let latest = self.delivered.saturating_sub(1);
            if latest > first {
                store
                    .record(&self.machine, latest)
                    .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
            }
            self.store = store;
            self.retained_start = first;
            self.last_checkpoint_count = self.delivered;
        }
        Ok(())
    }
}

struct AdvanceResponseInput<'borrow, 'program> {
    machine: &'borrow Machine<'program>,
    start: usize,
    terminal: Option<&'borrow RunExit>,
    profile: &'borrow str,
    warnings: &'borrow [ApiDiagnostic],
    view: Option<&'borrow crate::program_view::ProgramView>,
    source: Option<crate::ApiSourceIdentity>,
}

fn advance_response(input: AdvanceResponseInput<'_, '_>) -> Value {
    let events: Vec<_> = machine_events(input.machine)
        .get(input.start..)
        .unwrap_or_default()
        .iter()
        .map(|event| crate::execution_wire::event_with_source(event, input.view))
        .collect();
    let termination = input
        .terminal
        .map(crate::execution_wire::termination)
        .unwrap_or(json!({"kind":"running"}));
    let mut diagnostics: Vec<_> = input.warnings.to_vec();
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
