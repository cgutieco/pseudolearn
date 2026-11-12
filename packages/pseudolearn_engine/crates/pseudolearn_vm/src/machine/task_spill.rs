use super::TaskContext;
use super::cells::Cell;
use super::suspension_maps::{merge_plans, plan};
use super::suspension_storage::save_frame;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{Handle, Heap, ValueKind};
use std::collections::BTreeSet;

#[derive(Clone, Debug, PartialEq)]
pub(super) struct SpilledFrame {
    pub(super) handle: Handle,
    pub(super) function: usize,
    pub(super) position: usize,
    pub(super) bases: (usize, usize),
    pub(super) capacity: (usize, usize),
    pub(super) scalars: Vec<usize>,
    pub(super) references: Vec<usize>,
    pub(super) cells: Vec<usize>,
}

impl TaskContext {
    pub(super) fn spill(
        &mut self,
        heap: &mut Heap,
        probed: bool,
        (roots, additional): (&[Handle], Vec<SpilledFrame>),
    ) -> Result<(), Fault> {
        let plans = self.spill_plans(probed, additional)?;
        let mut retained = roots.to_vec();
        let mut parent = Handle(0);
        let mut values = Vec::new();
        for mut frame in plans {
            self.extend_cells(&mut frame)?;
            let (scalars, references) = self.spill_values(&frame)?;
            retained.extend_from_slice(&references);
            values.push((frame, scalars, references));
        }
        for (mut frame, scalars, references) in values {
            frame.handle = self
                .reusable
                .iter()
                .find(|cached| cached.function == frame.function && cached.bases == frame.bases)
                .map_or(Handle(0), |cached| cached.handle);
            let handle = save_frame(heap, &frame, (parent, scalars, references), &retained)?;
            frame.handle = handle;
            parent = handle;
            retained.push(handle);
            self.spills.push(frame);
        }
        self.scalars.clear();
        self.scalars.shrink_to_fit();
        self.references.clear();
        self.references.shrink_to_fit();
        Ok(())
    }

    fn spill_plans(
        &self,
        probed: bool,
        additional: Vec<SpilledFrame>,
    ) -> Result<Vec<SpilledFrame>, Fault> {
        let mut plans = additional;
        for frame in &self.frames {
            let mut position = *frame
                .function
                .continuations
                .get(frame.return_point)
                .ok_or(INVALID_BYTECODE)?;
            if probed {
                position = *frame
                    .function
                    .fast_to_probed_returns
                    .get(position)
                    .ok_or(INVALID_BYTECODE)?;
            }
            plans.push(plan(
                &frame.function,
                (position.saturating_sub(1), frame.function_index),
                (frame.scalar_base, frame.reference_base),
                probed,
            )?);
        }
        plans.push(plan(
            &self.current,
            (self.root_position, self.current_function_index),
            (self.cursor.scalar_base, self.cursor.reference_base),
            probed,
        )?);
        Ok(merge_plans(plans))
    }

    pub(super) fn unspill(&mut self, heap: &mut Heap) -> Result<(), Fault> {
        self.scalars.resize(self.bank_lengths.0, 0);
        self.references.resize(self.bank_lengths.1, 0);
        for frame in &self.spills {
            let (scalars, references) =
                pseudolearn_runtime::continuation::read_continuation(heap, frame.handle)
                    .map_err(super::memory::memory_fault)?;
            for (index, word) in frame.scalars.iter().zip(&scalars) {
                *self.scalars.get_mut(*index).ok_or(INVALID_BYTECODE)? = *word;
            }
            for (index, word) in frame
                .cells
                .iter()
                .zip(scalars.iter().skip(frame.scalars.len()))
            {
                *self.references.get_mut(*index).ok_or(INVALID_BYTECODE)? =
                    u32::try_from(*word).map_err(|_| INVALID_BYTECODE)?;
            }
            for (index, handle) in frame.references.iter().zip(&references) {
                *self.references.get_mut(*index).ok_or(INVALID_BYTECODE)? = handle.0;
            }
        }
        for frame in &self.spills {
            pseudolearn_runtime::continuation::clear_continuation(heap, frame.handle)
                .map_err(super::memory::memory_fault)?;
        }
        self.reusable = std::mem::take(&mut self.spills);
        Ok(())
    }

    fn extend_cells(&self, frame: &mut SpilledFrame) -> Result<(), Fault> {
        let mut scalars: BTreeSet<_> = frame.scalars.iter().copied().collect();
        let mut references: BTreeSet<_> = frame.references.iter().copied().collect();
        for index in &frame.cells {
            let bits = *self.references.get(*index).ok_or(INVALID_BYTECODE)?;
            if bits == 0 {
                continue;
            }
            let cell = self
                .cells
                .get(usize::try_from(bits.saturating_sub(1)).map_err(|_| INVALID_BYTECODE)?)
                .ok_or(INVALID_BYTECODE)?;
            if let Cell::Local { absolute, kind, .. } = cell {
                if *kind == ValueKind::Reference {
                    references.insert(*absolute);
                } else {
                    scalars.insert(*absolute);
                }
            }
        }
        frame.scalars = scalars.into_iter().collect();
        frame.references = references.into_iter().collect();
        Ok(())
    }

    fn spill_values(&self, frame: &SpilledFrame) -> Result<(Vec<u64>, Vec<Handle>), Fault> {
        let mut scalars = frame
            .scalars
            .iter()
            .map(|index| self.scalars.get(*index).copied().ok_or(INVALID_BYTECODE))
            .collect::<Result<Vec<_>, _>>()?;
        let mut references = frame
            .references
            .iter()
            .map(|index| {
                self.references
                    .get(*index)
                    .copied()
                    .map(Handle)
                    .ok_or(INVALID_BYTECODE)
            })
            .collect::<Result<Vec<_>, _>>()?;
        for index in &frame.cells {
            let bits = *self.references.get(*index).ok_or(INVALID_BYTECODE)?;
            scalars.push(u64::from(bits));
            if bits == 0 {
                continue;
            }
            let cell = self
                .cells
                .get(usize::try_from(bits.saturating_sub(1)).map_err(|_| INVALID_BYTECODE)?)
                .ok_or(INVALID_BYTECODE)?;
            if let Cell::Managed(cell) = cell {
                references.push(cell.owner);
            }
        }
        Ok((scalars, references))
    }
}

impl super::Machine<'_> {
    pub(super) fn cleanup_spill_plans(&self) -> Result<Vec<SpilledFrame>, Fault> {
        let points = self
            .tasks
            .cancel_points
            .get(&self.tasks.current)
            .into_iter()
            .flat_map(|points| points.values());
        let scopes = self
            .tasks
            .scope_stacks
            .get(&self.tasks.current)
            .into_iter()
            .flatten()
            .filter_map(|scope| self.tasks.scope_resumes.get(scope));
        points
            .chain(scopes)
            .map(|point| point.spill_plan(self.probed))
            .collect()
    }
}
