use crate::load::model::EffectSite;
use crate::machine::{Flow, Machine};
use crate::{Fault, PendingEffectRequest, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{EffectOperation, EffectValueKind, HostCapability, HostValue};

impl Machine<'_> {
    pub(crate) fn effect_call(&mut self, site: u32) -> Result<Flow, Fault> {
        let site = self.effect_site(site)?;
        let operation = self.effect_operation(&site)?;
        if let Some(reply) = self.effect_result.take() {
            self.complete_effect(&site, operation, &reply)?;
            return Ok(Flow::Continue);
        }
        let arguments = self.effect_arguments(&site, operation)?;
        if !operation.effect {
            return self.complete_local_effect(&site, operation, &arguments);
        }
        self.request_effect(site, operation, arguments)
    }

    fn effect_site(&self, site: u32) -> Result<EffectSite, Fault> {
        self.current
            .effect_sites
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .cloned()
            .ok_or(INVALID_BYTECODE)
    }

    fn effect_operation(&self, site: &EffectSite) -> Result<&'static EffectOperation, Fault> {
        pseudolearn_runtime::effect_operation(&site.operation).ok_or(INVALID_BYTECODE)
    }

    fn effect_arguments(
        &self,
        site: &EffectSite,
        operation: &EffectOperation,
    ) -> Result<Vec<HostValue>, Fault> {
        site.arguments
            .iter()
            .zip(operation.parameters)
            .map(|(register, kind)| {
                let word = if matches!(kind, EffectValueKind::Integer | EffectValueKind::Boolean) {
                    self.scalar(*register)?
                } else {
                    u64::from(self.reference(*register)?)
                };
                pseudolearn_runtime::decode_host_value(&self.heap, *kind, word)
                    .map_err(super::memory::memory_fault)
            })
            .collect()
    }

    fn complete_local_effect(
        &mut self,
        site: &EffectSite,
        operation: &EffectOperation,
        arguments: &[HostValue],
    ) -> Result<Flow, Fault> {
        let reply = pseudolearn_runtime::local_effect(
            &self.heap,
            pseudolearn_runtime::Handle(self.reference(site.capability)?),
            operation,
            arguments,
        )
        .map_err(super::memory::memory_fault)?;
        self.complete_effect(site, operation, &reply)?;
        Ok(Flow::Continue)
    }

    fn request_effect(
        &mut self,
        site: EffectSite,
        operation: &'static EffectOperation,
        arguments: Vec<HostValue>,
    ) -> Result<Flow, Fault> {
        let receiver = self.effect_receiver(&site, operation)?;
        self.cursor.program_counter = self
            .cursor
            .program_counter
            .checked_sub(1)
            .ok_or(INVALID_BYTECODE)?;
        self.effect_seq = self.effect_seq.checked_add(1).ok_or(INVALID_BYTECODE)?;
        Ok(Flow::AwaitingEffect(PendingEffectRequest {
            effect_seq: self.effect_seq,
            capability_kind: operation.capability_family().to_owned(),
            operation: site.operation,
            arguments_summary: format!("{{\"count\":{}}}", arguments.len()),
            source_node_id: Some(site.source_node_id),
            receiver,
            arguments,
        }))
    }

    fn effect_receiver(
        &self,
        site: &EffectSite,
        operation: &EffectOperation,
    ) -> Result<Option<HostCapability>, Fault> {
        if operation.receiver.is_none() {
            return Ok(None);
        }
        let capability = pseudolearn_runtime::Handle(self.reference(site.capability)?);
        let receiver = pseudolearn_runtime::capability_token(&self.heap, capability)
            .map_err(super::memory::memory_fault)?;
        Ok(Some(receiver.into()))
    }
}
