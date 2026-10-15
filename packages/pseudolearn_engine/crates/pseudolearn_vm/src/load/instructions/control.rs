#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeOperand, Instruction, Opcode, Register, RegisterClass, ValueType,
};

use super::DecodeContext;
use crate::VmTrap;
use crate::dispatch::Op;
use crate::load::edges::add_edge;
use crate::load::operands::{first_register, scalar_source};
use crate::load::{CallSite, Definition, LoadedFunction, Move, Source, invalid_bytecode};

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match instruction.opcode {
        Opcode::Jump => {
            let edge = add_edge(
                context,
                loaded,
                program_counter,
                instruction.operands.first(),
            )?;
            Ok(Op::Jump { edge })
        }
        Opcode::Branch => decode_branch(context, loaded, program_counter, instruction),
        Opcode::Call => decode_call(context, loaded, instruction),
        Opcode::Return => decode_return(instruction),
        Opcode::LoopCheckStep => decode_check_step(context, instruction),
        Opcode::TrapMissingReturn => Ok(Op::MissingReturn),
        Opcode::Unreachable => Ok(Op::Unreachable),
        _ => Ok(Op::Unsupported),
    }
}

fn decode_branch(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let condition = first_register(instruction)?;
    if condition.class != RegisterClass::Scalar {
        return Err(invalid_bytecode());
    }
    let then_edge = add_edge(
        context,
        loaded,
        program_counter,
        instruction.operands.get(1),
    )?;
    let else_edge = add_edge(
        context,
        loaded,
        program_counter,
        instruction.operands.get(2),
    )?;
    Ok(Op::Branch {
        condition: condition.index,
        then_edge,
        else_edge,
    })
}

fn decode_call(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let Some(BytecodeOperand::FunctionTarget {
        function_index,
        arguments,
    }) = instruction.operands.first()
    else {
        return Err(invalid_bytecode());
    };
    let callee = context
        .module
        .functions
        .get(usize::from(*function_index))
        .ok_or_else(invalid_bytecode)?;
    if callee.parameters.len() != arguments.len() {
        return Err(invalid_bytecode());
    }
    let arguments_start = loaded.moves.len();
    append_arguments(context, loaded, arguments, callee)?;
    let return_point = instruction.return_point.ok_or_else(invalid_bytecode)?;
    let site = CallSite {
        function: usize::from(*function_index),
        destination: instruction.destination,
        return_point: usize::try_from(return_point).map_err(|_| invalid_bytecode())?,
        arguments_start,
        arguments_end: loaded.moves.len(),
    };
    let index = u32::try_from(loaded.calls.len()).map_err(|_| invalid_bytecode())?;
    loaded.calls.push(site);
    Ok(Op::Call { site: index })
}

fn append_arguments(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    arguments: &[Register],
    callee: &BytecodeFunction,
) -> Result<(), VmTrap> {
    for (source, destination) in arguments.iter().zip(&callee.parameters) {
        if source.class != destination.class {
            return Err(invalid_bytecode());
        }
        let integer = callee.register_type(*destination) == Some(&ValueType::I64);
        loaded.moves.push(Move {
            source: source.index,
            destination: destination.index,
            class: source.class,
            definition: argument_definition(context, *source, integer),
        });
    }
    Ok(())
}

fn argument_definition(context: &DecodeContext<'_>, source: Register, integer: bool) -> Definition {
    context.definedness.definition_into(source, integer)
}

fn decode_return(instruction: &Instruction) -> Result<Op, VmTrap> {
    match instruction.operands.first() {
        None => Ok(Op::ReturnUnit),
        Some(BytecodeOperand::Register(register)) => Ok(match register.class {
            RegisterClass::Scalar => Op::ReturnScalar {
                source: register.index,
            },
            RegisterClass::Reference => Op::ReturnReference {
                source: register.index,
            },
        }),
        Some(_) => Err(invalid_bytecode()),
    }
}

fn decode_check_step(context: &DecodeContext<'_>, instruction: &Instruction) -> Result<Op, VmTrap> {
    let operand = instruction.operands.first().ok_or_else(invalid_bytecode)?;
    match scalar_source(context.function, operand) {
        Some(Source::Register(source)) => Ok(Op::CheckStepRegister { source }),
        Some(Source::Immediate(word)) => Ok(Op::CheckStepImmediate { word }),
        None => Err(invalid_bytecode()),
    }
}
