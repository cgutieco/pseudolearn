use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_vm::RunExit;
use serde_json::{Value, json};

#[cfg(test)]
#[path = "execution_input_tests.rs"]
mod execution_input_tests;

#[derive(Clone)]
pub(crate) struct InputRequest {
    pub(crate) resource_id: u64,
    pub(crate) task_id: u64,
    pub(crate) request_id: u64,
}

impl InputRequest {
    pub(crate) fn to_value(&self) -> Value {
        json!({"resource_id":self.resource_id,"task_id":self.task_id,"request_id":self.request_id})
    }

    fn matches(&self, other: &InputRequest) -> bool {
        self.resource_id == other.resource_id
            && self.task_id == other.task_id
            && self.request_id == other.request_id
    }
}

pub(crate) fn parse_input(arguments: &Value) -> Result<(InputRequest, String), ApiError> {
    let text = arguments
        .get("text")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing input text"))?
        .to_owned();
    let task_id = arguments
        .get("task_id")
        .and_then(Value::as_u64)
        .ok_or_else(|| usage("missing input task identity"))?;
    let resource_id = arguments
        .get("resource_id")
        .and_then(Value::as_u64)
        .ok_or_else(|| usage("missing input execution identity"))?;
    let request_id = arguments
        .get("request_id")
        .and_then(Value::as_u64)
        .filter(|request_id| *request_id > 0)
        .ok_or_else(|| usage("missing input request identity"))?;
    Ok((
        InputRequest {
            resource_id,
            task_id,
            request_id,
        },
        text,
    ))
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

    pub(crate) fn input(&mut self, reply: InputRequest, text: String) -> Result<(), ApiError> {
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
            || !pending.matches(&reply)
            || reply.resource_id != self.resource_id
            || reply.task_id != self.machine.current_task_id()
        {
            return Err(usage("input request identity mismatch"));
        }
        self.pending_input = None;
        self.hosts.shadow.log_input(reply.clone(), text.clone());
        self.options.inputs.push(text.clone());
        self.machine.supply_input(text);
        self.terminal = None;
        Ok(())
    }
}
