use super::{AllocationRequest, BlockRecord, Heap, Shape};
use crate::{CollectionPolicy, MemoryError, ValueKind};
use pseudolearn_abi::{
    ARRAY_KIND_STATUS_SHIFT, ARRAY_RANK_STATUS_SHIFT, COMMON_HEADER_WORDS, CommonHeader, Handle,
    LITERAL_STATUS_MASK,
};

impl Heap {
    pub(crate) fn allocate(
        &mut self,
        request: AllocationRequest,
        roots: &[Handle],
    ) -> Result<Handle, MemoryError> {
        #[cfg(feature = "telemetry")]
        self.record(|statistics| statistics.allocations = statistics.allocations.saturating_add(1));
        let (shape_tag, status_flags) = header_shape(&request)?;
        if !matches!(request.shape, Shape::Auxiliary) {
            self.prepare(request.cells, roots)?;
        }
        self.prepare_metadata(&request.shape)?;
        let physical = allocation_size(&request)?;
        self.blocks
            .try_reserve(1)
            .map_err(|_| MemoryError::Resource)?;
        let address = self.reserve(physical)?;
        let handle = Handle(u32::try_from(address).map_err(|_| MemoryError::Resource)?);
        if !matches!(request.shape, Shape::Text | Shape::Auxiliary) {
            self.ordinal = self.ordinal.checked_add(1).ok_or(MemoryError::Resource)?;
        }
        self.initialize_words(address, physical, &request)?;
        let identity = if matches!(request.shape, Shape::Text | Shape::Auxiliary) {
            0
        } else {
            self.ordinal
        };
        write_header(
            self,
            handle,
            CommonHeader::new(shape_tag, status_flags, identity),
        )?;
        self.register_block(handle, request.cells, physical)?;
        self.store_allocation_layout(request.shape)?;
        Ok(handle)
    }

    fn store_allocation_layout(&mut self, shape: Shape) -> Result<(), MemoryError> {
        if let Shape::Object(layout) = shape {
            let index = usize::try_from(layout.class).map_err(|_| MemoryError::Resource)?;
            if self.layouts.get(index).and_then(Option::as_ref).is_some() {
                return Ok(());
            }
            #[cfg(feature = "telemetry")]
            self.record(|statistics| {
                statistics.layout_copies = statistics.layout_copies.saturating_add(1)
            });
            self.store_layout((*layout).clone())?;
        }
        Ok(())
    }

    fn prepare_metadata(&mut self, shape: &Shape) -> Result<(), MemoryError> {
        let Shape::Object(layout) = shape else {
            return Ok(());
        };
        self.ensure_layout_capacity(layout.class)?;
        let index = usize::try_from(layout.class).map_err(|_| MemoryError::Resource)?;
        if self
            .layouts
            .get(index)
            .and_then(Option::as_ref)
            .is_some_and(|existing| existing != layout.as_ref())
        {
            return Err(MemoryError::Internal);
        }
        Ok(())
    }

