use super::Heap;
use super::markset::MarkSet;
use crate::{MemoryError, ValueKind};
use pseudolearn_abi::{
    ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, Handle, STRING_BREADCRUMBS_HANDLE_WORD_OFFSET,
};

impl Heap {
    pub fn reachable_cells(&self, roots: &[Handle]) -> Result<u64, MemoryError> {
        self.marked_cells(&self.reachable(roots)?)
    }

    pub(super) fn marked_cells(&self, reachable: &MarkSet) -> Result<u64, MemoryError> {
        reachable.handles.iter().try_fold(0_u64, |total, handle| {
            total
                .checked_add(self.block(*handle)?.cells)
                .ok_or(MemoryError::Resource)
        })
    }

    pub fn collect(&mut self, roots: &[Handle]) -> Result<(), MemoryError> {
        let reachable = self.reachable(roots)?;
        self.collect_marked(reachable)
    }

    pub(super) fn collect_marked(&mut self, reachable: MarkSet) -> Result<(), MemoryError> {
        #[cfg(feature = "telemetry")]
        self.record(|statistics| statistics.collections = statistics.collections.saturating_add(1));
        let live_cells = self.marked_cells(&reachable)?;
        let mut dead = Vec::new();
        for block in &self.blocks {
            if !reachable.contains(block.handle) && !self.is_literal(block.handle)? {
                dead.push(block.handle);
            }
        }
        for handle in dead {
            self.release_block(handle)?;
        }
        self.compact_text()?;
        self.live_cells = live_cells;
        self.allocated_cells = 0;
        Ok(())
    }

    pub(super) fn reachable(&self, roots: &[Handle]) -> Result<MarkSet, MemoryError> {
        #[cfg(feature = "telemetry")]
        self.record(|statistics| {
            statistics.reachability_walks = statistics.reachability_walks.saturating_add(1)
        });
        let mut marked = MarkSet::new(self.used)?;
        let mut pending = roots.to_vec();
        while let Some(handle) = pending.pop() {
            if handle.is_absent() || !marked.insert(handle)? {
                continue;
            }
            self.block(handle)?;
            self.visit_references(handle, &mut pending)?;
        }
        Ok(marked)
    }

    fn visit_references(
        &self,
        handle: Handle,
        pending: &mut Vec<Handle>,
    ) -> Result<(), MemoryError> {
        let header = self.header(handle)?;
        if matches!(
            header.shape_tag,
            pseudolearn_abi::vector_layout::VECTOR_SHAPE_TAG
                | pseudolearn_abi::dictionary_layout::DICTIONARY_SHAPE_TAG
        ) {
            return crate::collection::references(self, handle, pending);
        }
        if header.shape_tag == 1 {
            if self.array_element_kind(handle)? == ValueKind::Reference {
                let count = usize::try_from(self.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?)
                    .map_err(|_| MemoryError::Internal)?;
                self.reference_elements(handle, count, pending)?;
            }
        } else if header.shape_tag > 2 && header.shape_tag < u32::MAX {
            let references = self.layout(handle)?.references.clone();
            self.reference_fields(handle, &references, pending)?;
        } else if header.shape_tag == 2 {
            self.visit_text_index(handle, pending)?;
        }
        Ok(())
    }

    fn visit_text_index(
        &self,
        handle: Handle,
        pending: &mut Vec<Handle>,
    ) -> Result<(), MemoryError> {
        let auxiliary = self.word(handle, STRING_BREADCRUMBS_HANDLE_WORD_OFFSET)?;
        if auxiliary == 0 {
            return Ok(());
        }
        pending.push(Handle(
            u32::try_from(auxiliary).map_err(|_| MemoryError::Internal)?,
        ));
        Ok(())
    }

    fn reference_elements(
        &self,
        handle: Handle,
        count: usize,
        pending: &mut Vec<Handle>,
    ) -> Result<(), MemoryError> {
        let offset = self.array_payload(handle)?;
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
        let offset = self.object_payload(handle)?;
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

    pub(crate) fn release_block(&mut self, handle: Handle) -> Result<(), MemoryError> {
        let block = self.remove_block(handle)?;
        self.store(handle, 0, 0)?;
        let physical = usize::try_from(block.physical).map_err(|_| MemoryError::Internal)?;
        let address = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
        self.free.entry(physical).or_default().insert(address);
        Ok(())
    }
}
