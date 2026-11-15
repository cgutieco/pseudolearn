use super::Machine;
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{buffered_slot, take_buffer_change};

impl Machine<'_> {
    pub(super) fn channel_identity(&self, value: RuntimeValue) -> Result<u64, Fault> {
        let RuntimeValue::Reference(handle) = value else {
            return Err(INVALID_BYTECODE);
        };
        pseudolearn_runtime::channel_references::channel_identity(
            &self.heap,
            pseudolearn_runtime::Handle(handle),
        )
        .map_err(super::memory::memory_fault)
    }

    pub(super) fn flush_channel_buffers(&mut self) -> Result<(), Fault> {
        while let Some((channel, slot)) = take_buffer_change(&mut self.tasks.channels) {
            let handle = *self
                .tasks
                .channel_storage
                .get(&channel)
                .ok_or(INVALID_BYTECODE)?;
            let words: Vec<_> = buffered_slot(&self.tasks.channels, channel, slot)
                .into_iter()
                .flatten()
                .map(|value| match value {
                    RuntimeValue::Scalar(word) => (*word, false),
                    RuntimeValue::Reference(handle) => (u64::from(*handle), true),
                })
                .collect();
            pseudolearn_runtime::channel_references::store_channel_slot(
                &mut self.heap,
                handle,
                slot,
                &words,
            )
            .map_err(super::memory::memory_fault)?;
        }
        Ok(())
    }
}
