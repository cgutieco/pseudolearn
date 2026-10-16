use crate::{BytecodeError, BytecodeModule};
use pseudolearn_ir::{IrType, ValueClass};
use std::collections::BTreeSet;

pub(crate) fn verify(module: &BytecodeModule) -> Result<(), BytecodeError> {
    let mut names = BTreeSet::new();
    for class in &module.classes {
        if !names.insert(&class.name) {
            return Err(BytecodeError::InvalidModule);
        }
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
        for target in class.methods.values() {
            let function = module
                .functions
                .get(usize::from(*target))
                .ok_or(BytecodeError::InvalidModule)?;
            let receiver = function
                .parameters
                .first()
                .and_then(|register| function.register_type(*register));
            if !matches!(receiver, Some(IrType::Object(_))) {
                return Err(BytecodeError::InvalidModule);
            }
        }
    }
    Ok(())
}
