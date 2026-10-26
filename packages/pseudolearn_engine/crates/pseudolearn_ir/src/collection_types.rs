use crate::{ClassDeclaration, IrType, Operation, ValueClass};
pub use pseudolearn_abi::CollectionCommand;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CollectionType {
    pub key: Option<IrType>,
    pub key_is_enum: bool,
    pub leaves: Vec<IrType>,
}

pub fn collection_type(class: &ClassDeclaration) -> Option<CollectionType> {
    from_fields(
        &class.name,
        class
            .fields
            .iter()
            .map(|field| (field.name.as_str(), &field.field_type)),
    )
}

pub fn from_fields<'fields>(
    name: &str,
    fields: impl IntoIterator<Item = (&'fields str, &'fields IrType)>,
) -> Option<CollectionType> {
    let dictionary = if name.starts_with("$dictionary<") {
        true
    } else if name.starts_with("$vector<") {
        false
    } else {
        return None;
    };
    let mut key = None;
    let mut key_is_enum = false;
    let mut leaves = Vec::new();
    for (name, kind) in fields {
        if matches!(name, "$key" | "$keyEnum") && key.is_none() {
            key = Some(kind.clone());
            key_is_enum = name == "$keyEnum";
        } else if name.starts_with("$leaf") && kind.value_class() != ValueClass::Unit {
            leaves.push(kind.clone());
        } else {
            return None;
        }
    }
    validate(dictionary, &key, &leaves)?;
    Some(CollectionType {
        key,
        key_is_enum,
        leaves,
    })
}

pub fn collection_command(operation: Operation) -> Option<CollectionCommand> {
    match operation {
        Operation::CollectionNew => Some(CollectionCommand::New),
        Operation::CollectionLength => Some(CollectionCommand::Length),
        Operation::CollectionVersion => Some(CollectionCommand::Version),
        Operation::CollectionCheck => Some(CollectionCommand::Check),
        Operation::CollectionLookup => Some(CollectionCommand::Lookup),
        Operation::CollectionLoad => Some(CollectionCommand::Load),
        Operation::CollectionStore => Some(CollectionCommand::Store),
        Operation::CollectionInsert => Some(CollectionCommand::Insert),
        Operation::CollectionRemove => Some(CollectionCommand::Remove),
        Operation::CollectionNext => Some(CollectionCommand::Next),
        Operation::CollectionKey => Some(CollectionCommand::Key),
        Operation::ArrayLength => Some(CollectionCommand::ArrayLength),
        _ => None,
    }
}

fn validate(dictionary: bool, key: &Option<IrType>, leaves: &[IrType]) -> Option<()> {
    if dictionary != key.is_some() || leaves.len() > usize::from(u16::MAX) {
        return None;
    }
    if key
        .as_ref()
        .is_some_and(|key| !matches!(key, IrType::I64 | IrType::Char | IrType::Bool | IrType::Str))
    {
        return None;
    }
    let first_reference = leaves
        .iter()
        .position(|kind| kind.value_class() == ValueClass::Reference)
        .unwrap_or(leaves.len());
    if leaves
        .iter()
        .skip(first_reference)
        .any(|kind| kind.value_class() != ValueClass::Reference)
    {
        return None;
    }
    Some(())
}
