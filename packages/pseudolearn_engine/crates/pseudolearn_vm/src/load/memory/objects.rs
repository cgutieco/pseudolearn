use super::{DecodeContext, MemoryOp, destination, typed};
use crate::load::invalid_bytecode;
use crate::{VmTrap, dispatch::Op};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, ValueType};

pub(super) fn object_new(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let Some(BytecodeOperand::Identifier(name)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    let class = context
        .module
        .classes
        .iter()
        .position(|class| &class.name == name)
        .ok_or_else(invalid_bytecode)?;
    Ok(MemoryOp::ObjectNew {
        destination: destination(instruction)?.index,
        class,
    })
}

pub(super) fn field_cell(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let (receiver, offset) = object_field(context, instruction)?;
    Ok(MemoryOp::CellField {
        destination: destination(instruction)?.index,
        receiver,
        offset,
    })
}

pub(super) fn object_read(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let (receiver, offset) = object_field(context, instruction)?;
    if instruction.opcode == pseudolearn_bytecode::Opcode::ObjectLoadRaw {
        Ok(Op::ObjectReadRaw {
            destination: destination(instruction)?,
            receiver,
            offset,
        })
    } else {
        Ok(Op::ObjectRead {
            destination: destination(instruction)?,
            receiver,
            offset,
        })
    }
}

pub(super) fn object_write(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let (receiver, offset) = object_field(context, instruction)?;
    Ok(Op::ObjectWrite {
        receiver,
        offset,
        source: typed(context, instruction.operands.get(2))?.source,
    })
}

fn object_field(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<(u16, usize), VmTrap> {
    let Some(BytecodeOperand::Register(receiver)) = instruction.operands.first() else {
        return Err(invalid_bytecode());
    };
    let Some(ValueType::Object(name)) = context.function.register_type(*receiver) else {
        return Err(invalid_bytecode());
    };
    let Some(BytecodeOperand::Identifier(field)) = instruction.operands.get(1) else {
        return Err(invalid_bytecode());
    };
    let class = context
        .module
        .classes
        .iter()
        .find(|class| &class.name == name)
        .ok_or_else(invalid_bytecode)?;
    let offset = class
        .fields
        .iter()
        .position(|(name, _)| name == field)
        .ok_or_else(invalid_bytecode)?;
    Ok((receiver.index, offset))
}