    fn initialize_words(
        &mut self,
        address: usize,
        physical: usize,
        request: &AllocationRequest,
    ) -> Result<(), MemoryError> {
        #[cfg(feature = "telemetry")]
        self.record(|statistics| {
            statistics.initialized_words = statistics.initialized_words.saturating_add(
                u64::try_from(physical.saturating_mul(2).saturating_sub(request.payload))
                    .unwrap_or(u64::MAX),
            )
        });
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

    fn register_block(
        &mut self,
        handle: Handle,
        cells: u64,
        physical: usize,
    ) -> Result<(), MemoryError> {
        self.add_block(BlockRecord {
            handle,
            physical: u32::try_from(physical).map_err(|_| MemoryError::Resource)?,
            cells,
        })?;
        self.allocated_cells = self
            .allocated_cells
            .checked_add(cells)
            .ok_or(MemoryError::Resource)?;
        Ok(())
    }

    pub(crate) fn prepare(&mut self, cells: u64, roots: &[Handle]) -> Result<(), MemoryError> {
        let bound = self
            .live_cells
            .checked_add(self.allocated_cells)
            .and_then(|count| count.checked_add(cells))
            .ok_or(MemoryError::Resource)?;
        let threshold = self.collection_threshold();
        if self.options.collection == CollectionPolicy::Forced
            || bound > self.options.cells
            || self.allocated_cells >= threshold
        {
            let reachable = self.reachable(roots)?;
            let live = self.marked_cells(&reachable)?;
            if live.checked_add(cells).ok_or(MemoryError::Resource)? > self.options.cells {
                return Err(MemoryError::CellLimit);
            }
            if self.options.collection != CollectionPolicy::Disabled {
                self.collect_marked(reachable)?;
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
            #[cfg(feature = "telemetry")]
            self.record(|statistics| {
                statistics.heap_growths = statistics.heap_growths.saturating_add(1)
            });
            self.words
                .try_reserve(end.saturating_sub(self.words.len()))
                .map_err(|_| MemoryError::Resource)?;
            self.words.resize(end, 0);
        }
        let address = self.used;
        self.used = end;
        Ok(address)
    }
}

fn allocation_size(request: &AllocationRequest) -> Result<usize, MemoryError> {
    request
        .payload
        .checked_add(request.elements)
        .and_then(|count| count.checked_add(request.auxiliary))
        .ok_or(MemoryError::Resource)
}

fn initial_kind(shape: &Shape) -> ValueKind {
    match shape {
        Shape::Array { element, .. } => *element,
        _ => ValueKind::Integer,
    }
}

fn header_shape(request: &AllocationRequest) -> Result<(u32, u32), MemoryError> {
    let literal = if request.literal {
        LITERAL_STATUS_MASK
    } else {
        0
    };
    match &request.shape {
        Shape::Array {
            element,
            dimensions,
        } => array_header(*element, dimensions, literal),
        Shape::Object(layout) => {
            let tag = layout.class.checked_add(3).ok_or(MemoryError::Resource)?;
            if tag >= pseudolearn_abi::continuation_layout::CONTINUATION_SHAPE_TAG {
                return Err(MemoryError::Resource);
            }
            let payload = u16::try_from(request.payload).map_err(|_| MemoryError::Resource)?;
            Ok((tag, u32::from(payload) | literal))
        }
        Shape::Text => Ok((2, literal)),
        Shape::Auxiliary => Ok((u32::MAX, 0)),
        Shape::Vector => Ok((pseudolearn_abi::vector_layout::VECTOR_SHAPE_TAG, 0)),
        Shape::Dictionary => Ok((pseudolearn_abi::dictionary_layout::DICTIONARY_SHAPE_TAG, 0)),
        Shape::Task => Ok((pseudolearn_abi::task_layout::TASK_SHAPE_TAG, 0)),
        Shape::Continuation => Ok((
            pseudolearn_abi::continuation_layout::CONTINUATION_SHAPE_TAG,
            0,
        )),
        Shape::Channel => Ok((pseudolearn_abi::channel_layout::CHANNEL_SHAPE_TAG, 0)),
        Shape::Bytes => Ok((pseudolearn_abi::bytes_layout::BYTES_SHAPE_TAG, 0)),
        Shape::Capability => Ok((pseudolearn_abi::capability_layout::CAPABILITY_SHAPE_TAG, 0)),
        Shape::JsonBlock => Ok((pseudolearn_abi::json_layout::JSON_BLOCK_SHAPE_TAG, 0)),
        Shape::JsonView => Ok((pseudolearn_abi::json_layout::JSON_VIEW_SHAPE_TAG, 0)),
    }
}

fn encode_value_kind(kind: ValueKind) -> Result<u32, MemoryError> {
    let code: u32 = match kind {
        ValueKind::Integer => 0,
        ValueKind::Real => 1,
        ValueKind::Boolean => 2,
        ValueKind::Character => 3,
        ValueKind::Reference => 4,
    };
    Ok(code.wrapping_shl(ARRAY_KIND_STATUS_SHIFT))
}

fn write_header(heap: &mut Heap, handle: Handle, header: CommonHeader) -> Result<(), MemoryError> {
    let [shape_and_flags, identity] = header.to_words();
    heap.store(handle, 0, shape_and_flags.as_u64())?;
    heap.store(handle, 1, identity.as_u64())
}

fn array_header(
    element: ValueKind,
    dimensions: &[u64],
    literal: u32,
) -> Result<(u32, u32), MemoryError> {
    let rank = u32::try_from(dimensions.len()).map_err(|_| MemoryError::Resource)?;
    if rank == 0 || rank > u32::from(u8::MAX) {
        return Err(MemoryError::Resource);
    }
    Ok((
        1,
        encode_value_kind(element)? | rank.wrapping_shl(ARRAY_RANK_STATUS_SHIFT) | literal,
    ))
}
