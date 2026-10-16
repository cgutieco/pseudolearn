#![forbid(unsafe_code)]

use super::*;

pub(super) fn verify_cell_element(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Register(array)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Array {
        element,
        dimension_rank,
    }) = function.register_type(*array)
    else {
        return Err(TYPE_ERROR);
    };
    let indices = instruction.operands.get(1..).ok_or(TYPE_ERROR)?;
    if usize::try_from(*dimension_rank).ok() != Some(indices.len())
        || indices
            .iter()
            .any(|operand| operand_type(function, operand) != Some(ValueType::I64))
    {
        return Err(TYPE_ERROR);
    }
    require_destination(instruction, function, &ValueType::Cell(element.clone()))
}

pub(super) fn verify_cell_field(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Register(receiver)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Object(class_name)) = function.register_type(*receiver) else {
        return Err(TYPE_ERROR);
    };
    let Some(BytecodeOperand::Identifier(field_name)) = instruction.operands.get(1) else {
        return Err(TYPE_ERROR);
    };
    let field_type = object_field_type(module, class_name, field_name)?;
    require_destination(
        instruction,
        function,
        &ValueType::Cell(Box::new(field_type.clone())),
    )
}

pub(super) fn verify_object_load(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    if instruction.operands.len() != 2 {
        return Err(TYPE_ERROR);
    }
    let (class_name, field_name) = object_field_operands(function, instruction)?;
    let field_type = object_field_type(module, class_name, field_name)?;
    require_destination(instruction, function, field_type)
}

pub(super) fn verify_object_store(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    if instruction.operands.len() != 3 {
        return Err(TYPE_ERROR);
    }
    let (class_name, field_name) = object_field_operands(function, instruction)?;
    let field_type = object_field_type(module, class_name, field_name)?;
    let source = instruction.operands.get(2).ok_or(TYPE_ERROR)?;
    require_assignable(module, operand_type(function, source).as_ref(), field_type)
}

fn object_field_operands<'function>(
    function: &'function BytecodeFunction,
    instruction: &'function Instruction,
) -> Result<(&'function String, &'function String), BytecodeError> {
    let Some(BytecodeOperand::Register(receiver)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Object(class_name)) = function.register_type(*receiver) else {
        return Err(TYPE_ERROR);
    };
    let Some(BytecodeOperand::Identifier(field_name)) = instruction.operands.get(1) else {
        return Err(TYPE_ERROR);
    };
    Ok((class_name, field_name))
}

fn object_field_type<'module>(
    module: &'module BytecodeModule,
    class_name: &str,
    field_name: &str,
) -> Result<&'module ValueType, BytecodeError> {
    module
        .classes
        .iter()
        .find(|class| class.name == class_name)
        .and_then(|class| {
            class
                .fields
                .iter()
                .find(|(name, _)| name == field_name)
                .map(|(_, field_type)| field_type)
        })
        .ok_or(TYPE_ERROR)
}

pub(super) fn verify_cell_local(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Type(value_type)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    require_destination(
        instruction,
        function,
        &ValueType::Cell(Box::new(value_type.clone())),
    )
}

pub(super) fn verify_cell_load(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Register(cell)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Cell(value_type)) = function.register_type(*cell) else {
        return Err(TYPE_ERROR);
    };
    require_destination(instruction, function, value_type)
}

pub(super) fn verify_cell_store(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Register(cell)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Cell(value_type)) = function.register_type(*cell) else {
        return Err(TYPE_ERROR);
    };
    let source = instruction.operands.get(1).ok_or(TYPE_ERROR)?;
    require_assignable(module, operand_type(function, source).as_ref(), value_type)
}

pub(super) fn verify_object_new(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Identifier(class_name)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    if !module.classes.iter().any(|class| class.name == *class_name) {
        return Err(TYPE_ERROR);
    }
    require_destination(
        instruction,
        function,
        &ValueType::Object(class_name.clone()),
    )
}

pub(super) fn verify_object_copy(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Register(source)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Object(_)) = function.register_type(*source) else {
        return Err(TYPE_ERROR);
    };
    if function.register_type(*source) != destination_type(function, instruction) {
        return Err(TYPE_ERROR);
    }
    Ok(())
}

pub(super) fn verify_reference_compare(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Predicate(predicate)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let operands = instruction.operands.get(1..).ok_or(TYPE_ERROR)?;
    if !matches!(predicate.as_str(), "eq" | "ne")
        || operands.len() != 2
        || operands
            .iter()
            .any(|operand| !is_reference_type(operand_type(function, operand).as_ref()))
    {
        return Err(TYPE_ERROR);
    }
    require_destination(instruction, function, &ValueType::Bool)
}

pub(super) fn verify_host_random(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    if !instruction.operands.is_empty() {
        return Err(TYPE_ERROR);
    }
    require_destination(instruction, function, &ValueType::F64)
}
