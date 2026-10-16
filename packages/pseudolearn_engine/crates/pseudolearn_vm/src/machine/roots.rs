use super::{Machine, cells::Cell};
use crate::load::LoadedFunction;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{Handle, ValueKind};

impl Machine<'_> {
    pub(super) fn memory_roots(&mut self) -> Result<Vec<Handle>, Fault> {
        let mut roots = Vec::new();
        self.frame_roots(
            self.current,
            (
                self.cursor.program_counter.saturating_sub(1),
                self.cursor.reference_base,
            ),
            &mut roots,
        )?;
        for frame in &self.frames {
            let continuation = *frame
                .function
                .continuations
                .get(frame.return_point)
                .ok_or(INVALID_BYTECODE)?;
            self.frame_roots(
                frame.function,
                (continuation.saturating_sub(1), frame.reference_base),
                &mut roots,
            )?;
        }
        if self.options.inspect_memory {
            let cells = self
                .heap
                .reachable_cells(&roots)
                .map_err(super::memory::memory_fault)?;
            self.memory_counts.push(crate::MemoryCount {
                function: self.current.name.clone(),
                program_counter: self.cursor.program_counter.saturating_sub(1),
                cells,
            });
        }
        Ok(roots)
    }

    fn frame_roots(
        &self,
        function: &LoadedFunction,
        (position, base): (usize, usize),
        roots: &mut Vec<Handle>,
    ) -> Result<(), Fault> {
        let slots = function.roots.get(&position).ok_or(INVALID_BYTECODE)?;
        for (register, is_cell) in slots {
            let absolute = base
                .checked_add(usize::from(*register))
                .ok_or(INVALID_BYTECODE)?;
            let bits = *self.references.get(absolute).ok_or(INVALID_BYTECODE)?;
            if bits == 0 {
                continue;
            }
            if *is_cell {
                self.cell_roots(bits, roots)?;
            } else {
                roots.push(Handle(bits));
            }
        }
        Ok(())
    }

    fn cell_roots(&self, bits: u32, roots: &mut Vec<Handle>) -> Result<(), Fault> {
        let index = usize::try_from(bits.checked_sub(1).ok_or(INVALID_BYTECODE)?)
            .map_err(|_| INVALID_BYTECODE)?;
        match self.cells.get(index).ok_or(INVALID_BYTECODE)? {
            Cell::Managed(cell) => roots.push(cell.owner),
            Cell::Local {
                kind: ValueKind::Reference,
                absolute,
                ..
            } => {
                roots.push(Handle(
                    *self.references.get(*absolute).ok_or(INVALID_BYTECODE)?,
                ));
            }
            _ => {}
        }
        Ok(())
    }
}
