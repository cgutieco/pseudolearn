use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_vm::RunExit;
use serde_json::{Value, json};

#[cfg(test)]
#[path = "execution_input_tests.rs"]
mod execution_input_tests;

pub(crate) struct InputRequest {
    pub(crate) resource_id: u64,
    pub(crate) task_id: u64,
    pub(crate) request_id: u64,
}

impl InputRequest {
    pub(crate) fn to_value(&self) -> Value {
        json!({"resource_id":self.resource_id,"task_id":self.task_id,"request_id":self.request_id})
    }

    fn matches(&self, resource_id: u64, task_id: u64, request_id: u64) -> bool {
        self.resource_id == resource_id && self.task_id == task_id && self.request_id == request_id
    }
}

impl ExecutionResource {
    pub(super) fn issue_input_request(&mut self) -> Result<(), ApiError> {
        let request_id = self.next_input_request_id;
        self.next_input_request_id = request_id.checked_add(1).ok_or_else(|| {
            ApiError::InternalFault("input request identity exhausted".to_owned())
        })?;
        self.pending_input = Some(InputRequest {
            resource_id: self.resource_id,
            task_id: self.machine.current_task_id(),
            request_id,
        });
        Ok(())
    }

    pub(crate) fn input(
        &mut self,
        resource_id: u64,
        task_id: u64,
        request_id: u64,
        text: String,
    ) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external input rejected in replay or seek mode"));
        }
        if self.cancelled.load(std::sync::atomic::Ordering::Relaxed) {
            return Err(usage("execution is cancelled"));
        }
        let pending = self
            .pending_input
            .as_ref()
            .ok_or_else(|| usage("execution is not awaiting input"))?;
        if !matches!(self.terminal, Some(RunExit::AwaitingInput))
            || !pending.matches(resource_id, task_id, request_id)
            || resource_id != self.resource_id
            || task_id != self.machine.current_task_id()
        {
            return Err(usage("input request identity mismatch"));
        }
        self.pending_input = None;
        self.options.inputs.push(text.clone());
        self.machine.supply_input(text);
        self.terminal = None;
        Ok(())
    }
}
