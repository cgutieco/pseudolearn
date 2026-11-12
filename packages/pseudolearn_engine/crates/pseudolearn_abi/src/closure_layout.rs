use crate::{RecordBank, RecordLayout, RecordLayoutError};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ClosureLayout {
    value: RecordLayout,
    environment: RecordLayout,
}

impl ClosureLayout {
    pub fn from_captures(captures: &[RecordLayout]) -> Result<Self, RecordLayoutError> {
        Ok(Self {
            value: RecordLayout::from_banks(&[RecordBank::Scalar, RecordBank::Reference])?,
            environment: RecordLayout::from_parts(captures)?,
        })
    }

    pub fn value(&self) -> &RecordLayout {
        &self.value
    }

    pub fn environment(&self) -> &RecordLayout {
        &self.environment
    }

    pub fn field(&self, leaf: usize) -> Option<u32> {
        let leaf = self.environment.leaf(leaf)?;
        match leaf.bank {
            RecordBank::Scalar => Some(leaf.offset),
            RecordBank::Reference => self.environment.scalar_words().checked_add(leaf.offset),
        }
    }
}
