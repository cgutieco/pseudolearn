use super::Heap;
use crate::{MemoryError, ValueKind};
use pseudolearn_abi::{
    ARRAY_DEFINITION_MAP_WORD_OFFSET, ARRAY_DENSE_BOUNDARY_WORD_OFFSET,
    ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, Handle, OBJECT_INTEGER_MASK_WORD_OFFSET,
};

impl Heap {
    pub(crate) fn require(
        &self,
        handle: Handle,
        index: usize,
        (kind, word): (ValueKind, u64),
    ) -> Result<u64, MemoryError> {
        let defined = match kind {
            ValueKind::Integer => self.integer_defined(handle, index)?,
            ValueKind::Real => !f64::from_bits(word).is_nan(),
            _ => word != kind.absent(),
        };
        if defined {
            Ok(word)
        } else {
            Err(MemoryError::Uninitialized)
        }
    }

    pub(crate) fn integer_defined(
        &self,
        handle: Handle,
        index: usize,
    ) -> Result<bool, MemoryError> {
        let Some((offset, absence)) = self.mask_location(handle, index)? else {
            return Ok(true);
        };
        let word = self.word(handle, offset)?;
        Ok((word & bit(index)? == 0) == absence)
    }

    pub(crate) fn define_integer(
        &mut self,
        handle: Handle,
        index: usize,
    ) -> Result<(), MemoryError> {
        if self.integer_defined(handle, index)? {
            return Ok(());
        }
        let Some((offset, absence)) = self.mask_location(handle, index)? else {
            return Ok(());
        };
        let word = self.word(handle, offset)?;
        let mask = bit(index)?;
        self.store(
            handle,
            offset,
            if absence { word & !mask } else { word | mask },
        )?;
        self.advance_array_definition(handle)
    }

    fn mask_location(
        &self,
        handle: Handle,
        index: usize,
    ) -> Result<Option<(usize, bool)>, MemoryError> {
        let header = self.header(handle)?;
        if header.shape_tag == 1 {
            return self.array_mask_location(handle, index);
        }
        if header.shape_tag > 2 && header.shape_tag < u32::MAX {
            return self.object_mask_location(handle, index);
        }
        Ok(None)
    }

    fn array_mask_location(
        &self,
        handle: Handle,
        index: usize,
    ) -> Result<Option<(usize, bool)>, MemoryError> {
        let total = self.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?;
        let assigned = self.word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)?;
        if assigned == total {
            return Ok(None);
        }
        let base = self
            .word(handle, ARRAY_DEFINITION_MAP_WORD_OFFSET)?
            .checked_sub(u64::from(handle.0))
            .ok_or(MemoryError::Internal)?;
        let offset = usize::try_from(base)
            .map_err(|_| MemoryError::Internal)?
            .checked_add(index.checked_div(64).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Internal)?;
        Ok(Some((offset, false)))
    }

    fn object_mask_location(
        &self,
        handle: Handle,
        index: usize,
    ) -> Result<Option<(usize, bool)>, MemoryError> {
        if self.object_payload(handle)? == OBJECT_INTEGER_MASK_WORD_OFFSET {
            return Ok(None);
        }
        Ok(Some((
            OBJECT_INTEGER_MASK_WORD_OFFSET
                .checked_add(index.checked_div(64).ok_or(MemoryError::Internal)?)
                .ok_or(MemoryError::Internal)?,
            true,
        )))
    }

    fn advance_array_definition(&mut self, handle: Handle) -> Result<(), MemoryError> {
        if !self.is_array(handle)? {
            return Ok(());
        }
        let assigned = self
            .word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)?
            .checked_add(1)
            .ok_or(MemoryError::Resource)?;
        self.store(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET, assigned)?;
        if assigned == self.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)? {
            self.store(handle, ARRAY_DEFINITION_MAP_WORD_OFFSET, 0)?;
        }
        Ok(())
    }
}

fn bit(index: usize) -> Result<u64, MemoryError> {
    let shift = u32::try_from(index.checked_rem(64).ok_or(MemoryError::Internal)?)
        .map_err(|_| MemoryError::Internal)?;
    Ok(1_u64.wrapping_shl(shift))
}
