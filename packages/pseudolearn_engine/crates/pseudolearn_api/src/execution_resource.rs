use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::{CheckpointStore, replay_machine_to_event};
use pseudolearn_vm::{
    Fuel, LoadedProgram, Machine, RunExit, RunOptions, TwinMode, create_owned_machine, load,
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
const CHECKPOINT_LIMIT: usize = 128;

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
}

impl ExecutionResource {
    pub(crate) fn start(request: &ExecuteRequest) -> Result<Self, ApiError> {
        let (module, warnings) = crate::ir_execution::compile_source_with_warnings(
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
        let machine = create_owned_machine(program.clone(), Fuel::unlimited(), options.clone())
            .map_err(|trap| usage(trap.code))?;
        let initial_state = crate::execution_state::capture(&machine);
        let mut store = CheckpointStore::new(CHECKPOINT_LIMIT);
        store
            .record(&machine, 0)
            .map_err(|error| ApiError::InternalFault(format!("{error:?}")))?;
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
        let response = advance_response(
            &self.machine,
            (0, self.terminal.as_ref()),
            (&self.profile, &self.warnings),
            self.view.as_ref(),
        );
        self.delivered = machine_event_count(&self.machine);
        take_machine_events(&mut self.machine);
        self.record_checkpoint()?;
        self.trim_history()?;
        Ok(response)
    }

    pub(crate) fn input(&mut self, text: String) -> Result<(), ApiError> {
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

fn advance_response(
    machine: &Machine<'_>,
    (start, terminal): (usize, Option<&RunExit>),
    (profile, warnings): (&str, &[ApiDiagnostic]),
    view: Option<&crate::program_view::ProgramView>,
) -> Value {
    let events: Vec<_> = machine_events(machine)
        .get(start..)
        .unwrap_or_default()
        .iter()
        .map(|event| crate::execution_wire::event_with_source(event, view))
        .collect();
    let termination = terminal
        .map(crate::execution_wire::termination)
        .unwrap_or(json!({"kind":"running"}));
    let mut diagnostics: Vec<_> = warnings.to_vec();
    diagnostics.extend(
        machine
            .execution_diagnostics()
            .iter()
            .map(|trap| crate::execution_wire::diagnostic(trap, profile)),
    );
    if let Some(RunExit::Trap(trap)) = terminal {
        diagnostics.push(crate::execution_wire::diagnostic(trap, profile));
    }
    json!({"events":events,"output":machine_output(machine),"termination":termination,
        "inputs_consumed":machine.input_consumed_count(),"diagnostics":diagnostics})
}

pub(crate) fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}
