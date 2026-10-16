use super::{DecodeContext, MemoryOp, destination, indices, invalid_bytecode, reference, typed};
use crate::{VmTrap, dispatch::Op};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

pub(super) fn array_access(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let array = reference(instruction.operands.first())?;
    let operands = instruction.operands.get(1..).ok_or_else(invalid_bytecode)?;
    match instruction.opcode {
        Opcode::ArrayLoad => read_array(context, instruction, array, operands),
        Opcode::CellElement => Ok(MemoryOp::CellElement {
            destination: destination(instruction)?.index,
            array,
            indices: indices(context, operands)?,
        }),
        _ => write_array(context, array, operands),
    }
}

pub(super) fn direct_array_access(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<Option<Op>, VmTrap> {
    if !matches!(instruction.opcode, Opcode::ArrayLoad | Opcode::ArrayStore) {
        return Ok(None);
    }
    let Some(array_operand) = instruction.operands.first() else {
        return Ok(None);
    };
    let array = reference(Some(array_operand))?;
    let operands = instruction.operands.get(1..).ok_or_else(invalid_bytecode)?;
    match instruction.opcode {
        Opcode::ArrayLoad if operands.len() == 1 => {
            let index = operands
                .first()
                .and_then(|operand| super::scalar_source(context.function, operand))
                .ok_or_else(invalid_bytecode)?;
            Ok(Some(Op::ArrayRead1D {
                destination: destination(instruction)?,
                array,
                index,
            }))
        }
        Opcode::ArrayStore if operands.len() == 2 => {
            let index = operands
                .first()
                .and_then(|operand| super::scalar_source(context.function, operand))
                .ok_or_else(invalid_bytecode)?;
            let source = typed(context, operands.get(1))?.source;
            Ok(Some(Op::ArrayWrite1D {
                array,
                index,
                source,
            }))
        }
        _ => Ok(None),
    }
}

fn read_array(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
    array: u16,
    operands: &[BytecodeOperand],
) -> Result<MemoryOp, VmTrap> {
    Ok(MemoryOp::ArrayRead {
        destination: destination(instruction)?,
        array,
        indices: indices(context, operands)?,
    })
}

fn write_array(
    context: &DecodeContext<'_>,
    array: u16,
    operands: &[BytecodeOperand],
) -> Result<MemoryOp, VmTrap> {
    let indices = indices(
        context,
        operands
            .get(..operands.len().saturating_sub(1))
            .ok_or_else(invalid_bytecode)?,
    )?;
    let source = typed(context, operands.last())?;
    Ok(MemoryOp::ArrayWrite {
        array,
        indices,
        source,
    })
}
