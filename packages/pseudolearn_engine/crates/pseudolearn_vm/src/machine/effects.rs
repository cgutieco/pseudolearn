use crate::load::model::EffectSite;
use crate::machine::{Flow, Machine};
use crate::{Fault, PendingEffectRequest, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{EffectOperation, HostCapability, HostValue};

impl Machine<'_> {
    pub(crate) fn effect_call(&mut self, site: u32) -> Result<Flow, Fault> {
        let site = self.effect_site(site)?;
        let operation = self.effect_operation(&site)?;
        if let Some(reply) = self.effect_result.take() {
            let delivered = self.tasks.pending_effects.remove(&self.tasks.current);
            self.event_effect_delivered(delivered.map_or(0, |request| request.effect_seq));
            self.complete_effect(&site, operation, &reply)?;
            return Ok(Flow::Continue);
        }
        if !operation.effect
            && let Some(value) = self.try_local_json_view(&site, operation)?
        {
            self.complete_local_view(&site, value)?;
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
                let word = if EffectOperation::is_scalar(*kind) {
                    self.scalar(*register)?
                } else {
                    u64::from(self.reference(*register)?)
                };
                pseudolearn_runtime::decode_host_value(&self.heap, *kind, word)
                    .map_err(super::memory::memory_fault)
            })
            .collect()
    }

    fn effect_argument_words(
        &self,
        site: &EffectSite,
        operation: &EffectOperation,
    ) -> Result<Vec<u64>, Fault> {
        site.arguments
            .iter()
            .zip(operation.parameters)
            .map(|(register, kind)| {
                if EffectOperation::is_scalar(*kind) {
                    self.scalar(*register)
                } else {
                    self.reference(*register).map(u64::from)
                }
            })
            .collect()
    }

    fn try_local_json_view(
        &mut self,
        site: &EffectSite,
        operation: &EffectOperation,
    ) -> Result<Option<u64>, Fault> {
        let receiver = pseudolearn_runtime::Handle(self.reference(site.capability)?);
        let words = self.effect_argument_words(site, operation)?;
        let mut roots = self.memory_roots()?;
        roots
            .try_reserve(words.len().saturating_add(1))
            .map_err(|_| super::memory::memory_fault(pseudolearn_runtime::MemoryError::Resource))?;
        roots.push(receiver);
        for (word, kind) in words.iter().zip(operation.parameters) {
            if !EffectOperation::is_scalar(*kind) {
                roots.push(pseudolearn_runtime::Handle(
                    u32::try_from(*word).map_err(|_| INVALID_BYTECODE)?,
                ));
            }
        }
        let call = pseudolearn_library::LocalJsonViewCall::new(receiver, operation, &words, &roots);
        pseudolearn_library::local_json_view(&mut self.heap, call)
            .map_err(super::memory::memory_fault)
    }

    fn complete_local_effect(
        &mut self,
        site: &EffectSite,
        operation: &EffectOperation,
        arguments: &[HostValue],
    ) -> Result<Flow, Fault> {
        let receiver = pseudolearn_runtime::Handle(self.reference(site.capability)?);
        let reply =
            match pseudolearn_library::local_operation(pseudolearn_library::LocalOperationRequest {
                heap: &self.heap,
                receiver,
                operation,
                arguments,
                maximum_json_depth: self.options.max_json_depth,
            })
            .map_err(super::memory::memory_fault)?
            {
                Some(value) => pseudolearn_runtime::HostReply::Committed(value),
                None => {
                    pseudolearn_runtime::local_effect(&self.heap, receiver, operation, arguments)
                        .map_err(super::memory::memory_fault)?
                }
            };
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
        let request = PendingEffectRequest {
            effect_seq: self.effect_seq,
            capability_kind: operation.capability_family().to_owned(),
            operation: site.operation,
            arguments_summary: format!("{{\"count\":{}}}", arguments.len()),
            source_node_id: Some(site.source_node_id),
            task_id: self.tasks.current.0,
            receiver,
            arguments,
        };
        if site.awaited {
            self.wait_task_effect(request)
        } else {
            Ok(Flow::AwaitingEffect(request))
        }
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
