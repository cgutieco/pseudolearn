#![forbid(unsafe_code)]

use super::DecodeContext;
use crate::VmTrap;
use crate::dispatch::Op;
use crate::load::invalid_bytecode;
use crate::load::model::{EffectSite, LoadedFunction};
use pseudolearn_bytecode::{BytecodeOperand, Instruction};

pub(super) fn decode(
    _context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let capability = match instruction.operands.first() {
        Some(BytecodeOperand::Register(reg)) => reg.index,
        _ => 0,
    };
    let operation = match instruction.operands.get(1) {
        Some(BytecodeOperand::Identifier(name)) => name.clone(),
        _ => String::new(),
    };
    let mut arguments = Vec::new();
    for operand in instruction.operands.iter().skip(2) {
        if let BytecodeOperand::Register(reg) = operand {
            arguments.push(reg.index);
        }
    }
    let site = u32::try_from(loaded.effect_sites.len()).map_err(|_| invalid_bytecode())?;
    loaded.effect_sites.push(EffectSite {
        destination: instruction.destination,
        capability,
        operation,
        arguments,
    });
    Ok(Op::EffectCall { site })
}
