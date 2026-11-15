#![forbid(unsafe_code)]

use super::*;

pub(super) fn verify_array_new(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Type(element_type)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    let Some(ValueType::Array {
        element,
        dimension_rank,
    }) = destination_type(function, instruction)
    else {
        return Err(TYPE_ERROR);
    };
    let expected_element = match element_type {
        ValueType::Array { element, .. } => element.as_ref(),
        other => other,
    };
    let indices = instruction.operands.get(1..).ok_or(TYPE_ERROR)?;
    if indices.is_empty()
        || element.as_ref() != expected_element
        || usize::try_from(*dimension_rank).ok() != Some(indices.len())
        || indices
            .iter()
            .any(|operand| operand_type(function, operand) != Some(ValueType::I64))
    {
        return Err(TYPE_ERROR);
    }
    Ok(())
}

pub(super) fn verify_array_access(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
    stores: bool,
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
    let trailing_value = if stores { 1 } else { 0 };
    let end = instruction
        .operands
        .len()
        .checked_sub(trailing_value)
        .ok_or(TYPE_ERROR)?;
    let indices = instruction.operands.get(1..end).ok_or(TYPE_ERROR)?;
    if usize::try_from(*dimension_rank).ok() != Some(indices.len())
        || indices
            .iter()
            .any(|operand| operand_type(function, operand) != Some(ValueType::I64))
    {
        return Err(TYPE_ERROR);
    }
    if stores {
        let source = instruction.operands.get(end).ok_or(TYPE_ERROR)?;
        let source_type = operand_type(function, source).ok_or(TYPE_ERROR)?;
        return require_assignable(module, Some(&source_type), element);
    }
    require_destination(instruction, function, element)
}
