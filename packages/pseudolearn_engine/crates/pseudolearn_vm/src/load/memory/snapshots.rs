use super::{MemoryOp, reference};
use crate::VmTrap;
use crate::load::instructions::DecodeContext;
use crate::load::invalid_bytecode;
use pseudolearn_bytecode::Instruction;

pub(super) fn decode(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let Some(pseudolearn_bytecode::BytecodeOperand::Constant(index)) = instruction.operands.first()
    else {
        return Err(invalid_bytecode());
    };
    let Some(pseudolearn_bytecode::Constant::I64(count)) =
        context.function.constants.get(usize::from(*index))
    else {
        return Err(invalid_bytecode());
    };
    let count = usize::try_from(*count).map_err(|_| invalid_bytecode())?;
    let registers = instruction
        .operands
        .get(1..)
        .ok_or_else(invalid_bytecode)?
        .iter()
        .map(|operand| reference(Some(operand)))
        .collect::<Result<Vec<_>, _>>()?;
    if count == 0 || count.checked_mul(2) != Some(registers.len()) {
        return Err(invalid_bytecode());
    }
    let (sources, destinations) = registers.split_at(count);
    Ok(MemoryOp::Snapshot {
        sources: sources.to_vec(),
        destinations: destinations.to_vec(),
    })
}
