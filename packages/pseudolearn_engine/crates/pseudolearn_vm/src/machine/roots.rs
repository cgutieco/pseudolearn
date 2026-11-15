use super::{Machine, TaskContext, cells::Cell};
use crate::load::LoadedFunction;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{Handle, ValueKind};

struct RootState<'banks, 'output> {
    references: &'banks [u32],
    cells: &'banks [Cell],
    probed: bool,
    roots: &'output mut Vec<Handle>,
}

impl Machine<'_> {
    pub(super) fn memory_roots(&mut self) -> Result<Vec<Handle>, Fault> {
        let mut roots = Vec::new();
        self.frame_roots(
            self.current.as_ref(),
            (
                self.cursor.program_counter.saturating_sub(1),
                self.cursor.reference_base,
            ),
            &mut roots,
        )?;
        self.suspended_roots(&mut roots)?;
        roots.extend(self.tasks.value_roots());
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

    fn suspended_roots(&self, roots: &mut Vec<Handle>) -> Result<(), Fault> {
        let mut state = RootState {
            references: &self.references,
            cells: &self.cells,
            probed: self.probed,
            roots,
        };
        for frame in &self.frames {
            let mut continuation = *frame
                .function
                .continuations
                .get(frame.return_point)
                .ok_or(INVALID_BYTECODE)?;
            if self.probed {
                continuation = *frame
                    .function
                    .fast_to_probed_returns
                    .get(continuation)
                    .ok_or(INVALID_BYTECODE)?;
            }
            append_frame_roots(
                frame.function.as_ref(),
                continuation.saturating_sub(1),
                frame.reference_base,
                &mut state,
            )?;
        }
        for context in self.tasks.contexts() {
            append_context_roots(context, &mut state)?;
        }
        Ok(())
    }

    fn frame_roots(
        &self,
        function: &LoadedFunction,
        (position, base): (usize, usize),
        roots: &mut Vec<Handle>,
    ) -> Result<(), Fault> {
        let mut state = RootState {
            references: &self.references,
            cells: &self.cells,
            probed: self.probed,
            roots,
        };
        append_frame_roots(function, position, base, &mut state)
    }
}

fn append_context_roots(context: &TaskContext, state: &mut RootState<'_, '_>) -> Result<(), Fault> {
    state
        .roots
        .extend(context.spills.iter().map(|frame| frame.handle));
    Ok(())
}

fn append_frame_roots(
    function: &LoadedFunction,
    position: usize,
    base: usize,
    state: &mut RootState<'_, '_>,
) -> Result<(), Fault> {
    let maps = if state.probed {
        &function.probed_roots
    } else {
        &function.roots
    };
    let slots = maps.get(&position).ok_or(INVALID_BYTECODE)?;
    for (register, is_cell) in slots {
        let absolute = base
            .checked_add(usize::from(*register))
            .ok_or(INVALID_BYTECODE)?;
        let bits = *state.references.get(absolute).ok_or(INVALID_BYTECODE)?;
        if bits == 0 {
            continue;
        }
        if *is_cell {
            append_cell_roots(bits, state)?;
        } else {
            state.roots.push(Handle(bits));
        }
    }
    Ok(())
}

fn append_cell_roots(bits: u32, state: &mut RootState<'_, '_>) -> Result<(), Fault> {
    let index = usize::try_from(bits.checked_sub(1).ok_or(INVALID_BYTECODE)?)
        .map_err(|_| INVALID_BYTECODE)?;
    match state.cells.get(index).ok_or(INVALID_BYTECODE)? {
        Cell::Managed(cell) => state.roots.push(cell.owner),
        Cell::Local {
            kind: ValueKind::Reference,
            absolute,
            ..
        } => {
            state.roots.push(Handle(
                *state.references.get(*absolute).ok_or(INVALID_BYTECODE)?,
            ));
        }
        _ => {}
    }
    Ok(())
}
