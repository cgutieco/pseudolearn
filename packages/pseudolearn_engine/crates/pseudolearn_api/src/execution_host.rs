use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::{HostReply, begin_host_effect, perform_host_effect, resolve_host_effect};
use pseudolearn_vm::{PendingEffectRequest, RunExit};
use serde_json::Value;
use std::sync::atomic::Ordering;

impl ExecutionResource {
    pub(super) fn resolve_pending(
        &mut self,
        mut pending: PendingEffectRequest,
    ) -> Result<bool, ApiError> {
        let operation = pseudolearn_runtime::effect_operation(&pending.operation)
            .ok_or_else(|| usage("unknown effect operation"))?;
        self.prepare_delivery(&pending)?;
        let source = pending
            .source_node_id
            .ok_or_else(|| usage("missing effect source"))?;
        if self.cancel_on_effect == Some(self.next_effect_sequence())
            && self.execution_mode.allows_external_host()
        {
            let request = self.begin_pending(operation, &pending, source)?;
            self.pending_host = Some(request);
            self.cancelled.store(true, Ordering::Relaxed);
            self.settle_cancelled_suspension();
            return Ok(false);
        }
        if self.detached_effects && self.execution_mode.allows_external_host() {
            let request = self.begin_pending(operation, &pending, source)?;
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

    pub(super) fn sync_reservations(&mut self) -> Result<(), ApiError> {
        pseudolearn_timeline::sync_effect_reservations(&mut self.effects, &self.machine)
            .map_err(crate::tape_wire::replay_error_to_api)
    }

    fn prepare_delivery(&mut self, pending: &PendingEffectRequest) -> Result<(), ApiError> {
        pseudolearn_timeline::prepare_effect_delivery(&mut self.effects, &self.machine, pending)
            .map_err(crate::tape_wire::replay_error_to_api)
    }

    pub(super) fn seal_abandoned_effects(&mut self) -> Result<(), ApiError> {
        self.sync_reservations()?;
        let abandoned = self
            .machine
            .abandoned_effect_requests()
            .into_iter()
            .map(|request| {
                let receiver = request.receiver.clone();
                pseudolearn_runtime::AbandonedEffect {
                    vm_sequence: request.effect_seq,
                    task: request.task_id,
                    request: pseudolearn_runtime::HostEffectRequest {
                        effect_seq: request.effect_seq,
                        operation: request.operation,
                        receiver,
                        arguments: request.arguments,
                        result_capability: None,
                        source_node_id: request.source_node_id.unwrap_or(0),
                    },
                }
            })
            .collect();
        self.effects
            .seal_abandoned(abandoned)
            .map_err(crate::tape_wire::replay_error_to_api)
    }

    pub(super) fn concurrent_pending_effects(&self) -> Option<Value> {
        let requests = self.machine.pending_effect_requests();
        (self.pending_host.is_some() && requests.len() > 1).then(|| {
            Value::Array(
                requests
                    .iter()
                    .map(|request| {
                        let sequence = self
                            .effects
                            .reserved_sequence(request.effect_seq)
                            .or_else(|| self.pending_host.as_ref().map(|pending| pending.effect_seq));
                        serde_json::json!({
                            "effect_seq": sequence,
                            "task_id": request.task_id,
                            "capability_kind": request.capability_kind,
                            "operation": request.operation,
                            "source_node_id": request.source_node_id,
                        })
                    })
                    .collect(),
            )
        })
    }

    fn next_effect_sequence(&self) -> u64 {
        u64::try_from(self.effects.tape().entries().len())
            .unwrap_or(u64::MAX)
            .saturating_add(1)
    }

    fn begin_pending(
        &mut self,
        operation: &pseudolearn_abi::EffectOperation,
        pending: &PendingEffectRequest,
        source: u32,
    ) -> Result<pseudolearn_runtime::HostEffectRequest, ApiError> {
        begin_host_effect(
            &mut self.effects,
            operation,
            (pending.receiver.clone(), pending.arguments.clone()),
            source,
        )
        .map_err(crate::tape_wire::replay_error_to_api)
    }

    pub(super) fn settle_cancelled_suspension(&mut self) {
        if self.pending_host.is_none() || !self.cancelled.load(Ordering::Relaxed) {
            return;
        }
        self.pending_host = None;
        self.effects.abort();
        pseudolearn_runtime::HostEffectProvider::close_all(&mut self.host);
        self.terminal = Some(RunExit::Cancelled);
    }

    pub(crate) fn effect_result(&mut self, arguments: &Value) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external effect result rejected in replay mode"));
        }
        self.settle_cancelled_suspension();
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
