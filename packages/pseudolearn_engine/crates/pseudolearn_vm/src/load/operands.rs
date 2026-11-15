#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeOperand, Constant, Instruction, Register, RegisterClass, ValueType,
};

use super::{Sentinel, Source, invalid_bytecode};
use crate::VmTrap;

pub(super) fn constant_word(function: &BytecodeFunction, index: u16) -> Option<u64> {
    match function.constants.get(usize::from(index))? {
        Constant::I64(value) => Some(u64::from_ne_bytes(value.to_ne_bytes())),
        Constant::F64(value) => Some(value.to_bits()),
        Constant::Bool(value) => Some(u64::from(*value)),
        Constant::Char(value) => Some(u64::from(u32::from(*value))),
        Constant::Str(_) => None,
    }
}

pub(super) fn scalar_source(
    function: &BytecodeFunction,
    operand: &BytecodeOperand,
) -> Option<Source> {
    match operand {
        BytecodeOperand::Register(register) if register.class == RegisterClass::Scalar => {
            Some(Source::Register(register.index))
        }
        BytecodeOperand::Constant(index) => constant_word(function, *index).map(Source::Immediate),
        _ => None,
    }
}

pub(super) fn scalar_destination(instruction: &Instruction) -> Result<u16, VmTrap> {
    match instruction.destination {
        Some(register) if register.class == RegisterClass::Scalar => Ok(register.index),
        _ => Err(invalid_bytecode()),
    }
}

pub(super) fn first_register(instruction: &Instruction) -> Result<Register, VmTrap> {
    match instruction.operands.first() {
        Some(BytecodeOperand::Register(register)) => Ok(*register),
        _ => Err(invalid_bytecode()),
    }
}

pub(super) fn predicate(instruction: &Instruction) -> Option<&str> {
    match instruction.operands.first() {
        Some(BytecodeOperand::Predicate(value)) => Some(value.as_str()),
        _ => None,
    }
}

pub(super) fn scalar_sources(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<Vec<Source>, VmTrap> {
    let skip = usize::from(predicate(instruction).is_some());
    instruction
        .operands
        .iter()
        .skip(skip)
        .map(|operand| scalar_source(function, operand).ok_or_else(invalid_bytecode))
        .collect()
}

pub(super) fn sentinel_of(value_type: Option<&ValueType>) -> Sentinel {
    match value_type {
        Some(ValueType::F64) => Sentinel::Real,
        Some(ValueType::Bool) => Sentinel::Boolean,
        Some(ValueType::Char) => Sentinel::Character,
        _ => Sentinel::Unit,
    }
}

pub(super) fn sentinel_word(sentinel: Sentinel) -> u64 {
    match sentinel {
        Sentinel::Real => f64::NAN.to_bits(),
        Sentinel::Boolean => 2,
        Sentinel::Character => u64::from(u32::MAX),
        Sentinel::Unit => 0,
    }
}
