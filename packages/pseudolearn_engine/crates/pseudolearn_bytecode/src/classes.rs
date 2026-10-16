use crate::{BytecodeClass, BytecodeError};
use pseudolearn_ir::Module;
use std::collections::BTreeMap;

pub(crate) fn compile(
    module: &Module,
    functions: &BTreeMap<String, u16>,
) -> Result<Vec<BytecodeClass>, BytecodeError> {
    let mut completed = BTreeMap::new();
    while completed.len() < module.classes.len() {
        let before = completed.len();
        for class in &module.classes {
            if completed.contains_key(&class.name) {
                continue;
            }
            let Some(descriptor) = descriptor(class, &completed, functions)? else {
                continue;
            };
            completed.insert(class.name.clone(), descriptor);
        }
        if completed.len() == before {
            return Err(BytecodeError::InvalidModule);
        }
    }
    module
        .classes
        .iter()
        .map(|class| {
            completed
                .remove(&class.name)
                .ok_or(BytecodeError::InvalidModule)
        })
        .collect()
}

fn descriptor(
    class: &pseudolearn_ir::ClassDeclaration,
    completed: &BTreeMap<String, BytecodeClass>,
    functions: &BTreeMap<String, u16>,
) -> Result<Option<BytecodeClass>, BytecodeError> {
    let mut descriptor = if let Some(parent) = &class.superclass {
        let Some(parent) = completed.get(parent) else {
            return Ok(None);
        };
        BytecodeClass::clone(parent)
    } else {
        BytecodeClass {
            name: class.name.clone(),
            fields: Vec::new(),
            methods: BTreeMap::new(),
            dense_integers: false,
            references: Vec::new(),
        }
    };
    descriptor.name = class.name.clone();
    descriptor.dense_integers = class.dense_integers;
    descriptor.fields.extend(
        class
            .fields
            .iter()
            .map(|field| (field.name.clone(), field.field_type.clone())),
    );
    for (name, target) in &class.methods {
        descriptor.methods.insert(
            name.clone(),
            *functions
                .get(target)
                .ok_or(BytecodeError::MissingFunction)?,
        );
    }
    descriptor.references = references(&descriptor)?;
    Ok(Some(descriptor))
}

fn references(class: &BytecodeClass) -> Result<Vec<u32>, BytecodeError> {
    class
        .fields
        .iter()
        .enumerate()
        .filter(|(_, (_, kind))| kind.value_class() == pseudolearn_ir::ValueClass::Reference)
        .map(|(offset, _)| u32::try_from(offset).map_err(|_| BytecodeError::InvalidModule))
        .collect()
}
