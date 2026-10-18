use super::{Heap, ObjectLayout};
use crate::MemoryError;

impl Heap {
    pub(crate) fn ensure_layout_capacity(&mut self, class: u32) -> Result<(), MemoryError> {
        let index = usize::try_from(class).map_err(|_| MemoryError::Resource)?;
        let required = index.checked_add(1).ok_or(MemoryError::Resource)?;
        if required > self.layouts.len() {
            self.layouts
                .try_reserve_exact(required.saturating_sub(self.layouts.len()))
                .map_err(|_| MemoryError::Resource)?;
            self.layouts.resize(required, None);
        }
        Ok(())
    }

    pub(crate) fn store_layout(&mut self, layout: ObjectLayout) -> Result<(), MemoryError> {
        let index = usize::try_from(layout.class).map_err(|_| MemoryError::Resource)?;
        let slot = self.layouts.get_mut(index).ok_or(MemoryError::Internal)?;
        if slot.as_ref().is_some_and(|existing| existing != &layout) {
            return Err(MemoryError::Internal);
        }
        *slot = Some(layout);
        Ok(())
    }
}
