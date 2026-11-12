use super::DecodeContext;
use crate::load::{
    invalid_bytecode,
    model::{EffectSite, LoadedFunction},
};
use crate::{VmTrap, dispatch::Op};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, RegisterClass, ValueType};

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let effect = effect_site(context, instruction)?;
    let site = u32::try_from(loaded.effect_sites.len()).map_err(|_| invalid_bytecode())?;
    loaded.effect_sites.push(effect);
    Ok(Op::EffectCall { site })
}

fn effect_site(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<EffectSite, VmTrap> {
    let [
        BytecodeOperand::Register(capability),
        BytecodeOperand::Identifier(operation),
        BytecodeOperand::Type(result_type),
        BytecodeOperand::Identifier(source),
        rest @ ..,
    ] = instruction.operands.as_slice()
    else {
        return Err(invalid_bytecode());
    };
    let descriptor =
        pseudolearn_runtime::effect_operation(operation).ok_or_else(invalid_bytecode)?;
    let count = descriptor.result_cell_count();
    if capability.class != RegisterClass::Reference
        || rest.len() != descriptor.parameters.len().saturating_add(count)
    {
        return Err(invalid_bytecode());
    }
    let source_node_id = source
        .strip_prefix('n')
        .and_then(|source| source.parse().ok())
        .ok_or_else(invalid_bytecode)?;
    let (arguments, result_cells) = effect_arguments(rest, descriptor.parameters.len())?;
    Ok(EffectSite {
        awaited: instruction.opcode == pseudolearn_bytecode::Opcode::EffectAwait,
        destination: instruction.destination,
        capability: capability.index,
        operation: operation.clone(),
        arguments,
        result_cells,
        result_class: result_class(context, result_type)?,
        source_node_id,
    })
}

fn registers(operands: &[BytecodeOperand]) -> Result<Vec<u16>, VmTrap> {
    operands
        .iter()
        .map(|operand| match operand {
            BytecodeOperand::Register(register) => Ok(register.index),
            _ => Err(invalid_bytecode()),
        })
        .collect()
}

fn result_class(context: &DecodeContext<'_>, kind: &ValueType) -> Result<u32, VmTrap> {
    match kind {
        ValueType::Object(name) => context
            .module
            .classes
            .iter()
            .position(|class| class.name == *name)
            .and_then(|index| u32::try_from(index).ok())
            .ok_or_else(invalid_bytecode),
        _ => Ok(0),
    }
}

fn effect_arguments(
    rest: &[BytecodeOperand],
    parameter_count: usize,
) -> Result<(Vec<u16>, Vec<u16>), VmTrap> {
    let registers = registers(rest)?;
    let arguments = registers
        .get(..parameter_count)
        .ok_or_else(invalid_bytecode)?
        .to_vec();
    let result_cells = registers
        .get(parameter_count..)
        .ok_or_else(invalid_bytecode)?
        .to_vec();
    Ok((arguments, result_cells))
}
