use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_vm::{Machine, RunExit, RunOptions};
use serde_json::Value;
use std::sync::atomic::Ordering;

impl ExecutionResource {
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
        let machine =
            self.inspection_machine(event, arguments.get("task_id").and_then(Value::as_u64))?;
        crate::execution_state::query(&machine, operation, arguments)
    }

    pub(crate) fn query_page(&self, arguments: &Value, scope: &str) -> Result<Value, ApiError> {
        let request = crate::state_pages::PageRequest::parse(arguments)?;
        let revision = self
            .source
            .map_or_else(String::new, |source| source.revision_id.to_string());
        let machine = self.inspection_machine(request.event, request.task_id)?;
        crate::state_pages::page(
            &machine,
            &request,
            &format!(
                "{scope}|{revision}|{}",
                self.debug.as_ref().map_or(0, |debug| debug.generation)
            ),
        )
    }

    pub(crate) fn inspection_machine(
        &self,
        event: usize,
        task: Option<u64>,
    ) -> Result<Machine<'_>, ApiError> {
        if self.debug.as_ref().is_some_and(|debug| {
            debug.stopped
                && debug.cursor == Some(event)
                && event.checked_add(1) == Some(self.delivered)
        }) {
            return self
                .machine
                .task_inspection(task.unwrap_or(self.machine.current_task_id()))
                .map_err(|_| usage("invalid task reference"));
        }
        let machine = self.machine_at(event)?;
        let Some(task) = task.filter(|task| *task != machine.current_task_id()) else {
            return Ok(machine);
        };
        let image = pseudolearn_vm::suspend_machine(machine);
        let mut options = self.options.clone();
        options.cancelled = None;
        let machine = pseudolearn_vm::resume_machine(&self.program, image, options.clone())
            .map_err(|_| usage("invalid inspection state"))?;
        let inspection = machine
            .task_inspection(task)
            .map_err(|_| usage("invalid task reference"))?;
        let image = pseudolearn_vm::suspend_machine(inspection);
        pseudolearn_vm::resume_machine(&self.program, image, options)
            .map_err(|_| usage("invalid task reference"))
    }

    pub(super) fn debug_machine(
        &self,
        event: Option<usize>,
        task: u64,
    ) -> Result<Machine<'_>, ApiError> {
        match event.filter(|event| event.saturating_add(1) < self.delivered) {
            Some(event) => self.inspection_machine(event, Some(task)),
            None => self
                .machine
                .task_inspection(task)
                .map_err(|_| usage("invalid task reference")),
        }
    }

    pub(crate) fn inspection_options(&self) -> RunOptions {
        self.options.clone()
    }

    pub(crate) fn inspection_profile(&self) -> pseudolearn_lexicon::Profile {
        pseudolearn_lexicon::Profile::from_name(&self.syntax_profile)
            .unwrap_or(pseudolearn_lexicon::Profile::Spanish)
    }
}
