use crate::Fault;
use crate::evaluate::INVALID_BYTECODE;
use crate::load::{CallSite, Definition, Move};
use crate::machine::{Cursor, Machine};
use pseudolearn_bytecode::RegisterClass;

impl Machine<'_> {
    pub(super) fn pass_arguments(
        &mut self,
        site: &CallSite,
        caller: Cursor,
        callee: Cursor,
    ) -> Result<(), Fault> {
        let function = std::sync::Arc::clone(&self.current);
        let arguments = function
            .moves
            .get(site.arguments_start..site.arguments_end)
            .ok_or(INVALID_BYTECODE)?;
        for entry in arguments {
            self.pass_argument(entry, caller, callee)?;
        }
        Ok(())
    }

    fn pass_argument(&mut self, entry: &Move, caller: Cursor, callee: Cursor) -> Result<(), Fault> {
        let source = usize::from(entry.source);
        let destination = usize::from(entry.destination);
        if entry.class == RegisterClass::Reference {
            let absolute = callee.reference_base.wrapping_add(destination);
            let handle = *self
                .references
                .get(caller.reference_base.wrapping_add(source))
                .ok_or(INVALID_BYTECODE)?;
            self.mark_reference_dirty(absolute);
            let slot = self.references.get_mut(absolute).ok_or(INVALID_BYTECODE)?;
            *slot = handle;
            return Ok(());
        }
        let absolute = callee.scalar_base.wrapping_add(destination);
        let word = *self
            .scalars
            .get(caller.scalar_base.wrapping_add(source))
            .ok_or(INVALID_BYTECODE)?;
        self.mark_scalar_dirty(absolute);
        let slot = self.scalars.get_mut(absolute).ok_or(INVALID_BYTECODE)?;
        *slot = word;
        let defined = match entry.definition {
            Definition::Untracked => return Ok(()),
            Definition::Defined => true,
            Definition::Undefined => false,
            Definition::Copied => *self
                .defined
                .get(caller.scalar_base.wrapping_add(source))
                .ok_or(INVALID_BYTECODE)?,
        };
        self.set_defined(absolute, defined)
    }
}
