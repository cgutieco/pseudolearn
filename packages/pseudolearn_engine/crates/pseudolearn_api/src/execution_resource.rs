pub(crate) use crate::execution_prepare::{
    CHECKPOINT_LIMIT, initial_checkpoint, prepare_program_and_warnings, usage,
};
use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::CheckpointStore;
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

#[path = "execution_effects.rs"]
mod execution_effects;
#[path = "execution_host.rs"]
mod execution_host;

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
    effects: pseudolearn_runtime::EffectSession,
    output_cursor: usize,
    input_cursor: usize,
    host: crate::FakeHostProvider,
    detached_effects: bool,
    pending_host: Option<pseudolearn_runtime::HostEffectRequest>,
    completing_effect: bool,
}

impl ExecutionResource {
    pub(crate) fn start(request: &ExecuteRequest) -> Result<Self, ApiError> {
        let (program, warnings) = prepare_program_and_warnings(request)?;
        Self::from_loaded(request, program, warnings)
    }

    pub(crate) fn from_loaded(request: &ExecuteRequest, program: LoadedProgram, warnings: Vec<ApiDiagnostic>) -> Result<Self, ApiError> {
        let execution_mode =
            crate::tape_wire::parse_execution_mode(request.execution_mode.as_deref())?;
        crate::tape_wire::validate_replay_tape(request, execution_mode)?;
        let mut effects = execution_effects::prepare_session(request, execution_mode)?;
        pseudolearn_runtime::configure_host_authority(&mut effects, request.host.as_ref()).map_err(|error| usage(error.code()))?;
        let host = execution_effects::prepare_host(request, execution_mode)?;
        let detached_effects = request.host.as_ref().and_then(|host| host.get("detached")).and_then(Value::as_bool).unwrap_or(false);
        let cancelled = Arc::new(AtomicBool::new(false));
        let mut options = crate::execution::options(request);
        options.twin_mode = TwinMode::Probed;
        options.cancelled = Some(cancelled.clone());
        let mut machine = create_owned_machine(program.clone(), Fuel::unlimited(), options.clone())
            .map_err(|trap| usage(trap.code))?;
        machine.set_effect_checkpoint(pseudolearn_runtime::capture_effect_checkpoint(&effects));
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
            effects,
            output_cursor: 0, input_cursor: 0,
            host, detached_effects, pending_host: None, completing_effect: false,
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
            self.drive_batch(maximum)?;
        }

        let mut response = advance_response(AdvanceResponseInput {
            machine: &self.machine,
            start: 0,
            terminal: self.terminal.as_ref(),
            profile: &self.profile,
            warnings: &self.warnings,
            view: self.view.as_ref(),
            source: self.source,
        });
        if let Some(fields) = response.as_object_mut() {
            fields.insert("effect_tape".to_owned(), crate::tape_wire::tape_to_value(self.effects.tape()));
            if let Some(pending) = &self.pending_host { fields.insert("pending_effect".to_owned(), json!(pending)); }
            fields.insert("host_observation".to_owned(), json!({"calls":self.host.calls,"open_resources":self.host.live_resource_count()}));
        }
        self.delivered = machine_event_count(&self.machine);
        take_machine_events(&mut self.machine);
        if self.pending_host.is_none() {
            self.machine.set_effect_checkpoint(pseudolearn_runtime::capture_effect_checkpoint(&self.effects));
            self.record_checkpoint()?;
        }
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
        let machine = pseudolearn_timeline::replay_machine_with_effects(&self.program, image, event, (&options, self.effects.tape()))
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
