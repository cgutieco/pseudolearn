use super::DecodeContext;
use crate::{VmTrap, dispatch::Op};
use crate::load::{invalid_bytecode, model::{EffectSite, LoadedFunction}};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, ValueType as IrType, RegisterClass};

pub(super) fn decode(context: &DecodeContext<'_>, loaded: &mut LoadedFunction, instruction: &Instruction) -> Result<Op, VmTrap> {
    let Some(BytecodeOperand::Register(capability)) = instruction.operands.first() else { return Err(invalid_bytecode()); };
    let Some(BytecodeOperand::Identifier(operation)) = instruction.operands.get(1) else { return Err(invalid_bytecode()); };
    let descriptor = pseudolearn_runtime::effect_operation(operation).ok_or_else(invalid_bytecode)?;
    let Some(BytecodeOperand::Type(result_type)) = instruction.operands.get(2) else { return Err(invalid_bytecode()); };
    let Some(BytecodeOperand::Identifier(source)) = instruction.operands.get(3) else { return Err(invalid_bytecode()); };
    let source_node_id = source.strip_prefix('n').and_then(|source| source.parse().ok()).ok_or_else(invalid_bytecode)?;
    let count = if descriptor.fallible { 3 } else { 1 };
    if capability.class != RegisterClass::Reference || instruction.operands.len() != descriptor.parameters.len().saturating_add(count).saturating_add(4) {
        return Err(invalid_bytecode());
    }
    let registers = instruction.operands.iter().skip(4).map(|operand| match operand {
        BytecodeOperand::Register(register) => Ok(register.index), _ => Err(invalid_bytecode()),
    }).collect::<Result<Vec<_>, _>>()?;
    let arguments = registers.get(..descriptor.parameters.len()).ok_or_else(invalid_bytecode)?.to_vec();
    let result_cells = registers.get(descriptor.parameters.len()..).ok_or_else(invalid_bytecode)?.to_vec();
    let result_class = match result_type {
        IrType::Object(name) => context.module.classes.iter().position(|class| class.name == *name).and_then(|index| u32::try_from(index).ok()).ok_or_else(invalid_bytecode)?,
        _ => 0,
    };
    let site = u32::try_from(loaded.effect_sites.len()).map_err(|_| invalid_bytecode())?;
    loaded.effect_sites.push(EffectSite { destination: instruction.destination, capability: capability.index,
        operation: operation.clone(), arguments, result_cells, result_class, source_node_id });
    Ok(Op::EffectCall { site })
}
