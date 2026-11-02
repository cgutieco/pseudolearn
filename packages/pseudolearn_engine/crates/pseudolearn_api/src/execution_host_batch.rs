use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::HostReply;
use pseudolearn_vm::{PendingEffectRequest, RunExit};
use serde_json::Value;

#[derive(Default)]
pub(super) struct HostBookkeeping {
    pub(super) pending_hosts: std::collections::BTreeMap<u64, PendingHostEffect>,
    pub(super) completed_hosts: std::collections::VecDeque<CompletedHostEffect>,
    pub(super) limit_rejected_network: std::collections::BTreeSet<u64>,
    pub(super) completing_effect: bool,
}

impl HostBookkeeping {
    pub(super) fn forget_rejection(&mut self, sequence: u64) -> bool {
        self.limit_rejected_network.remove(&sequence)
    }

    pub(super) fn complete(&mut self, machine_sequence: u64, reply: HostReply) {
        self.completed_hosts.push_back(CompletedHostEffect {
            machine_sequence,
            reply,
        });
    }
}

pub(super) struct PendingHostEffect {
    pub(super) machine_sequence: u64,
    pub(super) request: PendingEffectRequest,
}

pub(super) struct CompletedHostEffect {
    pub(super) machine_sequence: u64,
    pub(super) reply: HostReply,
}

impl ExecutionResource {
    pub(super) fn concurrent_pending_effects(&self) -> Option<Value> {
        (self.hosts.pending_hosts.len() > 1).then(|| {
            Value::Array(
                self.hosts
                    .pending_hosts
                    .iter()
                    .map(|(sequence, host)| pending_host_value(*sequence, host))
                    .collect(),
            )
        })
    }

    pub(super) fn pending_host_value(&self) -> Option<Value> {
        if let Some(request) = &self.pending_host {
            return Some(serde_json::json!(request));
        }
        self.hosts
            .pending_hosts
            .iter()
            .next()
            .map(|(sequence, host)| pending_host_value(*sequence, host))
    }

    pub(super) fn activate_ready_host_effect(&mut self) -> Result<bool, ApiError> {
        let Some(completed) = self.hosts.completed_hosts.pop_front() else {
            return Ok(false);
        };
        self.machine
            .select_pending_effect(completed.machine_sequence)
            .map_err(|_| usage("pending effect cannot be selected"))?;
        self.machine.supply_effect_result(completed.reply);
        self.pending_host = None;
        self.hosts.completing_effect = true;
        Ok(true)
    }

    pub(super) fn has_external_effects(&self) -> bool {
        self.pending_host.is_some()
            || !self.hosts.pending_hosts.is_empty()
            || !self.hosts.completed_hosts.is_empty()
    }

    pub(super) fn start_concurrent_host_effects(
        &mut self,
        pending: &PendingEffectRequest,
    ) -> Result<bool, ApiError> {
        let requests = self.machine.pending_effect_requests();
        if requests.len() < 2 {
            return Ok(false);
        }
        self.mark_excess_network_requests();
        let requests = requests
            .into_iter()
            .filter(|request| {
                !self
                    .hosts
                    .limit_rejected_network
                    .contains(&request.effect_seq)
            })
            .collect::<Vec<_>>();
        if requests.len() < 2 {
            return Ok(false);
        }
        self.sync_reservations()?;
        for request in requests {
            self.reserve_pending_host(request)?;
        }
        let selected = self
            .hosts
            .pending_hosts
            .values()
            .find(|host| host.machine_sequence == pending.effect_seq)
            .and_then(|host| self.effects.reserved_sequence(host.machine_sequence))
            .ok_or_else(|| usage("missing pending network request"))?;
        let mut awaiting = pending.clone();
        awaiting.effect_seq = selected;
        self.terminal = Some(RunExit::AwaitingEffect(awaiting));
        Ok(true)
    }

    pub(super) fn wait_for_concurrent_reply(
        &mut self,
        mut pending: PendingEffectRequest,
    ) -> Result<bool, ApiError> {
        if self.activate_ready_host_effect()? {
            return Ok(true);
        }
        let host = self
            .hosts
            .pending_hosts
            .values()
            .find(|host| host.machine_sequence == pending.effect_seq)
            .ok_or_else(|| usage("missing pending network request"))?;
        pending.effect_seq = self
            .effects
            .reserved_sequence(host.machine_sequence)
            .ok_or_else(|| usage("missing reserved effect sequence"))?;
        self.terminal = Some(RunExit::AwaitingEffect(pending));
        Ok(false)
    }

    fn reserve_pending_host(&mut self, request: PendingEffectRequest) -> Result<(), ApiError> {
        let sequence = self
            .effects
            .reserved_sequence(request.effect_seq)
            .ok_or_else(|| usage("missing reserved effect sequence"))?;
        self.hosts.pending_hosts.insert(
            sequence,
            PendingHostEffect {
                machine_sequence: request.effect_seq,
                request,
            },
        );
        Ok(())
    }
}

fn pending_host_value(sequence: u64, host: &PendingHostEffect) -> Value {
    serde_json::json!({
        "effect_seq": sequence,
        "task_id": host.request.task_id,
        "capability_kind": host.request.capability_kind,
        "operation": host.request.operation,
        "source_node_id": host.request.source_node_id,
        "arguments": host.request.arguments,
    })
}
