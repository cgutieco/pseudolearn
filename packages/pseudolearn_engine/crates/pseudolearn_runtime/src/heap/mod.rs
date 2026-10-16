mod allocate;
mod collect;
mod definition;
mod markset;

use pseudolearn_abi::Handle;
use std::collections::{BTreeMap, BTreeSet};

use crate::text::TextArena;
use crate::{MemoryError, MemoryOptions, ValueKind};

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

pub(crate) struct Allocation {
    pub physical: usize,
    pub elements: usize,
    pub cells: u64,
    pub shape: Shape,
    pub assigned: usize,
    pub payload: usize,
    pub literal: bool,
}

pub(crate) struct AllocationRequest {
    pub shape: Shape,
    pub payload: usize,
    pub elements: usize,
    pub auxiliary: usize,
    pub cells: u64,
    pub literal: bool,
}

pub struct Heap {
    pub(crate) words: Vec<u64>,
    pub(crate) used: usize,
    pub(crate) allocations: BTreeMap<Handle, Allocation>,
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
            words: Vec::new(),
            used: 1,
            allocations: BTreeMap::new(),
            free: BTreeMap::new(),
            arena: TextArena::default(),
            ordinal: 0,
            options,
            allocated_cells: 0,
            live_cells: 0,
        }
    }

    pub fn identity(&self, handle: Handle) -> Result<u64, MemoryError> {
        let allocation = self.allocations.get(&handle).ok_or(MemoryError::Internal)?;
        if matches!(allocation.shape, Shape::Text | Shape::Auxiliary) {
            return Err(MemoryError::Internal);
        }
        self.word(handle, 1)
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
}
