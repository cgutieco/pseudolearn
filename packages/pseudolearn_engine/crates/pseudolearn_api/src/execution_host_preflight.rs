use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_runtime::{HostReply, resolve_host_effect};
use pseudolearn_vm::PendingEffectRequest;

pub(super) fn creates_capability(request: &PendingEffectRequest) -> bool {
    pseudolearn_runtime::effect_operation(&request.operation)
        .and_then(|operation| pseudolearn_runtime::capability_kind(operation.result))
        .is_some()
}

impl ExecutionResource {
    pub(super) fn select_capability_effect(
        &mut self,
        pending: PendingEffectRequest,
    ) -> Result<PendingEffectRequest, ApiError> {
        let creation = self
            .machine
            .pending_effect_requests()
            .into_iter()
            .find(creates_capability);
        let Some(creation) = creation else {
            return Ok(pending);
        };
        if creation.effect_seq != pending.effect_seq {
            self.machine
                .select_pending_effect(creation.effect_seq)
                .map_err(|_| usage("pending capability effect cannot be selected"))?;
        }
        Ok(creation)
    }

    pub(super) fn finish_rejected_host(&mut self, sequence: u64) -> Result<bool, ApiError> {
        let Some(error) = pseudolearn_runtime::pending_host_rejection(&self.effects) else {
            return Ok(false);
        };
        let reply = resolve_host_effect(&mut self.effects, sequence, HostReply::failure(error))
            .map_err(crate::tape_wire::replay_error_to_api)?;
        self.machine.supply_effect_result(reply);
        self.hosts.completing_effect = true;
        Ok(true)
    }
}
