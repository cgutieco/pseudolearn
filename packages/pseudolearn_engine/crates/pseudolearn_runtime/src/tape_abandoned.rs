use crate::{EffectRecord, EffectSession, HostEffectRequest, ReplayError};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AbandonedEffect {
    pub vm_sequence: u64,
    pub task: u64,
    pub request: HostEffectRequest,
}

impl EffectSession {
    pub fn seal_abandoned(&mut self, abandoned: Vec<AbandonedEffect>) -> Result<(), ReplayError> {
        let mut ordered = abandoned;
        ordered.sort_by_key(|effect| effect.vm_sequence);
        for effect in ordered {
            let operation = pseudolearn_abi::effect_operation(&effect.request.operation)
                .ok_or(ReplayError::Divergence)?;
            let sequence = self.reservation_for(effect.vm_sequence);
            self.current_task = effect.task;
            let arguments = crate::host_session::request_arguments(&effect.request)?;
            let record = EffectRecord {
                capability_kind: operation.capability_family().to_owned(),
                operation: operation.identity.to_owned(),
                arguments,
                source_node_id: effect.request.source_node_id,
            };
            self.resolve_at(sequence, record, (Vec::new(), "abandoned"))?;
        }
        Ok(())
    }
}
