use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::{HostReply, resolve_host_effect};

impl ExecutionResource {
    pub(super) fn resolve_concurrent_host_result(
        &mut self,
        sequence: u64,
        reply: HostReply,
    ) -> Result<(), ApiError> {
        let pending = self
            .hosts
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
        self.hosts.complete(pending.machine_sequence, reply);
        self.clear_completed_host(sequence);
        Ok(())
    }

    pub(super) fn flush_buffered_host_replies(&mut self) -> Result<(), ApiError> {
        let replies = std::mem::take(&mut self.hosts.buffered_replies);
        for (sequence, reply) in replies {
            self.resolve_concurrent_host_result(sequence, reply)?;
        }
        Ok(())
    }

    pub(super) fn resolve_single_host_result(
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
        self.hosts.completing_effect = true;
        self.terminal = None;
        Ok(())
    }
}
