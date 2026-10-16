use super::{Allocation, AllocationRequest, Heap, Shape};
use crate::{CollectionPolicy, MemoryError, ValueKind};
use pseudolearn_abi::{COMMON_HEADER_WORDS, Handle};

impl Heap {
    pub(crate) fn allocate(
        &mut self,
        request: AllocationRequest,
        roots: &[Handle],
    ) -> Result<Handle, MemoryError> {
        if !matches!(request.shape, Shape::Auxiliary) {
            self.prepare(request.cells, roots)?;
        }
        let physical = request
            .payload
            .checked_add(request.elements)
            .and_then(|count| count.checked_add(request.auxiliary))
            .ok_or(MemoryError::Resource)?;
        let address = self.reserve(physical)?;
        let handle = Handle(u32::try_from(address).map_err(|_| MemoryError::Resource)?);
        if !matches!(request.shape, Shape::Text | Shape::Auxiliary) {
            self.ordinal = self.ordinal.checked_add(1).ok_or(MemoryError::Resource)?;
        }
        self.initialize_words(address, physical, &request)?;
        let shape_tag = shape_tag(&request.shape)?;
        self.store(handle, 0, shape_tag)?;
        self.store(handle, 1, self.ordinal)?;
        self.register_allocation(handle, request, physical)?;
        Ok(handle)
    }

    fn initialize_words(
        &mut self,
        address: usize,
        physical: usize,
        request: &AllocationRequest,
    ) -> Result<(), MemoryError> {
        let kind = initial_kind(&request.shape);
        let end = address.checked_add(physical).ok_or(MemoryError::Resource)?;
        self.words
            .get_mut(address..end)
            .ok_or(MemoryError::Internal)?
            .fill(0);
        self.words
            .get_mut(
                address
                    .checked_add(request.payload)
                    .ok_or(MemoryError::Resource)?..end,
            )
            .ok_or(MemoryError::Internal)?
            .fill(kind.absent());
        Ok(())
    }

    fn register_allocation(
        &mut self,
        handle: Handle,
        request: AllocationRequest,
        physical: usize,
    ) -> Result<(), MemoryError> {
        self.allocations.insert(
            handle,
            Allocation {
                physical,
                elements: request.elements,
                cells: request.cells,
                shape: request.shape,
                assigned: 0,
                payload: request.payload,
                literal: request.literal,
            },
        );
        self.allocated_cells = self
            .allocated_cells
            .checked_add(request.cells)
            .ok_or(MemoryError::Resource)?;
        Ok(())
    }

    fn prepare(&mut self, cells: u64, roots: &[Handle]) -> Result<(), MemoryError> {
        let bound = self
            .live_cells
            .checked_add(self.allocated_cells)
            .and_then(|count| count.checked_add(cells))
            .ok_or(MemoryError::Resource)?;
        let threshold = self.live_cells.max(4096);
        if self.options.collection == CollectionPolicy::Forced
            || bound > self.options.cells
            || self.allocated_cells >= threshold
        {
            let live = self.reachable_cells(roots)?;
            if live.checked_add(cells).ok_or(MemoryError::Resource)? > self.options.cells {
                return Err(MemoryError::CellLimit);
            }
            if self.options.collection != CollectionPolicy::Disabled {
                self.collect(roots)?;
            }
        }
        Ok(())
    }

    fn reserve(&mut self, physical: usize) -> Result<usize, MemoryError> {
        if physical < COMMON_HEADER_WORDS {
            return Err(MemoryError::Internal);
        }
        if let Some(addresses) = self.free.get_mut(&physical)
            && let Some(address) = addresses.pop_first()
        {
            return Ok(address);
        }
        let end = self
            .used
            .checked_add(physical)
            .ok_or(MemoryError::Resource)?;
        u32::try_from(end).map_err(|_| MemoryError::Resource)?;
        if end > self.words.len() {
            let capacity = end
                .max(4096)
                .checked_next_power_of_two()
                .ok_or(MemoryError::Resource)?;
            self.words
                .try_reserve_exact(capacity.saturating_sub(self.words.len()))
                .map_err(|_| MemoryError::Resource)?;
            self.words.resize(capacity, 0);
        }
        let address = self.used;
        self.used = end;
        Ok(address)
    }
}

fn initial_kind(shape: &Shape) -> ValueKind {
    match shape {
        Shape::Array { element, .. } => *element,
        _ => ValueKind::Integer,
    }
}

fn shape_tag(shape: &Shape) -> Result<u64, MemoryError> {
    match shape {
        Shape::Array { .. } => Ok(1),
        Shape::Object(layout) => u64::from(layout.class)
            .checked_add(3)
            .ok_or(MemoryError::Resource),
        Shape::Text => Ok(2),
        Shape::Auxiliary => Ok(u64::from(u32::MAX)),
    }
}
