#![forbid(unsafe_code)]

pub const RECORD_MAXIMUM_LEAVES: usize = 65_535;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RecordBank {
    Scalar,
    Reference,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RecordLeaf {
    pub bank: RecordBank,
    pub offset: u32,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RecordLayoutError {
    TooManyLeaves,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RecordLayout {
    leaves: Vec<RecordLeaf>,
    scalar_words: u32,
    reference_words: u32,
}

impl RecordLayout {
    pub fn from_banks(banks: &[RecordBank]) -> Result<Self, RecordLayoutError> {
        if banks.len() > RECORD_MAXIMUM_LEAVES {
            return Err(RecordLayoutError::TooManyLeaves);
        }
        let mut layout = Self::default();
        for bank in banks {
            let offset = match bank {
                RecordBank::Scalar => &mut layout.scalar_words,
                RecordBank::Reference => &mut layout.reference_words,
            };
            layout.leaves.push(RecordLeaf {
                bank: *bank,
                offset: *offset,
            });
            *offset = offset.saturating_add(1);
        }
        Ok(layout)
    }

    pub fn from_parts(parts: &[RecordLayout]) -> Result<Self, RecordLayoutError> {
        let banks: Vec<RecordBank> = parts
            .iter()
            .flat_map(|part| part.leaves.iter().map(|leaf| leaf.bank))
            .collect();
        Self::from_banks(&banks)
    }

    pub fn leaf(&self, position: usize) -> Option<RecordLeaf> {
        self.leaves.get(position).copied()
    }

    pub fn leaf_count(&self) -> usize {
        self.leaves.len()
    }

    pub fn scalar_words(&self) -> u32 {
        self.scalar_words
    }

    pub fn reference_words(&self) -> u32 {
        self.reference_words
    }
}
