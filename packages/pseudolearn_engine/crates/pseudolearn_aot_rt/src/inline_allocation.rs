use crate::context::AotRuntimeContext;
use crate::engine::AotEngine;
use crate::kinds::kind_from_code;
use crate::trap::Trap;
use pseudolearn_abi::{CommonHeader, Handle, object_fields_start_offset};
use pseudolearn_runtime::{InlineBlock, MemoryError};

pub const INLINE_PENDING_CAPACITY: usize = 256;
pub const INLINE_RECORD_WORDS: usize = 2;
pub const INLINE_PHYSICAL_SHIFT: u32 = 32;
pub const INLINE_MAXIMUM_PHYSICAL: usize = 64;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct InlineObjectImage {
    pub physical: u32,
    pub cells: u64,
    pub header: u64,
    pub words: Vec<u64>,
}

pub fn inline_object_image(class: u32, fields: &[u32], dense: bool) -> Option<InlineObjectImage> {
    let payload = object_fields_start_offset(fields.len(), dense)?;
    let physical = payload.checked_add(fields.len())?;
    if physical > INLINE_MAXIMUM_PHYSICAL {
        return None;
    }
    let tag = class.checked_add(3).filter(|tag| *tag != u32::MAX)?;
    let status = u32::try_from(payload).ok().filter(|_| payload <= 0xFFFF)?;
    let [header, _] = CommonHeader::new(tag, status, 0).to_words();
    let mut words = vec![u64::MAX; payload.checked_sub(2)?];
    for code in fields {
        words.push(kind_from_code(*code).ok()?.absent());
    }
    Some(InlineObjectImage {
        physical: u32::try_from(physical).ok()?,
        cells: u64::try_from(fields.len()).ok()?.checked_add(1)?,
        header: header.as_u64(),
        words,
    })
}

impl AotEngine {
    pub(crate) fn settle_inline(
        &mut self,
        context: &mut AotRuntimeContext,
    ) -> Result<(), MemoryError> {
        let count = usize::try_from(context.pending_length).map_err(|_| MemoryError::Internal)?;
        if count == 0 {
            return Ok(());
        }
        let blocks = self.pending_blocks(count)?;
        self.heap
            .adopt_inline((context.heap_used, context.heap_ordinal), &blocks)?;
        context.pending_length = 0;
        Ok(())
    }

    fn pending_blocks(&self, count: usize) -> Result<Vec<InlineBlock>, MemoryError> {
        let words = count
            .checked_mul(INLINE_RECORD_WORDS)
            .and_then(|length| self.pending.get(..length))
            .ok_or(MemoryError::Internal)?;
        let (records, _) = words.as_chunks::<INLINE_RECORD_WORDS>();
        Ok(records
            .iter()
            .map(|[packed, cells]| InlineBlock {
                handle: Handle(u32::try_from(packed & 0xFFFF_FFFF).unwrap_or(0)),
                physical: u32::try_from(packed.wrapping_shr(INLINE_PHYSICAL_SHIFT)).unwrap_or(0),
                cells: *cells,
            })
            .collect())
    }

    pub(crate) fn publish_inline(&mut self, context: &mut AotRuntimeContext) {
        context.pending_pointer = self.pending.as_mut_ptr();
        context.pending_capacity = u64::try_from(INLINE_PENDING_CAPACITY).unwrap_or(0);
        context.pending_length = 0;
        match self.heap.inline_window() {
            Ok(window) => {
                context.heap_used = window.used;
                context.heap_limit = window.limit;
                context.heap_ordinal = window.ordinal;
                context.room_cells = window.room_cells;
                context.room_threshold = window.room_threshold;
                context.free_size_mask = window.free_size_mask;
            }
            Err(_) => {
                context.room_cells = 0;
                context.room_threshold = 0;
            }
        }
        context.heap_words_pointer = self.heap.words_pointer();
    }
}

pub(crate) fn settle_failure() -> Trap {
    Trap::named("internalFault")
}
