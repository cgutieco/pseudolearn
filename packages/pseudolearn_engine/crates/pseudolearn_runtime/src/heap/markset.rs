use crate::{Handle, MemoryError};

pub(super) struct MarkSet {
    bits: Vec<u64>,
    pub handles: Vec<Handle>,
}

impl MarkSet {
    pub fn new(words: usize) -> Result<Self, MemoryError> {
        let count = words
            .checked_add(63)
            .and_then(|count| count.checked_div(64))
            .ok_or(MemoryError::Resource)?;
        let mut bits = Vec::new();
        bits.try_reserve_exact(count)
            .map_err(|_| MemoryError::Resource)?;
        bits.resize(count, 0);
        Ok(Self {
            bits,
            handles: Vec::new(),
        })
    }

    pub fn insert(&mut self, handle: Handle) -> Result<bool, MemoryError> {
        let index = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
        let word = index.checked_div(64).ok_or(MemoryError::Internal)?;
        let shift = u32::try_from(index.checked_rem(64).ok_or(MemoryError::Internal)?)
            .map_err(|_| MemoryError::Internal)?;
        let mask = 1_u64.wrapping_shl(shift);
        let bits = self.bits.get_mut(word).ok_or(MemoryError::Internal)?;
        if *bits & mask != 0 {
            return Ok(false);
        }
        *bits |= mask;
        self.handles
            .try_reserve(1)
            .map_err(|_| MemoryError::Resource)?;
        self.handles.push(handle);
        Ok(true)
    }

    pub fn contains(&self, handle: Handle) -> bool {
        let index = usize::try_from(handle.0).unwrap_or(usize::MAX);
        let word = index.checked_div(64).unwrap_or(usize::MAX);
        let shift = u32::try_from(index.checked_rem(64).unwrap_or(0)).unwrap_or(0);
        self.bits
            .get(word)
            .is_some_and(|bits| bits & 1_u64.wrapping_shl(shift) != 0)
    }
}
