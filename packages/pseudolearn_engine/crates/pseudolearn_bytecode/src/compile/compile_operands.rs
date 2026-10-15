#![forbid(unsafe_code)]

use pseudolearn_ir::{Operand, ValueId};

use crate::error::BytecodeError;
use crate::model::{BytecodeOperand, Constant, Register};

use super::{InstructionPlan, register_for};

pub(super) fn compile_operand(
    plan: &mut InstructionPlan<'_, '_>,
    operand: &Operand,
) -> Result<BytecodeOperand, BytecodeError> {
    match operand {
        Operand::Value(value) => compile_value_operand(plan, *value),
        Operand::BlockTarget {
            target_block,
            arguments,
        } => Ok(BytecodeOperand::BlockTarget {
            target: *target_block,
            arguments: compile_registers(plan.registers, arguments)?,
        }),
        Operand::FunctionTarget {
            function_name,
            arguments,
        } => compile_function_target(plan, function_name, arguments),
        literal @ (Operand::LiteralI64(_)
        | Operand::LiteralF64(_)
        | Operand::LiteralBool(_)
        | Operand::LiteralChar(_)
        | Operand::LiteralStr(_)) => compile_literal_operand(plan.constants, literal),
        Operand::Type(value_type) => Ok(BytecodeOperand::Type(value_type.clone())),
        Operand::Predicate(predicate) => {
            Ok(BytecodeOperand::Predicate(predicate.as_str().to_owned()))
        }
        Operand::Identifier(value) => Ok(BytecodeOperand::Identifier(value.clone())),
        Operand::Newline => Ok(BytecodeOperand::Newline),
    }
}

fn compile_value_operand(
    plan: &mut InstructionPlan<'_, '_>,
    value: ValueId,
) -> Result<BytecodeOperand, BytecodeError> {
    if plan.allow_immediate
        && let Some(constant) = plan.constants_by_value.get(&value)
    {
        return add_constant(plan.constants, constant.clone());
    }
    Ok(BytecodeOperand::Register(register_for(
        plan.registers,
        value,
    )?))
}

fn compile_literal_operand(
    constants: &mut Vec<Constant>,
    operand: &Operand,
) -> Result<BytecodeOperand, BytecodeError> {
    match operand {
        Operand::LiteralI64(value) => add_constant(constants, Constant::I64(*value)),
        Operand::LiteralF64(value) => add_constant(constants, Constant::F64(*value)),
        Operand::LiteralBool(value) => add_constant(constants, Constant::Bool(*value)),
        Operand::LiteralChar(value) => add_constant(constants, Constant::Char(*value)),
        Operand::LiteralStr(value) => add_constant(constants, Constant::Str(value.clone())),
        _ => Err(BytecodeError::UnsupportedOperation),
    }
}

fn compile_function_target(
    plan: &InstructionPlan<'_, '_>,
    function_name: &str,
    arguments: &[ValueId],
) -> Result<BytecodeOperand, BytecodeError> {
    let normalized = function_name.trim_start_matches('@');
    let function_index = plan
        .function_names
        .get(function_name)
        .or_else(|| plan.function_names.get(normalized))
        .copied()
        .ok_or(BytecodeError::MissingFunction)?;
    Ok(BytecodeOperand::FunctionTarget {
        function_index,
        arguments: compile_registers(plan.registers, arguments)?,
    })
}

fn compile_registers(
    registers: &std::collections::BTreeMap<ValueId, Register>,
    values: &[ValueId],
) -> Result<Vec<Register>, BytecodeError> {
    values
        .iter()
        .map(|value| register_for(registers, *value))
        .collect()
}

fn add_constant(
    constants: &mut Vec<Constant>,
    constant: Constant,
) -> Result<BytecodeOperand, BytecodeError> {
    if let Some(index) = constants
        .iter()
        .position(|candidate| candidate == &constant)
    {
        return u16::try_from(index)
            .map(BytecodeOperand::Constant)
            .map_err(|_| BytecodeError::TooManyConstants);
    }
    let index = u16::try_from(constants.len()).map_err(|_| BytecodeError::TooManyConstants)?;
    constants.push(constant);
    Ok(BytecodeOperand::Constant(index))
}
