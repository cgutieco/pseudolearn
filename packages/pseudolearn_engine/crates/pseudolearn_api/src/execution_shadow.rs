use super::{ExecutionResource, InputRequest, usage};
use crate::{ApiError, ExecuteRequest};
use pseudolearn_timeline::HistoricalEvent;
use pseudolearn_vm::{
    Fuel, Machine, create_owned_machine, machine_event_count, take_machine_events,
};
use serde_json::Value;

enum DriveOperation {
    Advance(usize),
    EffectResult(Value),
    Input(InputRequest, String),
}

#[derive(Default)]
pub(super) struct ShadowLog {
    request: Option<ExecuteRequest>,
    operations: Vec<DriveOperation>,
    deliveries: bool,
    history: Option<Vec<HistoricalEvent>>,
}

impl ShadowLog {
    pub(super) fn for_execution(request: &ExecuteRequest, recording: bool) -> Self {
        Self {
            request: recording.then(|| request.clone()),
            ..Self::default()
        }
    }

    fn is_active(&self) -> bool {
        self.request.is_some() && self.deliveries
    }

    pub(super) fn log_advance(&mut self, maximum: usize) {
        self.push(DriveOperation::Advance(maximum));
    }

    pub(super) fn log_effect_result(&mut self, arguments: &Value) {
        self.deliveries = true;
        self.push(DriveOperation::EffectResult(arguments.clone()));
    }

    pub(super) fn log_input(&mut self, reply: InputRequest, text: String) {
        self.push(DriveOperation::Input(reply, text));
    }

    fn push(&mut self, operation: DriveOperation) {
        if self.request.is_some() {
            self.operations.push(operation);
        }
    }

    pub(super) fn is_collecting(&self) -> bool {
        self.history.is_some()
    }

    pub(super) fn collect(&mut self, events: Vec<pseudolearn_vm::TraceEvent>, task: u64) {
        if let Some(history) = &mut self.history {
            history.extend(
                events
                    .into_iter()
                    .map(|event| HistoricalEvent { event, task }),
            );
        }
    }
}

impl ExecutionResource {
    pub(super) fn shadow_active(&self) -> bool {
        self.hosts.shadow.is_active()
            && self.debug.is_none()
            && !self.cancelled.load(std::sync::atomic::Ordering::Relaxed)
    }

    pub(super) fn shadow_machine(&self, event: usize) -> Result<Machine<'_>, ApiError> {
        let mut twin = self.twin_not_past(event.saturating_add(1))?;
        let mut options = self.options.clone();
        options.cancelled = None;
        let spare = create_owned_machine(self.program.clone(), Fuel::unlimited(), options.clone())
            .map_err(|trap| usage(trap.code))?;
        let image = pseudolearn_vm::suspend_machine(std::mem::replace(&mut twin.machine, spare));
        pseudolearn_vm::resume_machine(&self.program, image, options)
            .map_err(|_| usage("unreachable event"))
    }

    fn twin_not_past(&self, count: usize) -> Result<ExecutionResource, ApiError> {
        let mut target = count;
        loop {
            let twin = self.shadow_twin(target)?;
            if machine_event_count(&twin.machine) <= count || target == 0 {
                return Ok(twin);
            }
            target = target.saturating_sub(1);
        }
    }

    pub(super) fn shadow_window(
        &self,
        start: usize,
        end: usize,
    ) -> Result<Vec<HistoricalEvent>, ApiError> {
        let mut twin = self.shadow_twin(end)?;
        let history = twin.hosts.shadow.history.take().unwrap_or_default();
        Ok(history
            .into_iter()
            .skip(start)
            .take(end.saturating_sub(start))
            .collect())
    }

    fn shadow_twin(&self, target: usize) -> Result<ExecutionResource, ApiError> {
        let request = self
            .hosts
            .shadow
            .request
            .as_ref()
            .ok_or_else(|| usage("unreachable event"))?;
        let mut twin = Self::from_loaded(request, self.program.clone(), Vec::new())?;
        twin.set_resource_id(self.resource_id);
        twin.hosts.shadow = ShadowLog {
            history: Some(Vec::new()),
            ..ShadowLog::default()
        };
        for operation in &self.hosts.shadow.operations {
            let have = machine_event_count(&twin.machine);
            if have >= target {
                break;
            }
            match operation {
                DriveOperation::Advance(maximum) => {
                    twin.advance((*maximum).min(target.saturating_sub(have)))?;
                }
                DriveOperation::EffectResult(arguments) => twin.effect_result(arguments)?,
                DriveOperation::Input(reply, text) => twin.input(reply.clone(), text.clone())?,
            }
        }
        if machine_event_count(&twin.machine) < target {
            return Err(usage("unreachable event"));
        }
        Ok(twin)
    }

    pub(super) fn collect_step_events(&mut self, task: u64) {
        if self.hosts.shadow.is_collecting() {
            let events = take_machine_events(&mut self.machine);
            self.hosts.shadow.collect(events, task);
        }
    }
}
