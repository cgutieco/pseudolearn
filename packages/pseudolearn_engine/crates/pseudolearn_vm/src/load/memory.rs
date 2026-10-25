use super::instructions::DecodeContext;
use super::operands::scalar_source;
use super::{LoadedFunction, Source, invalid_bytecode};
use crate::{VmTrap, dispatch::Op};
use pseudolearn_bytecode::{
    BytecodeOperand, Instruction, Opcode, Register, RegisterClass, ValueType,
};
use pseudolearn_runtime::ValueKind;

mod arrays;
mod model;
mod objects;
use arrays::{array_access, direct_array_access};
pub(crate) use model::{MemoryOp, TypedSource, ValueSource};
use objects::{field_cell, object_new, object_read, object_write};

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    if let Some(operation) = direct_operation(context, instruction)? {
        return Ok(operation);
    }
    let operation = match instruction.opcode {
        Opcode::ArrayNew => array_new(context, instruction)?,
        Opcode::ArrayLoad | Opcode::ArrayStore | Opcode::CellElement => {
            array_access(context, instruction)?
        }
        Opcode::ObjectNew => object_new(context, instruction)?,
        Opcode::ObjectCopy => MemoryOp::ObjectCopy {
            destination: destination(instruction)?.index,
            source: reference(instruction.operands.first())?,
        },
        Opcode::RefCmp => reference_compare(instruction)?,
        Opcode::CellLocal => local_cell(loaded, instruction)?,
        Opcode::CellLoad | Opcode::CellLoadRaw => load_cell(instruction)?,
        Opcode::CellStore => MemoryOp::CellStore {
            cell: reference(instruction.operands.first())?,
            source: typed(context, instruction.operands.get(1))?,
        },
        Opcode::CellField => field_cell(context, instruction)?,
        Opcode::HostRandom => MemoryOp::Random {
            destination: destination(instruction)?.index,
        },
        Opcode::OutWrite => output(context, instruction)?,
        _ => text(context, instruction)?,
    };
    let site = u32::try_from(loaded.memory.len()).map_err(|_| invalid_bytecode())?;
    loaded.memory.push(operation);
    Ok(Op::Memory { site })
}

