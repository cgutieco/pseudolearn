use super::{Heap, Shape};
use crate::{MemoryError, ValueKind};
use pseudolearn_abi::Handle;

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
        let entry = self
            .allocations
            .get_mut(&handle)
            .ok_or(MemoryError::Internal)?;
        entry.assigned = entry.assigned.checked_add(1).ok_or(MemoryError::Resource)?;
        if matches!(entry.shape, Shape::Array { .. }) && entry.assigned == entry.elements {
            let total = u64::try_from(entry.elements).map_err(|_| MemoryError::Internal)?;
            self.store(handle, 3, total)?;
            self.store(handle, 4, 0)?;
        }
        Ok(())
    }

    fn mask_location(
        &self,
        handle: Handle,
        index: usize,
    ) -> Result<Option<(usize, bool)>, MemoryError> {
        let entry = self.allocations.get(&handle).ok_or(MemoryError::Internal)?;
        let word = index.checked_div(64).ok_or(MemoryError::Internal)?;
        match &entry.shape {
            Shape::Object(_) if entry.payload > 2 => Ok(Some((
                2_usize.checked_add(word).ok_or(MemoryError::Internal)?,
                true,
            ))),
            Shape::Array {
                element: ValueKind::Integer,
                ..
            } => {
                if u64::try_from(index).map_err(|_| MemoryError::Internal)?
                    < self.word(handle, 3)?
                {
                    return Ok(None);
                }
                let base = self
                    .word(handle, 4)?
                    .checked_sub(u64::from(handle.0))
                    .ok_or(MemoryError::Internal)?;
                let offset = usize::try_from(base)
                    .map_err(|_| MemoryError::Internal)?
                    .checked_add(word)
                    .ok_or(MemoryError::Internal)?;
                Ok(Some((offset, false)))
            }
            _ => Ok(None),
        }
    }
}

fn bit(index: usize) -> Result<u64, MemoryError> {
    let shift = u32::try_from(index.checked_rem(64).ok_or(MemoryError::Internal)?)
        .map_err(|_| MemoryError::Internal)?;
    Ok(1_u64.wrapping_shl(shift))
}
