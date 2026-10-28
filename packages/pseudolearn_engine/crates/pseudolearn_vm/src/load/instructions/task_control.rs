#![forbid(unsafe_code)]

use pseudolearn_bytecode::{Instruction, Opcode, RegisterClass};

use super::super::operands::first_register;
use super::DecodeContext;
use super::{LoadedFunction, invalid_bytecode};
use crate::VmTrap;
use crate::dispatch::Op;

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match instruction.opcode {
        Opcode::TaskScopeOpen => decode_scope_open(instruction),
        Opcode::TaskSpawn => decode_task_spawn(context, loaded, instruction),
        Opcode::TaskAwait => decode_task_await(instruction),
        Opcode::TaskScopeJoin => decode_scope_join(instruction),
        Opcode::TaskYieldCheck => decode_yield_check(instruction),
        _ => Err(invalid_bytecode()),
    }
}

fn decode_scope_open(instruction: &Instruction) -> Result<Op, VmTrap> {
    let Some(destination) = instruction.destination else {
        return Err(invalid_bytecode());
    };
    if destination.class != RegisterClass::Scalar || !instruction.operands.is_empty() {
        return Err(invalid_bytecode());
    }
    Ok(Op::TaskScopeOpen {
        destination: destination.index,
    })
}

fn decode_task_spawn(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let scope = first_register(instruction)?;
    if scope.class != RegisterClass::Scalar {
        return Err(invalid_bytecode());
    }
    let Op::Call { site } = super::control::decode_call(context, loaded, instruction)? else {
        return Err(invalid_bytecode());
    };
    Ok(Op::TaskSpawn {
        scope: scope.index,
        site,
    })
}

fn decode_task_await(instruction: &Instruction) -> Result<Op, VmTrap> {
    let task = first_register(instruction)?;
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    if task.class != RegisterClass::Scalar || instruction.operands.len() != 2 {
        return Err(invalid_bytecode());
    }
    Ok(Op::TaskAwait {
        task: task.index,
        destination,
    })
}

fn decode_scope_join(instruction: &Instruction) -> Result<Op, VmTrap> {
    let scope = first_register(instruction)?;
    if scope.class != RegisterClass::Scalar || instruction.operands.len() != 1 {
        return Err(invalid_bytecode());
    }
    Ok(Op::TaskScopeJoin { scope: scope.index })
}

fn decode_yield_check(instruction: &Instruction) -> Result<Op, VmTrap> {
    if instruction.operands.is_empty() && instruction.destination.is_none() {
        Ok(Op::TaskYieldCheck)
    } else {
        Err(invalid_bytecode())
    }
}
