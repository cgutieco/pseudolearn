#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeModule, BytecodeOperand, Instruction, Opcode, ValueType,
};

use super::definedness::Definedness;
use super::edges::add_edge;
use super::model::{ObservationKind, ObservationSite};
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
    pub literals: &'module [String],
}

pub(super) fn decode_all(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
) -> Result<(), VmTrap> {
    decode_fast(context, loaded)?;
    decode_probed(context, loaded)?;
    Ok(())
}

fn decode_fast(context: &DecodeContext<'_>, loaded: &mut LoadedFunction) -> Result<(), VmTrap> {
    let used =
        usize::try_from(context.function.fast.used_length).map_err(|_| invalid_bytecode())?;
    for (position, instruction) in context.function.fast.instructions.iter().enumerate() {
        if position >= used {
            loaded.code.push(Op::Unreachable);
            loaded.origins.push(Origin::default());
            continue;
        }
        let program_counter = u32::try_from(position).map_err(|_| invalid_bytecode())?;
        let (operation, origin) =
            decode_fast_position(context, loaded, program_counter, instruction)?;
        loaded.code.push(operation);
        loaded.origins.push(origin);
    }
    Ok(())
}

fn decode_probed(context: &DecodeContext<'_>, loaded: &mut LoadedFunction) -> Result<(), VmTrap> {
    let used =
        usize::try_from(context.function.probed.used_length).map_err(|_| invalid_bytecode())?;
    for (position, instruction) in context.function.probed.instructions.iter().enumerate() {
        if position >= used {
            loaded.probed_code.push(Op::Unreachable);
            loaded.probed_origins.push(Origin::default());
            continue;
        }
        let program_counter = u32::try_from(position).map_err(|_| invalid_bytecode())?;
        let operation = decode_instruction(context, loaded, (program_counter, true), instruction)?;
        let origin = Origin {
            first: Some(instruction.opcode)
                .filter(|opcode| dispatch_kind(*opcode) != DispatchKind::Observation),
            second: None,
        };
        loaded.probed_code.push(operation);
        loaded.probed_origins.push(origin);
    }
    Ok(())
}

fn decode_fast_position(
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
    let operation = decode_instruction(context, loaded, (program_counter, false), instruction)?;
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
    (program_counter, probed): (u32, bool),
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match dispatch_kind(instruction.opcode) {
        DispatchKind::Constant => values::decode_constant(context, instruction),
        DispatchKind::ValueState => values::decode_value_state(context, instruction),
        DispatchKind::Scalar => decode_scalar(context.function, instruction),
        DispatchKind::Control => {
            control::decode(context, loaded, (program_counter, probed), instruction)
        }
        DispatchKind::Output => decode_output(context, loaded, instruction),
        DispatchKind::Input => decode_input(context.function, instruction),
        DispatchKind::Memory => super::memory::decode(context, loaded, instruction),
        DispatchKind::Observation => decode_observation(context, loaded, instruction),
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

fn decode_output(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match values::decode_output(context.function, instruction)? {
        Op::Unsupported => super::memory::decode(context, loaded, instruction),
        operation => Ok(operation),
    }
}

fn decode_input(function: &BytecodeFunction, instruction: &Instruction) -> Result<Op, VmTrap> {
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    let target_type = function
        .register_type(destination)
        .ok_or_else(invalid_bytecode)?;
    let register_index = destination.index;
    match target_type {
        ValueType::I64 => Ok(Op::InReadInteger {
            destination: register_index,
        }),
        ValueType::F64 => Ok(Op::InReadReal {
            destination: register_index,
        }),
        ValueType::Bool => Ok(Op::InReadBoolean {
            destination: register_index,
        }),
        ValueType::Char => Ok(Op::InReadCharacter {
            destination: register_index,
        }),
        ValueType::Str => Ok(Op::InReadString {
            destination: register_index,
        }),
        _ => Err(invalid_bytecode()),
    }
}

fn decode_observation(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let line = instruction
        .span
        .or(context.function.declaration_span)
        .map(|span| span.start_line)
        .unwrap_or(0);
    let kind = match instruction.opcode {
        Opcode::StmtEnter => ObservationKind::StatementEnter,
        Opcode::StmtExit => ObservationKind::StatementExit,
        Opcode::DecideBool => {
            let register = extract_register(instruction)?;
            ObservationKind::DecideBool {
                condition: register,
            }
        }
        Opcode::DecideCase => {
            let register = extract_register(instruction)?;
            ObservationKind::DecideCase { index: register }
        }
        Opcode::DecideDefault => ObservationKind::DecideDefault,
        Opcode::DecideNone => ObservationKind::DecideNone,
        _ => return Err(invalid_bytecode()),
    };
    let site = u32::try_from(loaded.observations.len()).map_err(|_| invalid_bytecode())?;
    loaded.observations.push(ObservationSite { kind, line });
    Ok(Op::Observe { site })
}

fn extract_register(instruction: &Instruction) -> Result<u16, VmTrap> {
    instruction
        .operands
        .first()
        .and_then(|operand| match operand {
            BytecodeOperand::Register(register) => Some(register.index),
            _ => None,
        })
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
    let then_edge = add_edge(context, loaded, (branch_pc, false), branch.operands.get(1))?;
    let else_edge = add_edge(context, loaded, (branch_pc, false), branch.operands.get(2))?;
    Ok(select_fused(
        compare.opcode,
        predicate(compare),
        destination,
        &sources,
        (then_edge, else_edge),
    ))
}
