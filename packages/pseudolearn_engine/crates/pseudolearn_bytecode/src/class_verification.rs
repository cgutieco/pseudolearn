use crate::{BytecodeError, BytecodeModule};
use pseudolearn_ir::{IrType, ValueClass};
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn verify(module: &BytecodeModule) -> Result<(), BytecodeError> {
    let classes = module
        .classes
        .iter()
        .map(|class| (class.name.as_str(), class))
        .collect::<BTreeMap<_, _>>();
    if classes.len() != module.classes.len() {
        return Err(BytecodeError::InvalidModule);
    }
    for class in &module.classes {
        verify_class(module, class, &classes)?;
    }
    Ok(())
}

fn verify_class<'class>(
    module: &BytecodeModule,
    class: &'class crate::BytecodeClass,
    classes: &BTreeMap<&str, &'class crate::BytecodeClass>,
) -> Result<(), BytecodeError> {
    verify_superclass_chain(class, classes)?;
    verify_inherited_layout(class, classes)?;
    verify_fields(class, classes)?;
    verify_reference_layout(class)?;
    verify_methods(module, class)?;
    Ok(())
}

fn verify_fields(
    class: &crate::BytecodeClass,
    classes: &BTreeMap<&str, &crate::BytecodeClass>,
) -> Result<(), BytecodeError> {
    if class.name.is_empty()
        || class
            .fields
            .iter()
            .any(|(name, kind)| name.is_empty() || !valid_field_type(kind, classes))
        || class.methods.keys().any(String::is_empty)
        || class.fields.len() > usize::from(u16::MAX)
        || (class
            .name
            .starts_with(pseudolearn_ir::ENVIRONMENT_CLASS_PREFIX)
            && !pseudolearn_ir::environment_fields_are_ordered(
                class.fields.iter().map(|(name, _)| name.as_str()),
            ))
    {
        return Err(BytecodeError::InvalidModule);
    }
    Ok(())
}

fn valid_field_type(value_type: &IrType, classes: &BTreeMap<&str, &crate::BytecodeClass>) -> bool {
    match value_type {
        IrType::I64 | IrType::F64 | IrType::Bool | IrType::Char | IrType::Str => true,
        IrType::Unit | IrType::Cell(_) => false,
        IrType::Object(name) => classes.contains_key(name.as_str()),
        IrType::Array {
            element,
            dimension_rank,
        } => *dimension_rank > 0 && valid_field_type(element, classes),
    }
}

fn verify_superclass_chain(
    class: &crate::BytecodeClass,
    classes: &BTreeMap<&str, &crate::BytecodeClass>,
) -> Result<(), BytecodeError> {
    let mut seen = BTreeSet::new();
    let mut current = class;
    while let Some(superclass) = &current.superclass {
        if !seen.insert(current.name.as_str()) {
            return Err(BytecodeError::InvalidModule);
        }
        current = classes
            .get(superclass.as_str())
            .copied()
            .ok_or(BytecodeError::InvalidModule)?;
    }
    if seen.contains(current.name.as_str()) {
        return Err(BytecodeError::InvalidModule);
    }
    Ok(())
}

fn verify_inherited_layout(
    class: &crate::BytecodeClass,
    classes: &BTreeMap<&str, &crate::BytecodeClass>,
) -> Result<(), BytecodeError> {
    let Some(superclass) = &class.superclass else {
        return Ok(());
    };
    let parent = classes
        .get(superclass.as_str())
        .ok_or(BytecodeError::InvalidModule)?;
    if !class.fields.starts_with(&parent.fields)
        || parent
            .methods
            .keys()
            .any(|name| !class.methods.contains_key(name))
    {
        return Err(BytecodeError::InvalidModule);
    }
    Ok(())
}

fn verify_reference_layout(class: &crate::BytecodeClass) -> Result<(), BytecodeError> {
    let references = class
        .fields
        .iter()
        .enumerate()
        .filter(|(_, (_, kind))| kind.value_class() == ValueClass::Reference)
        .map(|(offset, _)| u32::try_from(offset).map_err(|_| BytecodeError::InvalidModule))
        .collect::<Result<Vec<_>, _>>()?;
    if references != class.references {
        return Err(BytecodeError::InvalidModule);
    }
    let mut fields = BTreeSet::new();
    if class.fields.iter().any(|(name, _)| !fields.insert(name)) {
        return Err(BytecodeError::InvalidModule);
    }
    Ok(())
}

fn verify_methods(
    module: &BytecodeModule,
    class: &crate::BytecodeClass,
) -> Result<(), BytecodeError> {
    for target in class.methods.values() {
        let function = module
            .functions
            .get(usize::from(*target))
            .ok_or(BytecodeError::InvalidModule)?;
        let receiver = function
            .parameters
            .first()
            .and_then(|register| function.register_type(*register));
        let Some(IrType::Object(receiver)) = receiver else {
            return Err(BytecodeError::InvalidModule);
        };
        if !is_subtype(module, &class.name, receiver) {
            return Err(BytecodeError::InvalidModule);
        }
    }
    Ok(())
}

pub(crate) fn assignable(module: &BytecodeModule, actual: &IrType, expected: &IrType) -> bool {
    if actual == expected {
        return true;
    }
    let (IrType::Object(actual), IrType::Object(expected)) = (actual, expected) else {
        return false;
    };
    is_subtype(module, actual, expected)
}

fn is_subtype(module: &BytecodeModule, actual: &str, expected: &str) -> bool {
    let mut current = Some(actual);
    for _ in 0..module.classes.len() {
        let Some(name) = current else {
            return false;
        };
        if name == expected {
            return true;
        }
        current = module
            .classes
            .iter()
            .find(|class| class.name == name)
            .and_then(|class| class.superclass.as_deref());
    }
    false
}
