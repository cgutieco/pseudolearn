use super::Machine;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::Handle;

impl Machine<'_> {
    pub(super) fn copy_snapshot(
        &mut self,
        sources: &[u16],
        destinations: &[u16],
    ) -> Result<(), Fault> {
        let sources = sources
            .iter()
            .map(|source| self.reference(*source).map(Handle))
            .collect::<Result<Vec<_>, _>>()?;
        let roots = self.memory_roots()?;
        let copied = pseudolearn_runtime::snapshot_copy_many(&mut self.heap, &sources, &roots)
            .map_err(super::memory::memory_fault)?;
        if copied.len() != destinations.len() {
            return Err(INVALID_BYTECODE);
        }
        for (handle, destination) in copied.into_iter().zip(destinations) {
            let cell = self.cell(*destination)?;
            self.store_cell(cell, u64::from(handle.0))?;
        }
        Ok(())
    }
}
