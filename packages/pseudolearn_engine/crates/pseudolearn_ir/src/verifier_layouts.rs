#![forbid(unsafe_code)]

use crate::model::{ClassDeclaration, Module};
use crate::types::IrType;
use std::collections::HashSet;

const CAPTURE_PREFIX: &str = "capture";
const OPERAND_LIMIT: usize = 65_535;

pub const ENVIRONMENT_CLASS_PREFIX: &str = "$environment";

pub fn environment_fields_are_ordered<'name>(names: impl IntoIterator<Item = &'name str>) -> bool {
    let mut previous: Option<usize> = None;
    for name in names {
        let Some(offset) = name
            .strip_prefix(CAPTURE_PREFIX)
            .and_then(|suffix| suffix.parse::<usize>().ok())
        else {
            return false;
        };
        if previous.is_some_and(|previous| previous >= offset) {
            return false;
        }
        previous = Some(offset);
    }
    true
}

pub(crate) fn check_class_layouts(module: &Module) -> Result<(), &'static str> {
    for class in &module.classes {
        check_class_layout(class)?;
    }
    Ok(())
}

fn check_class_layout(class: &ClassDeclaration) -> Result<(), &'static str> {
    let mut names = HashSet::new();
    for field in &class.fields {
        if !names.insert(field.name.as_str()) || !is_storable(&field.field_type) {
            return Err("IR.WELL-FORMEDNESS#R10");
        }
    }
    if class.name.starts_with(ENVIRONMENT_CLASS_PREFIX)
        && !environment_fields_are_ordered(class.fields.iter().map(|field| field.name.as_str()))
    {
        return Err("IR.WELL-FORMEDNESS#R10");
    }
    Ok(())
}

fn is_storable(field_type: &IrType) -> bool {
    !matches!(field_type, IrType::Unit | IrType::Cell(_))
}

pub(crate) fn check_operand_limits(module: &Module) -> Result<(), &'static str> {
    if module.classes.len() > OPERAND_LIMIT || module.functions.len() > OPERAND_LIMIT {
        return Err("IR.WELL-FORMEDNESS#R11");
    }
    if module
        .classes
        .iter()
        .any(|class| class.fields.len() > OPERAND_LIMIT)
    {
        return Err("IR.WELL-FORMEDNESS#R11");
    }
    for function in &module.functions {
        if function.parameters.len() > OPERAND_LIMIT
            || function
                .blocks
                .iter()
                .any(|block| block.parameters.len() > OPERAND_LIMIT)
        {
            return Err("IR.WELL-FORMEDNESS#R11");
        }
    }
    Ok(())
}
