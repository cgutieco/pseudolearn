pub use pseudolearn_ir::collection_types::{
    CollectionCommand, CollectionType, from_fields as collection_fields,
};

pub fn collection_command(opcode: crate::Opcode) -> Option<CollectionCommand> {
    pseudolearn_ir::Operation::from_name(opcode.as_name())
        .and_then(pseudolearn_ir::collection_types::collection_command)
}

pub(crate) fn descriptor(class: &crate::BytecodeClass) -> Option<CollectionType> {
    collection_fields(
        &class.name,
        class
            .fields
            .iter()
            .map(|(name, kind)| (name.as_str(), kind)),
    )
}
