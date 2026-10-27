use super::{ExecutionResource, usage};
use crate::{ApiError, ExecuteRequest};
use pseudolearn_runtime::{EffectSession, ExecutionMode};
use pseudolearn_vm::machine_output;
use pseudolearn_vm::{RunExit, machine_event_count};
use serde_json::Value;

impl ExecutionResource {
    pub(super) fn drive_batch(&mut self, maximum: usize) -> Result<(), ApiError> {
        let initial_count = machine_event_count(&self.machine);
        loop {
            let exit = self.machine.step_instruction();
            self.capture_step_output()?;
            if let Some(exit) = exit {
                if self.handle_exit(exit)? {
                    continue;
                }
                break;
            }
            let emitted = machine_event_count(&self.machine).saturating_sub(initial_count);
            if emitted >= maximum {
                break;
            }
        }
        Ok(())
    }

    fn capture_step_output(&mut self) -> Result<(), ApiError> {
        if !self.completing_effect {
            return self.capture_console();
        }
        self.output_cursor = machine_output(&self.machine).len();
        self.completing_effect = false;
        Ok(())
    }

    fn handle_exit(&mut self, exit: RunExit) -> Result<bool, ApiError> {
        if let RunExit::AwaitingEffect(pending) = exit {
            return self.resolve_pending(pending);
        }
        if matches!(exit, RunExit::Completed(_)) {
            self.effects
                .finish()
                .map_err(crate::tape_wire::replay_error_to_api)?;
        } else if matches!(
            exit,
            RunExit::Cancelled | RunExit::LimitReached { .. } | RunExit::Trap(_)
        ) {
            self.effects.abort();
        }
        pseudolearn_runtime::HostEffectProvider::close_all(&mut self.host);
        self.terminal = Some(exit);
        Ok(false)
    }

    pub(super) fn capture_console(&mut self) -> Result<(), ApiError> {
        let output = machine_output(&self.machine);
        if let Some(text) = output
            .get(self.output_cursor..)
            .filter(|text| !text.is_empty())
        {
            let bytes = text.as_bytes().to_vec();
            let expected = self
                .effects
                .resolve(pseudolearn_runtime::console_record("write", bytes.clone()), bytes.clone(), "committed")
                .map_err(crate::tape_wire::replay_error_to_api)?;
            if expected != bytes {
                return Err(crate::tape_wire::replay_error_to_api(
                    pseudolearn_runtime::ReplayError::Divergence,
                ));
            }
            self.output_cursor = output.len();
        }
        let consumed = self.machine.input_consumed_count();
        while self.input_cursor < consumed {
            let text = self
                .options
                .inputs
                .get(self.input_cursor)
                .ok_or_else(|| usage("missing consumed input"))?;
            self.effects
                .resolve(
                    pseudolearn_runtime::console_record("read", Vec::new()),
                    text.as_bytes().to_vec(),
                    "committed",
                )
                .map_err(crate::tape_wire::replay_error_to_api)?;
            self.input_cursor = self.input_cursor.saturating_add(1);
        }
        Ok(())
    }
}

pub(super) fn prepare_session(
    request: &ExecuteRequest,
    execution_mode: ExecutionMode,
) -> Result<EffectSession, ApiError> {
    let identity = crate::tape_wire::build_identity(request);
    let maximum = request
        .host
        .as_ref()
        .and_then(|host| host.get("max_tape_bytes"))
        .and_then(Value::as_u64)
        .and_then(|count| usize::try_from(count).ok())
        .unwrap_or(pseudolearn_runtime::tape_privacy::DEFAULT_MAX_TAPE_BYTES);
    let effects = if execution_mode.allows_external_host() {
        pseudolearn_runtime::EffectSession::new(identity, maximum)
    } else {
        let tape = request
            .effect_tape
            .as_ref()
            .ok_or_else(|| usage("missing replay tape"))?;
        pseudolearn_runtime::EffectSession::from_tape(
            crate::tape_wire::tape_from_value(tape)?,
            &identity,
        )
        .map_err(crate::tape_wire::replay_error_to_api)?
    };

    Ok(effects)
}

pub(super) fn prepare_host(
    request: &ExecuteRequest,
    mode: ExecutionMode,
) -> Result<crate::FakeHostProvider, ApiError> {
    if !mode.allows_external_host() {
        return Ok(crate::FakeHostProvider::default());
    }
    request
        .host
        .as_ref()
        .map(crate::FakeHostProvider::from_value)
        .transpose()
        .map(|host| host.unwrap_or_default())
        .map_err(|error| usage(error.code()))
}
