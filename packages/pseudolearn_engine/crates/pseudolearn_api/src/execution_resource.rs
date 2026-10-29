pub(crate) use crate::execution_prepare::{CHECKPOINT_LIMIT, prepare_program_and_warnings, usage};
use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_timeline::CheckpointStore;
use pseudolearn_vm::{
    LoadedProgram, Machine, RunExit, RunOptions, machine_event_count, take_machine_events,
};
use serde_json::{Value, json};
use std::collections::BTreeSet;
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
#[path = "execution_response.rs"]
mod execution_response;
#[path = "execution_setup.rs"]
mod execution_setup;

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
    network_limits: pseudolearn_runtime::NetworkLimits,
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
    cancel_on_effect: Option<u64>,
    pending_host: Option<pseudolearn_runtime::HostEffectRequest>,
    limit_rejected_network: BTreeSet<u64>,
    completing_effect: bool,
}

impl ExecutionResource {
    pub(crate) fn start(request: &ExecuteRequest) -> Result<Self, ApiError> {
        let (program, warnings) = prepare_program_and_warnings(request)?;
        Self::from_loaded(request, program, warnings)
    }

    pub(crate) fn from_loaded(
        request: &ExecuteRequest,
        program: LoadedProgram,
        warnings: Vec<ApiDiagnostic>,
    ) -> Result<Self, ApiError> {
        let (prepared, initialized) = execution_setup::prepare(request, program)?;
        Ok(Self::from_prepared(
            request,
            warnings,
            prepared,
            initialized,
        ))
    }

    fn from_prepared(
        request: &ExecuteRequest,
        warnings: Vec<ApiDiagnostic>,
        prepared: execution_setup::PreparedExecution,
        initialized: execution_setup::InitializedMachine,
    ) -> Self {
        Self {
            program: initialized.program,
            machine: initialized.machine,
            initial_state: initialized.initial_state,
            store: initialized.store,
            checkpoint_stride: CHECKPOINT_STRIDE,
            last_checkpoint_count: 0,
            retained_start: 0,
            options: initialized.options,
            network_limits: prepared.network_limits,
            terminal: None,
            delivered: 0,
            retained_events: usize::MAX,
            cancelled: prepared.cancelled,
            profile: request.profile.clone(),
            warnings,
            view: None,
            source: request.source,
            execution_mode: prepared.execution_mode,
            effects: prepared.effects,
            output_cursor: 0,
            input_cursor: 0,
            host: prepared.host,
            detached_effects: prepared.detached_effects,
            cancel_on_effect: prepared.cancel_on_effect,
            pending_host: None,
            completing_effect: false,
            limit_rejected_network: BTreeSet::new(),
        }
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
        self.settle_cancelled_suspension();
        if self.terminal.is_none() {
            self.drive_batch(maximum)?;
        }

        let mut response =
            execution_response::advance_response(execution_response::AdvanceResponseInput {
                machine: &self.machine,
                start: 0,
                terminal: self.terminal.as_ref(),
                profile: &self.profile,
                warnings: &self.warnings,
                view: self.view.as_ref(),
                source: self.source,
            });
        self.add_effect_observation(&mut response);
        self.delivered = machine_event_count(&self.machine);
        take_machine_events(&mut self.machine);
        if self.pending_host.is_none() {
            self.machine
                .set_effect_checkpoint(pseudolearn_runtime::capture_effect_checkpoint(
                    &self.effects,
                ));
            self.record_checkpoint()?;
        }
        self.trim_history()?;
        Ok(response)
    }

    fn add_effect_observation(&self, response: &mut Value) {
        let Some(fields) = response.as_object_mut() else {
            return;
        };
        fields.insert(
            "effect_tape".to_owned(),
            crate::tape_wire::tape_to_value(self.effects.tape()),
        );
        if let Some(pending) = &self.pending_host {
            fields.insert("pending_effect".to_owned(), json!(pending));
        }
        if let Some(list) = self.concurrent_pending_effects() {
            fields.insert("pending_effects".to_owned(), list);
        }
        fields.insert(
            "host_observation".to_owned(),
            json!({"calls":self.host.calls,"open_resources":self.host.live_resource_count()}),
        );
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
        let machine = pseudolearn_timeline::replay_machine_with_effects(
            &self.program,
            image,
            event,
            (&options, self.effects.tape()),
        )
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
