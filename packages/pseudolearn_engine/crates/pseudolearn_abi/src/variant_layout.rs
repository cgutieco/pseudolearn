#![forbid(unsafe_code)]

use crate::{RECORD_MAXIMUM_LEAVES, RecordBank, RecordLayout};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum VariantLayoutError {
    EmptyVariants,
    TooManyWords,
    InvalidVariant,
    ReferenceBufferTooSmall,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct VariantLayout {
    alternatives: Vec<RecordLayout>,
    scalar_words: u32,
    reference_words: u32,
    reference_niche: bool,
}

impl VariantLayout {
    pub fn tagged(alternatives: &[RecordLayout]) -> Result<Self, VariantLayoutError> {
        if alternatives.is_empty() {
            return Err(VariantLayoutError::EmptyVariants);
        }
        if alternatives.len() > RECORD_MAXIMUM_LEAVES {
            return Err(VariantLayoutError::TooManyWords);
        }
        let payload_words = alternatives
            .iter()
            .map(RecordLayout::scalar_words)
            .max()
            .unwrap_or(0);
        let scalar_words = payload_words
            .checked_add(1)
            .ok_or(VariantLayoutError::TooManyWords)?;
        let reference_words = alternatives
            .iter()
            .map(RecordLayout::reference_words)
            .max()
            .unwrap_or(0);
        let total = scalar_words
            .checked_add(reference_words)
            .ok_or(VariantLayoutError::TooManyWords)?;
        if usize::try_from(total).unwrap_or(usize::MAX) > RECORD_MAXIMUM_LEAVES {
            return Err(VariantLayoutError::TooManyWords);
        }
        Ok(Self {
            alternatives: alternatives.to_vec(),
            scalar_words,
            reference_words,
            reference_niche: false,
        })
    }

    pub fn optional(payload: RecordLayout) -> Result<Self, VariantLayoutError> {
        let reference_niche = payload.leaf_count() == 1
            && payload
                .leaf(0)
                .is_some_and(|leaf| leaf.bank == RecordBank::Reference);
        let mut layout = Self::tagged(&[RecordLayout::default(), payload])?;
        if reference_niche {
            layout.scalar_words = 0;
            layout.reference_niche = true;
        }
        Ok(layout)
    }

    pub fn scalar_words(&self) -> u32 {
        self.scalar_words
    }

    pub fn reference_words(&self) -> u32 {
        self.reference_words
    }

    pub fn uses_reference_niche(&self) -> bool {
        self.reference_niche
    }

    pub fn payload(&self, variant: usize) -> Option<&RecordLayout> {
        self.alternatives.get(variant)
    }

    pub fn clear_inactive_references(
        &self,
        variant: usize,
        references: &mut [u32],
    ) -> Result<(), VariantLayoutError> {
        let payload = self
            .payload(variant)
            .ok_or(VariantLayoutError::InvalidVariant)?;
        let count =
            usize::try_from(self.reference_words).map_err(|_| VariantLayoutError::TooManyWords)?;
        let active = usize::try_from(payload.reference_words())
            .map_err(|_| VariantLayoutError::TooManyWords)?;
        let slots = references
            .get_mut(..count)
            .ok_or(VariantLayoutError::ReferenceBufferTooSmall)?;
        for reference in slots.iter_mut().skip(active) {
            *reference = crate::reference_absent_handle().0;
        }
        Ok(())
    }
}
