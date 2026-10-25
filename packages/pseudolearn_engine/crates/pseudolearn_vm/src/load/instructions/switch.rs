use super::DecodeContext;
use crate::VmTrap;
use crate::dispatch::Op;
use crate::load::edges::add_edge;
use crate::load::model::SwitchTable;
use crate::load::{LoadedFunction, invalid_bytecode};
use pseudolearn_bytecode::{BytecodeOperand, Constant, Instruction};

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    position: (u32, bool),
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let source = crate::load::operands::first_register(instruction)?;
    let default = add_edge(context, loaded, position, instruction.operands.get(1))?;
    let mut targets = Vec::new();
    for pair in instruction
        .operands
        .get(2..)
        .ok_or_else(invalid_bytecode)?
        .as_chunks::<2>()
        .0
        .iter()
    {
        let Some(BytecodeOperand::Constant(index)) = pair.first() else {
            return Err(invalid_bytecode());
        };
        let Some(Constant::I64(ordinal)) = context.function.constants.get(usize::from(*index))
        else {
            return Err(invalid_bytecode());
        };
        let ordinal = usize::try_from(*ordinal).map_err(|_| invalid_bytecode())?;
        if ordinal >= 65_536 {
            return Err(invalid_bytecode());
        }
        let edge = add_edge(context, loaded, position, pair.get(1))?;
        targets.resize(targets.len().max(ordinal.saturating_add(1)), default);
        *targets.get_mut(ordinal).ok_or_else(invalid_bytecode)? = edge;
    }
    let table = u32::try_from(loaded.switches.len()).map_err(|_| invalid_bytecode())?;
    loaded.switches.push(SwitchTable { default, targets });
    Ok(Op::Switch {
        source: source.index,
        table,
    })
}
