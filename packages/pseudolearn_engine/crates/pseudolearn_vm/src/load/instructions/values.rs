#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeOperand, Instruction, Opcode, RegisterClass, ValueType,
};

use super::DecodeContext;
use crate::VmTrap;
use crate::dispatch::Op;
use crate::load::definedness::StaticState;
use crate::load::operands::{
    constant_word, first_register, scalar_source, sentinel_of, sentinel_word,
};
use crate::load::{Source, invalid_bytecode};

pub(super) fn decode_constant(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let Some(BytecodeOperand::Constant(index)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    match (destination.class, constant_word(function, *index)) {
        (RegisterClass::Scalar, Some(word)) => Ok(Op::LoadWord {
            destination: destination.index,
            word,
        }),
        _ => Ok(Op::Unsupported),
    }
}

pub(super) fn decode_value_state(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match instruction.opcode {
        Opcode::ValueUndefined => decode_undefined(context.function, instruction),
        Opcode::ValueRequire => decode_require(context, instruction),
        _ => Err(invalid_bytecode()),
    }
}

fn decode_undefined(function: &BytecodeFunction, instruction: &Instruction) -> Result<Op, VmTrap> {
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    Ok(match destination.class {
        RegisterClass::Scalar => Op::MarkUndefined {
            destination: destination.index,
            word: sentinel_word(sentinel_of(function.register_type(destination))),
        },
        RegisterClass::Reference => Op::MarkUndefinedReference {
            destination: destination.index,
        },
    })
}

fn decode_require(context: &DecodeContext<'_>, instruction: &Instruction) -> Result<Op, VmTrap> {
    let source = first_register(instruction)?;
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    if source.class != destination.class {
        return Err(invalid_bytecode());
    }
    if source.class == RegisterClass::Reference {
        return Ok(Op::RequireReference {
            destination: destination.index,
            source: source.index,
        });
    }
    if !context.definedness.is_integer(source) {
        let sentinel = sentinel_of(context.function.register_type(source));
        return Ok(Op::RequireSentinel {
            destination: destination.index,
            source: source.index,
            sentinel,
        });
    }
    Ok(match context.definedness.state(source) {
        StaticState::Defined => Op::MoveScalar {
            destination: destination.index,
            source: source.index,
        },
        StaticState::Undefined => Op::RequireFailed,
        StaticState::Dynamic => Op::RequireDefinedInteger {
            destination: destination.index,
            source: source.index,
        },
    })
}

pub(super) fn decode_output(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let value = instruction.operands.first().ok_or_else(invalid_bytecode)?;
    let newline = match instruction.operands.get(1) {
        Some(BytecodeOperand::Newline) => true,
        None => false,
        Some(_) => return Err(invalid_bytecode()),
    };
    let integer = match value {
        BytecodeOperand::Register(register) => {
            function.register_type(*register) == Some(&ValueType::I64)
        }
        BytecodeOperand::Constant(index) => matches!(
            function.constants.get(usize::from(*index)),
            Some(pseudolearn_bytecode::Constant::I64(_))
        ),
        _ => false,
    };
    if !integer {
        return Ok(Op::Unsupported);
    }
    Ok(match scalar_source(function, value) {
        Some(Source::Register(source)) => Op::WriteIntegerRegister { source, newline },
        Some(Source::Immediate(word)) => Op::WriteIntegerImmediate { word, newline },
        None => Op::Unsupported,
    })
}
