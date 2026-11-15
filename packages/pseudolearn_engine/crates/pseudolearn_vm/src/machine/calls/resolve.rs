use crate::Fault;
use crate::evaluate::INVALID_BYTECODE;
use crate::load::{CallSite, LoadedFunction};
use crate::machine::Machine;
use std::sync::Arc;

impl Machine<'_> {
    pub(super) fn resolve_callee(
        &self,
        site: &CallSite,
    ) -> Result<(Arc<LoadedFunction>, usize), Fault> {
        let index = if let Some(code) = site.indirect {
            let index =
                usize::try_from(self.scalar(code)?).map_err(|_| "invalidFunctionReference")?;
            self.table_target(site, index)
                .map_err(|_| "invalidFunctionReference")?
        } else if let Some(receiver) = site.receiver {
            let receiver = pseudolearn_runtime::Handle(self.reference(receiver)?);
            let class = pseudolearn_runtime::object_class(&self.heap, receiver)
                .map_err(crate::machine::memory::memory_fault)?;
            self.table_target(site, usize::try_from(class).map_err(|_| INVALID_BYTECODE)?)?
        } else {
            site.function
        };
        let function = self
            .program
            .inner
            .functions
            .get(index)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
        Ok((function, index))
    }

    fn table_target(&self, site: &CallSite, index: usize) -> Result<usize, Fault> {
        let position = site
            .targets_start
            .checked_add(index)
            .ok_or(INVALID_BYTECODE)?;
        if position >= site.targets_end {
            return Err(INVALID_BYTECODE);
        }
        self.current
            .virtual_targets
            .get(position)
            .copied()
            .flatten()
            .map(usize::from)
            .ok_or(INVALID_BYTECODE)
    }
}
