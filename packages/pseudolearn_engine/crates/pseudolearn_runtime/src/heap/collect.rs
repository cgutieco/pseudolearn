use super::markset::MarkSet;
use super::{Heap, Shape};
use crate::{MemoryError, ValueKind};
use pseudolearn_abi::Handle;

impl Heap {
    pub fn reachable_cells(&self, roots: &[Handle]) -> Result<u64, MemoryError> {
        self.reachable(roots)?
            .handles
            .iter()
            .try_fold(0_u64, |total, handle| {
                total
                    .checked_add(
                        self.allocations
                            .get(handle)
                            .ok_or(MemoryError::Internal)?
                            .cells,
                    )
                    .ok_or(MemoryError::Resource)
            })
    }

    pub fn collect(&mut self, roots: &[Handle]) -> Result<(), MemoryError> {
        let reachable = self.reachable(roots)?;
        let dead = self
            .allocations
            .iter()
            .filter(|(handle, entry)| !entry.literal && !reachable.contains(**handle))
            .map(|(handle, _)| *handle)
            .collect::<Vec<_>>();
        for handle in dead {
            let entry = self
                .allocations
                .remove(&handle)
                .ok_or(MemoryError::Internal)?;
            self.free
                .entry(entry.physical)
                .or_default()
                .insert(usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?);
        }
        self.compact_text()?;
        self.live_cells = self.reachable_cells(roots)?;
        self.allocated_cells = 0;
        Ok(())
    }

    fn reachable(&self, roots: &[Handle]) -> Result<MarkSet, MemoryError> {
        let mut marked = MarkSet::new(self.used)?;
        let mut pending = roots.to_vec();
        while let Some(handle) = pending.pop() {
            if handle.is_absent() || !marked.insert(handle)? {
                continue;
            }
            let entry = self.allocations.get(&handle).ok_or(MemoryError::Internal)?;
            match &entry.shape {
                Shape::Array {
                    element: ValueKind::Reference,
                    ..
                } => {
                    self.reference_elements(handle, entry.elements, &mut pending)?;
                }
                Shape::Object(layout) => {
                    self.reference_fields(handle, &layout.references, &mut pending)?;
                }
                Shape::Text => {
                    let auxiliary = self.word(handle, 4)?;
                    if auxiliary != 0 {
                        pending.push(Handle(
                            u32::try_from(auxiliary).map_err(|_| MemoryError::Internal)?,
                        ));
                    }
                }
                _ => {}
            }
        }
        Ok(marked)
    }

    fn reference_elements(
        &self,
        handle: Handle,
        count: usize,
        pending: &mut Vec<Handle>,
    ) -> Result<(), MemoryError> {
        let offset = self
            .allocations
            .get(&handle)
            .ok_or(MemoryError::Internal)?
            .payload;
        for index in 0..count {
            let bits = self.word(
                handle,
                offset.checked_add(index).ok_or(MemoryError::Internal)?,
            )?;
            pending.push(Handle(
                u32::try_from(bits).map_err(|_| MemoryError::Internal)?,
            ));
        }
        Ok(())
    }

    fn reference_fields(
        &self,
        handle: Handle,
        fields: &[usize],
        pending: &mut Vec<Handle>,
    ) -> Result<(), MemoryError> {
        let offset = self
            .allocations
            .get(&handle)
            .ok_or(MemoryError::Internal)?
            .payload;
        for index in fields {
            let bits = self.word(
                handle,
                offset.checked_add(*index).ok_or(MemoryError::Internal)?,
            )?;
            pending.push(Handle(
                u32::try_from(bits).map_err(|_| MemoryError::Internal)?,
            ));
        }
        Ok(())
    }
}
