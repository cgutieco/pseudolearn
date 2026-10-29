use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::{HostReply, begin_host_effect, perform_host_effect, resolve_host_effect};
use pseudolearn_vm::{PendingEffectRequest, RunExit};
use serde_json::Value;
use std::sync::atomic::Ordering;

impl ExecutionResource {
    pub(super) fn resolve_pending(
        &mut self,
        pending: PendingEffectRequest,
    ) -> Result<bool, ApiError> {
        let operation = pseudolearn_runtime::effect_operation(&pending.operation)
            .ok_or_else(|| usage("unknown effect operation"))?;
        let source = pending
            .source_node_id
            .ok_or_else(|| usage("missing effect source"))?;
        if self.resolve_cancelled_pending(operation, &pending, source)? {
            return Ok(false);
        }
        if self.reject_excess_network_request(operation, &pending, source)? {
            return Ok(true);
        }
        if self.detached_effects && self.execution_mode.allows_external_host() {
            return self.resolve_detached_pending(operation, pending, source);
        }
        self.resolve_attached_pending(operation, pending, source)
    }

    fn resolve_cancelled_pending(
        &mut self,
        operation: &pseudolearn_abi::EffectOperation,
        pending: &PendingEffectRequest,
        source: u32,
    ) -> Result<bool, ApiError> {
        if self.cancel_on_effect != Some(self.next_effect_sequence())
            || !self.execution_mode.allows_external_host()
        {
            return Ok(false);
        }
        self.prepare_delivery(pending)?;
        let request = self.begin_pending(operation, pending, source)?;
        self.pending_host = Some(request);
        self.cancelled.store(true, Ordering::Relaxed);
        self.settle_cancelled_suspension();
        Ok(true)
    }

    fn resolve_detached_pending(
        &mut self,
        operation: &pseudolearn_abi::EffectOperation,
        mut pending: PendingEffectRequest,
        source: u32,
    ) -> Result<bool, ApiError> {
        if self
            .pending_hosts
            .values()
            .any(|host| host.machine_sequence == pending.effect_seq)
        {
            return self.wait_for_concurrent_reply(pending);
        }
        if self.activate_ready_host_effect()? {
            return Ok(true);
        }
        if self.start_concurrent_host_effects(&pending)? {
            return Ok(false);
        }
        self.prepare_delivery(&pending)?;
        let request = self.begin_pending(operation, &pending, source)?;
        pending.effect_seq = request.effect_seq;
        self.pending_host = Some(request);
        self.terminal = Some(RunExit::AwaitingEffect(pending));
        Ok(false)
    }

    fn resolve_attached_pending(
        &mut self,
        operation: &pseudolearn_abi::EffectOperation,
        pending: PendingEffectRequest,
        source: u32,
    ) -> Result<bool, ApiError> {
        self.prepare_delivery(&pending)?;
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

    fn next_effect_sequence(&self) -> u64 {
        u64::try_from(self.effects.tape().entries().len())
            .unwrap_or(u64::MAX)
            .saturating_add(1)
    }

    fn pending_network_limit_exceeded(&mut self, pending: &PendingEffectRequest) -> bool {
        if pending.operation != "network_send" {
            return false;
        }
        self.mark_excess_network_requests();
        self.limit_rejected_network.remove(&pending.effect_seq)
    }

    fn reject_excess_network_request(
        &mut self,
        operation: &pseudolearn_abi::EffectOperation,
        pending: &PendingEffectRequest,
        source: u32,
    ) -> Result<bool, ApiError> {
        if !self.pending_network_limit_exceeded(pending) {
            return Ok(false);
        }
        self.prepare_delivery(pending)?;
        let request = self.begin_pending(operation, pending, source)?;
        let reply = pseudolearn_runtime::resolve_host_effect(
            &mut self.effects,
            request.effect_seq,
            pseudolearn_runtime::HostReply::failure(pseudolearn_runtime::IoError::from_kind(
                pseudolearn_abi::IoErrorKind::LimitExceeded,
            )),
        )
        .map_err(crate::tape_wire::replay_error_to_api)?;
        self.machine.supply_effect_result(reply);
        self.completing_effect = true;
        Ok(true)
    }

    pub(super) fn mark_excess_network_requests(&mut self) {
        let maximum = self.network_limits.pending;
        let requests = self
            .machine
            .pending_effect_requests()
            .into_iter()
            .filter(|request| request.operation == "network_send");
        for (index, request) in requests.enumerate() {
            let count = u64::try_from(index).unwrap_or(u64::MAX).saturating_add(1);
            if pseudolearn_runtime::pending_limit_exceeded(count, maximum) {
                self.limit_rejected_network.insert(request.effect_seq);
            }
        }
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
        if !self.has_external_effects() || !self.cancelled.load(Ordering::Relaxed) {
            return;
        }
        self.pending_host = None;
        self.pending_hosts.clear();
        self.completed_hosts.clear();
        self.effects.abort();
        pseudolearn_runtime::HostEffectProvider::close_all(&mut self.host);
        self.terminal = Some(RunExit::Cancelled);
    }

    pub(crate) fn effect_result(&mut self, arguments: &Value) -> Result<(), ApiError> {
        if !self.execution_mode.allows_external_host() {
            return Err(usage("external effect result rejected in replay mode"));
        }
        self.settle_cancelled_suspension();
        let sequence = arguments
            .get("effect_seq")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing effect sequence"))?;
        let result = arguments
            .get("result")
            .ok_or_else(|| usage("missing effect result"))?;
        let reply: HostReply =
            serde_json::from_value(result.clone()).map_err(|error| usage(&error.to_string()))?;
        if self.pending_hosts.contains_key(&sequence) {
            return self.resolve_concurrent_host_result(sequence, reply);
        }
        self.resolve_single_host_result(sequence, reply)
    }

    fn resolve_concurrent_host_result(
        &mut self,
        sequence: u64,
        reply: HostReply,
    ) -> Result<(), ApiError> {
        let pending = self
            .pending_hosts
            .remove(&sequence)
            .ok_or_else(|| usage("execution is not awaiting effect"))?;
        let operation = pseudolearn_runtime::effect_operation(&pending.request.operation)
            .ok_or_else(|| usage("unknown effect operation"))?;
        let source = pending
            .request
            .source_node_id
            .ok_or_else(|| usage("missing effect source"))?;
        self.prepare_delivery(&pending.request)?;
        let request = self.begin_pending(operation, &pending.request, source)?;
        if request.effect_seq != sequence {
            return Err(usage("effect sequence mismatch"));
        }
        let reply = resolve_host_effect(&mut self.effects, sequence, reply)
            .map_err(crate::tape_wire::replay_error_to_api)?;
        self.completed_hosts.push_back(super::CompletedHostEffect {
            machine_sequence: pending.machine_sequence,
            reply,
        });
        self.clear_completed_host(sequence);
        Ok(())
    }

    fn clear_completed_host(&mut self, sequence: u64) {
        if self
            .pending_host
            .as_ref()
            .is_some_and(|host| host.effect_seq == sequence)
        {
            self.pending_host = None;
        }
        self.terminal = None;
    }

    fn resolve_single_host_result(
        &mut self,
        sequence: u64,
        reply: HostReply,
    ) -> Result<(), ApiError> {
        let pending = self
            .pending_host
            .as_ref()
            .ok_or_else(|| usage("execution is not awaiting effect"))?;
        if sequence != pending.effect_seq {
            return Err(usage("effect sequence mismatch"));
        }
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
