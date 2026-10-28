#![forbid(unsafe_code)]

#[path = "verify_array_types.rs"]
mod arrays;
#[path = "verify_reference_types.rs"]
mod references;

use crate::error::{BytecodeError, VerificationRule};
use crate::model::{BytecodeFunction, BytecodeModule, BytecodeOperand, Constant, Instruction};
use crate::{Opcode, ValueType};

const TYPE_ERROR: BytecodeError = BytecodeError::Verification(VerificationRule::ValueClass);

pub(crate) fn verify(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    if crate::verify_task_types::verify(function, instruction)? {
        return Ok(());
    }
    if crate::verify_collection_types::verify(module, function, instruction)? {
        return Ok(());
    }
    match instruction.opcode {
        Opcode::SnapshotCopy => crate::verify_snapshot_types::verify(function, instruction),
        Opcode::ArrayNew => arrays::verify_array_new(function, instruction),
        Opcode::ArrayLoad => arrays::verify_array_access(module, function, instruction, false),
        Opcode::ArrayStore => arrays::verify_array_access(module, function, instruction, true),
        Opcode::CellElement => references::verify_cell_element(function, instruction),
        Opcode::CellField => references::verify_cell_field(module, function, instruction),
        Opcode::ObjectLoad => references::verify_object_load(module, function, instruction),
        Opcode::ObjectStore => references::verify_object_store(module, function, instruction),
        Opcode::CellLocal => references::verify_cell_local(function, instruction),
        Opcode::CellLoad | Opcode::CellLoadRaw => {
            references::verify_cell_load(function, instruction)
        }
        Opcode::CellStore => references::verify_cell_store(module, function, instruction),
        Opcode::ObjectNew => references::verify_object_new(module, function, instruction),
        Opcode::ObjectCopy => references::verify_object_copy(function, instruction),
        Opcode::RefCmp => references::verify_reference_compare(function, instruction),
        Opcode::HostRandom => references::verify_host_random(function, instruction),
        Opcode::InRead => verify_in_read(function, instruction),
        Opcode::ValueReinterpret => verify_reinterpret(function, instruction),
        Opcode::Switch => crate::verify_switch::check(function, instruction),
        _ => Ok(()),
    }
}

fn verify_in_read(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let target = destination_type(function, instruction).ok_or(TYPE_ERROR)?;
    let Some(BytecodeOperand::Type(expected)) = instruction.operands.first() else {
        return Err(TYPE_ERROR);
    };
    if target == expected {
        Ok(())
    } else {
        Err(TYPE_ERROR)
    }
}

fn destination_type<'function>(
    function: &'function BytecodeFunction,
    instruction: &Instruction,
) -> Option<&'function ValueType> {
    function.register_type(instruction.destination?)
}

fn operand_type(function: &BytecodeFunction, operand: &BytecodeOperand) -> Option<ValueType> {
    match operand {
        BytecodeOperand::Register(register) => function.register_type(*register).cloned(),
        BytecodeOperand::Constant(index) => {
            constant_type(function.constants.get(usize::from(*index)))
        }
        _ => None,
    }
}

fn constant_type(constant: Option<&Constant>) -> Option<ValueType> {
    match constant? {
        Constant::I64(_) => Some(ValueType::I64),
        Constant::F64(_) => Some(ValueType::F64),
        Constant::Bool(_) => Some(ValueType::Bool),
        Constant::Char(_) => Some(ValueType::Char),
        Constant::Str(_) => Some(ValueType::Str),
    }
}

fn require_destination(
    instruction: &Instruction,
    function: &BytecodeFunction,
    expected: &ValueType,
) -> Result<(), BytecodeError> {
    if destination_type(function, instruction) == Some(expected) {
        Ok(())
    } else {
        Err(TYPE_ERROR)
    }
}

fn require_assignable(
    module: &BytecodeModule,
    actual: Option<&ValueType>,
    expected: &ValueType,
) -> Result<(), BytecodeError> {
    if actual.is_some_and(|actual| crate::class_verification::assignable(module, actual, expected))
    {
        Ok(())
    } else {
        Err(TYPE_ERROR)
    }
}

fn is_reference_type(value_type: Option<&ValueType>) -> bool {
    value_type
        .is_some_and(|value_type| value_type.value_class() == pseudolearn_ir::ValueClass::Reference)
}

fn verify_reinterpret(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let [BytecodeOperand::Type(target), source] = instruction.operands.as_slice() else {
        return Err(TYPE_ERROR);
    };
    let source = operand_type(function, source).ok_or(TYPE_ERROR)?;
    let carrier = source == ValueType::I64
        || *target == ValueType::I64
        || source == ValueType::Str
        || *target == ValueType::Str;
    if destination_type(function, instruction) == Some(target)
        && source.value_class() == target.value_class()
        && *target != ValueType::Unit
        && carrier
        && !matches!(source, ValueType::Cell(_))
        && !matches!(target, ValueType::Cell(_))
    {
        Ok(())
    } else {
        Err(TYPE_ERROR)
    }
}
