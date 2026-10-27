use crate::{Fault, PendingEffectRequest, evaluate::INVALID_BYTECODE};
use crate::machine::{Flow, Machine};
use pseudolearn_runtime::{EffectValueKind, HostValue};

impl Machine<'_> {
    pub(crate) fn effect_call(&mut self, site: u32) -> Result<Flow, Fault> {
        let site = self.current.effect_sites.get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?).ok_or(INVALID_BYTECODE)?.clone();
        let operation = pseudolearn_runtime::effect_operation(&site.operation).ok_or(INVALID_BYTECODE)?;
        if let Some(reply) = self.effect_result.take() {
            self.complete_effect(&site, operation, &reply)?;
            return Ok(Flow::Continue);
        }
        let arguments = site.arguments.iter().zip(operation.parameters).map(|(register, kind)| {
            let word = if matches!(kind, EffectValueKind::Integer | EffectValueKind::Boolean) { self.scalar(*register)? }
                else { u64::from(self.reference(*register)?) };
            pseudolearn_runtime::decode_host_value(&self.heap, *kind, word).map_err(super::memory::memory_fault)
        }).collect::<Result<Vec<HostValue>, Fault>>()?;
        if !operation.effect {
            let reply = pseudolearn_runtime::local_effect(&self.heap, pseudolearn_runtime::Handle(self.reference(site.capability)?), operation, &arguments).map_err(super::memory::memory_fault)?;
            self.complete_effect(&site, operation, &reply)?;
            return Ok(Flow::Continue);
        }
        let receiver = if operation.receiver.is_some() {
            Some(pseudolearn_runtime::capability_token(&self.heap, pseudolearn_runtime::Handle(self.reference(site.capability)?)).map_err(super::memory::memory_fault)?.into())
        } else { None };
        self.cursor.program_counter = self.cursor.program_counter.checked_sub(1).ok_or(INVALID_BYTECODE)?;
        self.effect_seq = self.effect_seq.checked_add(1).ok_or(INVALID_BYTECODE)?;
        Ok(Flow::AwaitingEffect(PendingEffectRequest {
            effect_seq: self.effect_seq, capability_kind: operation.capability_family().to_owned(),
            operation: site.operation, arguments_summary: format!("{{\"count\":{}}}", arguments.len()),
            source_node_id: Some(site.source_node_id), receiver, arguments,
        }))
    }
}
