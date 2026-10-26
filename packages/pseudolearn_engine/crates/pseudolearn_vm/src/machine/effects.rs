#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::INVALID_BYTECODE;
use crate::machine::{Flow, Machine};
use crate::{PendingEffectRequest, RuntimeValue};

impl Machine<'_> {
    pub(crate) fn effect_call(&mut self, site: u32) -> Result<Flow, Fault> {
        let site_record = self
            .current
            .effect_sites
            .get(site as usize)
            .ok_or(INVALID_BYTECODE)?
            .clone();

        if let Some(result) = self.effect_result.take() {
            if let Some(destination) = site_record.destination {
                match result {
                    RuntimeValue::Scalar(word) => {
                        self.set_scalar(destination.index, word)?;
                    }
                    RuntimeValue::Reference(handle) => {
                        self.set_reference(destination.index, handle)?;
                    }
                }
            }
            return Ok(Flow::Continue);
        }

        self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
        self.effect_seq = self.effect_seq.saturating_add(1);
        let capability_kind = format!("cap_{}", site_record.capability);
        let pending = PendingEffectRequest {
            effect_seq: self.effect_seq,
            capability_kind,
            operation: site_record.operation,
            arguments_summary: format!("args_{}", site_record.arguments.len()),
            source_node_id: None,
        };
        Ok(Flow::AwaitingEffect(pending))
    }
}
