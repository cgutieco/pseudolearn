use super::{DecodeContext, LoadedFunction, invalid_bytecode};
use crate::{
    VmTrap,
    dispatch::{Op, TaskOp},
};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode, Register};

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct ChannelSite {
    pub command: String,
    pub destination: Register,
    pub arguments: Vec<Register>,
}

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let destination = instruction.destination.ok_or_else(invalid_bytecode)?;
    if instruction.opcode == Opcode::TaskValueLoad {
        let [BytecodeOperand::Type(_), BytecodeOperand::Constant(index)] =
            instruction.operands.as_slice()
        else {
            return Err(invalid_bytecode());
        };
        let index = super::super::operands::constant_word(context.function, *index)
            .and_then(|value| u32::try_from(value).ok())
            .ok_or_else(invalid_bytecode)?;
        return Ok(Op::Task(TaskOp::ValueLoad { destination, index }));
    }
    let [
        BytecodeOperand::Identifier(command),
        BytecodeOperand::Type(_),
        arguments @ ..,
    ] = instruction.operands.as_slice()
    else {
        return Err(invalid_bytecode());
    };
    let arguments = arguments
        .iter()
        .map(|argument| match argument {
            BytecodeOperand::Register(register) => Ok(*register),
            _ => Err(invalid_bytecode()),
        })
        .collect::<Result<Vec<_>, _>>()?;
    let site = u32::try_from(loaded.channel_sites.len()).map_err(|_| invalid_bytecode())?;
    loaded.channel_sites.push(ChannelSite {
        command: command.clone(),
        destination,
        arguments,
    });
    Ok(Op::Task(TaskOp::Channel { site }))
}
