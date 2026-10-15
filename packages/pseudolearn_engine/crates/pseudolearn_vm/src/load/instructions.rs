#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeFunction, BytecodeModule, Instruction, Opcode};

use super::definedness::Definedness;
use super::edges::add_edge;
use super::operands::{predicate, scalar_destination, scalar_sources};
use super::{LoadedFunction, Origin, invalid_bytecode};
use crate::VmTrap;
use crate::dispatch::{DispatchKind, Op, dispatch_kind, select_fused, select_operation};

mod control;
mod values;

pub(super) struct DecodeContext<'module> {
    pub module: &'module BytecodeModule,
    pub function: &'module BytecodeFunction,
    pub definedness: &'module Definedness,
}

pub(super) fn decode_all(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
) -> Result<(), VmTrap> {
    let used =
        usize::try_from(context.function.fast.used_length).map_err(|_| invalid_bytecode())?;
    for (position, instruction) in context.function.fast.instructions.iter().enumerate() {
        if position >= used {
            loaded.code.push(Op::Unreachable);
            loaded.origins.push(Origin::default());
            continue;
        }
        let program_counter = u32::try_from(position).map_err(|_| invalid_bytecode())?;
        let (operation, origin) = decode_position(context, loaded, program_counter, instruction)?;
        loaded.code.push(operation);
        loaded.origins.push(origin);
    }
    Ok(())
}

fn decode_position(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<(Op, Origin), VmTrap> {
    let fused_branch = context
        .function
        .fast
        .superinstructions
        .get(&program_counter)
        .copied();
    if let Some(branch_pc) = fused_branch
        && let Some(operation) = decode_fused(context, loaded, instruction, branch_pc)?
    {
        let origin = Origin {
            first: Some(instruction.opcode),
            second: Some(Opcode::Branch),
        };
        return Ok((operation, origin));
    }
    let operation = decode_instruction(context, loaded, program_counter, instruction)?;
    let origin = Origin {
        first: Some(instruction.opcode)
            .filter(|opcode| dispatch_kind(*opcode) != DispatchKind::Observation),
        second: None,
    };
    Ok((operation, origin))
}

fn decode_instruction(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match dispatch_kind(instruction.opcode) {
        DispatchKind::Constant => values::decode_constant(context.function, instruction),
        DispatchKind::ValueState => values::decode_value_state(context, instruction),
        DispatchKind::Scalar => decode_scalar(context.function, instruction),
        DispatchKind::Control => control::decode(context, loaded, program_counter, instruction),
        DispatchKind::Output => values::decode_output(context.function, instruction),
        DispatchKind::Observation => Ok(Op::Observe),
        DispatchKind::Other => Ok(Op::Unsupported),
    }
}

fn decode_scalar(function: &BytecodeFunction, instruction: &Instruction) -> Result<Op, VmTrap> {
    let destination = scalar_destination(instruction)?;
    let sources = scalar_sources(function, instruction)?;
    select_operation(
        instruction.opcode,
        predicate(instruction),
        destination,
        &sources,
    )
    .ok_or_else(invalid_bytecode)
}

fn decode_fused(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    compare: &Instruction,
    branch_pc: u32,
) -> Result<Option<Op>, VmTrap> {
    let branch = usize::try_from(branch_pc)
        .ok()
        .and_then(|position| context.function.fast.instructions.get(position))
        .ok_or_else(invalid_bytecode)?;
    let condition = super::operands::first_register(branch)?;
    if compare.destination != Some(condition) || branch.opcode != Opcode::Branch {
        return Ok(None);
    }
    let destination = scalar_destination(compare)?;
    let sources = scalar_sources(context.function, compare)?;
    let then_edge = add_edge(context, loaded, branch_pc, branch.operands.get(1))?;
    let else_edge = add_edge(context, loaded, branch_pc, branch.operands.get(2))?;
    Ok(select_fused(
        compare.opcode,
        predicate(compare),
        destination,
        &sources,
        (then_edge, else_edge),
    ))
}