fn direct_operation(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<Option<Op>, VmTrap> {
    match instruction.opcode {
        Opcode::ObjectLoad | Opcode::ObjectLoadRaw => object_read(context, instruction).map(Some),
        Opcode::ObjectStore => object_write(context, instruction).map(Some),
        Opcode::ArrayLoad | Opcode::ArrayStore => direct_array_access(context, instruction),
        _ => Ok(None),
    }
}

fn array_new(context: &DecodeContext<'_>, instruction: &Instruction) -> Result<MemoryOp, VmTrap> {
    let Some(BytecodeOperand::Type(kind)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    let kind = match kind {
        ValueType::Array { element, .. } => element.as_ref(),
        _ => kind,
    };
    Ok(MemoryOp::ArrayNew {
        destination: destination(instruction)?.index,
        element: value_kind(kind),
        dimensions: indices(
            context,
            instruction.operands.get(1..).ok_or_else(invalid_bytecode)?,
        )?,
    })
}

fn local_cell(loaded: &mut LoadedFunction, instruction: &Instruction) -> Result<MemoryOp, VmTrap> {
    let Some(BytecodeOperand::Type(kind)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    let kind = value_kind(kind);
    let (class, window) = if kind == ValueKind::Reference {
        (RegisterClass::Reference, &mut loaded.reference_window)
    } else {
        (RegisterClass::Scalar, &mut loaded.scalar_window)
    };
    let index = u16::try_from(*window).map_err(|_| invalid_bytecode())?;
    *window = window.checked_add(1).ok_or_else(invalid_bytecode)?;
    Ok(MemoryOp::CellLocal {
        destination: destination(instruction)?.index,
        kind,
        slot: Register { class, index },
    })
}

fn reference_compare(instruction: &Instruction) -> Result<MemoryOp, VmTrap> {
    let Some(BytecodeOperand::Predicate(predicate)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    Ok(MemoryOp::ReferenceCompare {
        destination: destination(instruction)?.index,
        left: reference(instruction.operands.get(1))?,
        right: reference(instruction.operands.get(2))?,
        equal: predicate == "eq",
    })
}

fn text(context: &DecodeContext<'_>, instruction: &Instruction) -> Result<MemoryOp, VmTrap> {
    let mut sources = Vec::new();
    let mut predicate = None;
    for operand in &instruction.operands {
        if let BytecodeOperand::Predicate(value) = operand {
            predicate = Some(value.clone());
        } else {
            sources.push(typed(context, Some(operand))?);
        }
    }
    Ok(MemoryOp::Text {
        opcode: instruction.opcode,
        destination: destination(instruction)?,
        sources,
        predicate,
    })
}

pub(super) fn output(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let mut sources = Vec::new();
    for operand in &instruction.operands {
        if *operand != BytecodeOperand::Newline {
            sources.push(typed(context, Some(operand))?);
        }
    }
    Ok(MemoryOp::Output {
        sources,
        newline: instruction.operands.last() == Some(&BytecodeOperand::Newline),
    })
}

fn indices(
    context: &DecodeContext<'_>,
    operands: &[BytecodeOperand],
) -> Result<Vec<Source>, VmTrap> {
    operands
        .iter()
        .map(|operand| scalar_source(context.function, operand).ok_or_else(invalid_bytecode))
        .collect()
}

pub(super) fn typed(
    context: &DecodeContext<'_>,
    operand: Option<&BytecodeOperand>,
) -> Result<TypedSource, VmTrap> {
    let operand = operand.ok_or_else(invalid_bytecode)?;
    let kind = operand_kind(context, operand)?;
    let source = match operand {
        BytecodeOperand::Constant(index) if kind == ValueKind::Reference => {
            let Some(pseudolearn_bytecode::Constant::Str(text)) =
                context.function.constants.get(usize::from(*index))
            else {
                return Err(invalid_bytecode());
            };
            let index = context
                .literals
                .iter()
                .position(|literal| literal == text)
                .ok_or_else(invalid_bytecode)?;
            ValueSource::LiteralText(u32::try_from(index).map_err(|_| invalid_bytecode())?)
        }
        BytecodeOperand::Register(register) if register.class == RegisterClass::Reference => {
            ValueSource::Reference(register.index)
        }
        _ => ValueSource::Scalar(
            scalar_source(context.function, operand).ok_or_else(invalid_bytecode)?,
        ),
    };
    Ok(TypedSource { source, kind })
}

pub(crate) fn value_kind(kind: &ValueType) -> ValueKind {
    match kind {
        ValueType::I64 => ValueKind::Integer,
        ValueType::F64 => ValueKind::Real,
        ValueType::Bool => ValueKind::Boolean,
        ValueType::Char => ValueKind::Character,
        _ => ValueKind::Reference,
    }
}

fn destination(instruction: &Instruction) -> Result<Register, VmTrap> {
    instruction.destination.ok_or_else(invalid_bytecode)
}

fn reference(operand: Option<&BytecodeOperand>) -> Result<u16, VmTrap> {
    if let Some(BytecodeOperand::Register(register)) = operand
        && register.class == RegisterClass::Reference
    {
        Ok(register.index)
    } else {
        Err(invalid_bytecode())
    }
}

fn operand_kind(
    context: &DecodeContext<'_>,
    operand: &BytecodeOperand,
) -> Result<ValueKind, VmTrap> {
    Ok(match operand {
        BytecodeOperand::Register(register) => context
            .function
            .register_type(*register)
            .map(value_kind)
            .ok_or_else(invalid_bytecode)?,
        BytecodeOperand::Constant(index) => {
            match context.function.constants.get(usize::from(*index)) {
                Some(pseudolearn_bytecode::Constant::I64(_)) => ValueKind::Integer,
                Some(pseudolearn_bytecode::Constant::F64(_)) => ValueKind::Real,
                Some(pseudolearn_bytecode::Constant::Bool(_)) => ValueKind::Boolean,
                Some(pseudolearn_bytecode::Constant::Char(_)) => ValueKind::Character,
                Some(pseudolearn_bytecode::Constant::Str(_)) => ValueKind::Reference,
                _ => return Err(invalid_bytecode()),
            }
        }
        _ => return Err(invalid_bytecode()),
    })
}

fn load_cell(instruction: &Instruction) -> Result<MemoryOp, VmTrap> {
    let destination = destination(instruction)?;
    let cell = reference(instruction.operands.first())?;
    Ok(if instruction.opcode == Opcode::CellLoadRaw {
        MemoryOp::CellLoadRaw { destination, cell }
    } else {
        MemoryOp::CellLoad { destination, cell }
    })
}
