mod allocate;
mod collect;
mod definition;
mod layouts;
mod markset;

use pseudolearn_abi::{
    ARRAY_KIND_STATUS_MASK, ARRAY_KIND_STATUS_SHIFT, ARRAY_RANK_STATUS_MASK,
    ARRAY_RANK_STATUS_SHIFT, CommonHeader, Handle, LITERAL_STATUS_MASK, OBJECT_PAYLOAD_STATUS_MASK,
    STRING_BREADCRUMBS_HANDLE_WORD_OFFSET, Word,
};
use std::collections::{BTreeMap, BTreeSet};

use crate::text::TextArena;
use crate::{CollectionPolicy, MemoryError, MemoryOptions, ValueKind};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ObjectLayout {
    pub class: u32,
    pub fields: Vec<ValueKind>,
    pub dense: bool,
    pub references: Vec<usize>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum Shape {
    Array {
        element: ValueKind,
        dimensions: Vec<u64>,
    },
    Object(std::sync::Arc<ObjectLayout>),
    Text,
    Auxiliary,
}

pub(crate) struct AllocationRequest {
    pub shape: Shape,
    pub payload: usize,
    pub elements: usize,
    pub auxiliary: usize,
    pub cells: u64,
    pub literal: bool,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct BlockRecord {
    pub handle: Handle,
    pub physical: u32,
    pub cells: u64,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Heap {
    #[cfg(feature = "telemetry")]
    pub(crate) statistics: std::cell::Cell<crate::HeapStatistics>,
    pub(crate) words: Vec<u64>,
    pub(crate) used: usize,
    pub(crate) blocks: Vec<BlockRecord>,
    pub(crate) layouts: Vec<Option<ObjectLayout>>,
    pub(crate) free: BTreeMap<usize, BTreeSet<usize>>,
    pub(crate) arena: TextArena,
    pub(crate) ordinal: u64,
    pub(crate) options: MemoryOptions,
    pub(crate) allocated_cells: u64,
    pub(crate) live_cells: u64,
}

impl Heap {
    pub fn new(options: MemoryOptions) -> Self {
        Self {
            #[cfg(feature = "telemetry")]
            statistics: std::cell::Cell::default(),
            words: vec![0],
            used: 1,
            blocks: Vec::new(),
            layouts: Vec::new(),
            free: BTreeMap::new(),
            arena: TextArena::default(),
            ordinal: 0,
            options,
            allocated_cells: 0,
            live_cells: 0,
        }
    }

    pub fn set_collection_policy(&mut self, collection: CollectionPolicy) {
        self.options.collection = collection;
    }

    pub fn needs_collection(&self, cells: u64) -> bool {
        self.options.collection == CollectionPolicy::Forced
            || self
                .live_cells
                .saturating_add(self.allocated_cells)
                .saturating_add(cells)
                > self.options.cells
            || self.allocated_cells >= self.live_cells.max(4096)
    }

    pub fn identity(&self, handle: Handle) -> Result<u64, MemoryError> {
        let header = self.header(handle)?;
        if header.shape_tag != 1 && (header.shape_tag <= 2 || header.shape_tag == u32::MAX) {
            return Err(MemoryError::Internal);
        }
        self.word(handle, 1)
    }

    pub fn register_layout(&mut self, layout: ObjectLayout) -> Result<(), MemoryError> {
        self.ensure_layout_capacity(layout.class)?;
        self.store_layout(layout)
    }

    pub(crate) fn header(&self, handle: Handle) -> Result<CommonHeader, MemoryError> {
        let address = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
        let first = self
            .words
            .get(address)
            .copied()
            .ok_or(MemoryError::Internal)?;
        let second = self
            .words
            .get(address.checked_add(1).ok_or(MemoryError::Internal)?)
            .copied()
            .ok_or(MemoryError::Internal)?;
        CommonHeader::from_words([Word::from_u64(first), Word::from_u64(second)])
            .ok_or(MemoryError::Internal)
    }

    pub(crate) fn layout(&self, handle: Handle) -> Result<&ObjectLayout, MemoryError> {
        let header = self.header(handle)?;
        let class = header
            .shape_tag
            .checked_sub(3)
            .filter(|_| header.shape_tag > 2 && header.shape_tag < u32::MAX)
            .ok_or(MemoryError::Internal)?;
        self.layouts
            .get(usize::try_from(class).map_err(|_| MemoryError::Internal)?)
            .and_then(Option::as_ref)
            .ok_or(MemoryError::Internal)
    }

    pub(crate) fn is_array(&self, handle: Handle) -> Result<bool, MemoryError> {
        Ok(self.header(handle)?.shape_tag == 1)
    }

    pub(crate) fn array_element_kind(&self, handle: Handle) -> Result<ValueKind, MemoryError> {
        let header = self.header(handle)?;
        if header.shape_tag != 1 {
            return Err(MemoryError::Internal);
        }
        let raw = (header.status_flags & ARRAY_KIND_STATUS_MASK)
            .checked_shr(ARRAY_KIND_STATUS_SHIFT)
            .ok_or(MemoryError::Internal)?;
        value_kind(raw)
    }

    pub(crate) fn array_rank(&self, handle: Handle) -> Result<usize, MemoryError> {
        let header = self.header(handle)?;
        if header.shape_tag != 1 {
            return Err(MemoryError::Internal);
        }
        let rank = (header.status_flags & ARRAY_RANK_STATUS_MASK)
            .checked_shr(ARRAY_RANK_STATUS_SHIFT)
            .ok_or(MemoryError::Internal)?;
        let rank = usize::try_from(rank).map_err(|_| MemoryError::Internal)?;
        if rank == 0 {
            return Err(MemoryError::Internal);
        }
        Ok(rank)
    }

    pub(crate) fn array_payload(&self, handle: Handle) -> Result<usize, MemoryError> {
        let rank = u32::try_from(self.array_rank(handle)?).map_err(|_| MemoryError::Internal)?;
        Ok(pseudolearn_abi::array_elements_start_offset(rank))
    }

    pub(crate) fn object_payload(&self, handle: Handle) -> Result<usize, MemoryError> {
        let header = self.header(handle)?;
        let layout = self.layout(handle)?;
        let payload = usize::try_from(header.status_flags & OBJECT_PAYLOAD_STATUS_MASK)
            .map_err(|_| MemoryError::Internal)?;
        let expected =
            pseudolearn_abi::object_fields_start_offset(layout.fields.len(), layout.dense)
                .ok_or(MemoryError::Internal)?;
        if payload != expected {
            return Err(MemoryError::Internal);
        }
        Ok(payload)
    }

    pub(crate) fn block(&self, handle: Handle) -> Result<BlockRecord, MemoryError> {
        self.blocks
            .binary_search_by_key(&handle, |block| block.handle)
            .ok()
            .and_then(|index| self.blocks.get(index).copied())
            .ok_or(MemoryError::Internal)
    }

    pub(crate) fn add_block(&mut self, block: BlockRecord) -> Result<(), MemoryError> {
        self.blocks
            .try_reserve(1)
            .map_err(|_| MemoryError::Resource)?;
        let index = match self
            .blocks
            .binary_search_by_key(&block.handle, |entry| entry.handle)
        {
            Ok(_) => return Err(MemoryError::Internal),
            Err(index) => index,
        };
        self.blocks.insert(index, block);
        Ok(())
    }

    pub(crate) fn remove_block(&mut self, handle: Handle) -> Result<BlockRecord, MemoryError> {
        let index = self
            .blocks
            .binary_search_by_key(&handle, |block| block.handle)
            .map_err(|_| MemoryError::Internal)?;
        Ok(self.blocks.remove(index))
    }

    pub(crate) fn is_literal(&self, handle: Handle) -> Result<bool, MemoryError> {
        Ok(self.header(handle)?.status_flags & LITERAL_STATUS_MASK != 0)
    }

    pub(crate) fn is_text(&self, handle: Handle) -> Result<bool, MemoryError> {
        Ok(self.header(handle)?.shape_tag == 2)
    }

    pub(crate) fn is_auxiliary(&self, handle: Handle) -> Result<bool, MemoryError> {
        Ok(self.header(handle)?.shape_tag == u32::MAX)
    }

    pub(crate) fn clear_text_index(&mut self, handle: Handle) -> Result<(), MemoryError> {
        self.store(handle, STRING_BREADCRUMBS_HANDLE_WORD_OFFSET, 0)
    }

    pub(crate) fn word(&self, handle: Handle, offset: usize) -> Result<u64, MemoryError> {
        let address = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
        self.words
            .get(address.checked_add(offset).ok_or(MemoryError::Internal)?)
            .copied()
            .ok_or(MemoryError::Internal)
    }

    pub(crate) fn store(
        &mut self,
        handle: Handle,
        offset: usize,
        word: u64,
    ) -> Result<(), MemoryError> {
        let address = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
        *self
            .words
            .get_mut(address.checked_add(offset).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Internal)? = word;
        Ok(())
    }

    pub fn words_pointer(&mut self) -> *mut u64 {
        self.words.as_mut_ptr()
    }

    pub fn shrink_to_fit(&mut self) {
        self.words.truncate(self.used);
        self.words.shrink_to_fit();
        self.blocks.shrink_to_fit();
        self.layouts.shrink_to_fit();
    }
}

pub(crate) fn value_kind(code: u32) -> Result<ValueKind, MemoryError> {
    match code {
        0 => Ok(ValueKind::Integer),
        1 => Ok(ValueKind::Real),
        2 => Ok(ValueKind::Boolean),
        3 => Ok(ValueKind::Character),
        4 => Ok(ValueKind::Reference),
        _ => Err(MemoryError::Internal),
    }
}
