use crate::engine::AotEngine;
use crate::kinds::kind_from_code;
use pseudolearn_runtime::{MemoryError, ObjectLayout, ValueKind};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ClassDescriptor {
    pub fields: Vec<u32>,
    pub dense: bool,
}

impl AotEngine {
    pub fn register_class(
        &mut self,
        class: u32,
        descriptor: &ClassDescriptor,
    ) -> Result<(), MemoryError> {
        let fields = descriptor
            .fields
            .iter()
            .map(|code| kind_from_code(*code).map_err(|_| MemoryError::Internal))
            .collect::<Result<Vec<_>, _>>()?;
        let references = fields
            .iter()
            .enumerate()
            .filter(|(_, kind)| **kind == ValueKind::Reference)
            .map(|(index, _)| index)
            .collect();
        self.register_layout(ObjectLayout {
            class,
            fields,
            dense: descriptor.dense,
            references,
        })
    }
}
