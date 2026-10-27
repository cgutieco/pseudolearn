use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::{HostReply, begin_host_effect, perform_host_effect, resolve_host_effect};
use pseudolearn_vm::{PendingEffectRequest, RunExit};
use serde_json::Value;

impl ExecutionResource {
    pub(super) fn resolve_pending(
        &mut self,
        mut pending: PendingEffectRequest,
    ) -> Result<bool, ApiError> {
        let operation = pseudolearn_runtime::effect_operation(&pending.operation)
            .ok_or_else(|| usage("unknown effect operation"))?;
        let source = pending
            .source_node_id
            .ok_or_else(|| usage("missing effect source"))?;
        if self.detached_effects && self.execution_mode.allows_external_host() {
            let request = begin_host_effect(
                &mut self.effects,
                operation,
                (pending.receiver.clone(), pending.arguments.clone()),
                source,
            )
            .map_err(crate::tape_wire::replay_error_to_api)?;
            pending.effect_seq = request.effect_seq;
            self.pending_host = Some(request);
            self.terminal = Some(RunExit::AwaitingEffect(pending));
            return Ok(false);
        }
        let reply = perform_host_effect(
            &mut self.effects,
            &mut self.host,
            operation,
            (pending.receiver, pending.arguments, source),
        )
        .map_err(crate::tape_wire::replay_error_to_api)?;
        self.machine.supply_effect_result(reply);
        self.completing_effect = true;
        Ok(true)
    }

    pub(crate) fn effect_result(&mut self, arguments: &Value) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external effect result rejected in replay mode"));
        }
        let pending = self
            .pending_host
            .as_ref()
            .ok_or_else(|| usage("execution is not awaiting effect"))?;
        let sequence = arguments
            .get("effect_seq")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing effect sequence"))?;
        if sequence != pending.effect_seq {
            return Err(usage("effect sequence mismatch"));
        }
        let result = arguments
            .get("result")
            .ok_or_else(|| usage("missing effect result"))?;
        let reply: HostReply =
            serde_json::from_value(result.clone()).map_err(|error| usage(&error.to_string()))?;
        let reply = resolve_host_effect(&mut self.effects, sequence, reply)
            .map_err(crate::tape_wire::replay_error_to_api)?;
        self.machine.supply_effect_result(reply);
        self.pending_host = None;
        self.completing_effect = true;
        self.terminal = None;
        Ok(())
    }
}

impl Drop for ExecutionResource {
    fn drop(&mut self) {
        pseudolearn_runtime::HostEffectProvider::close_all(&mut self.host);
    }
}
