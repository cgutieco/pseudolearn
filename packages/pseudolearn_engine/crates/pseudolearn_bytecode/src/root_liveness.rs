use crate::{BytecodeError, BytecodeOperand, CodeVariant, Instruction, RegisterClass};
use std::collections::BTreeSet;

pub(crate) fn analyze(variant: &CodeVariant) -> Result<Vec<BTreeSet<u16>>, BytecodeError> {
    analyze_slots(variant, RegisterClass::Reference)
}

pub fn analyze_slots(
    variant: &CodeVariant,
    class: RegisterClass,
) -> Result<Vec<BTreeSet<u16>>, BytecodeError> {
    let count = usize::try_from(variant.used_length).map_err(|_| BytecodeError::InvalidModule)?;
    let mut live = vec![BTreeSet::new(); count];
    loop {
        let mut changed = false;
        for position in (0..count).rev() {
            let instruction = variant
                .instructions
                .get(position)
                .ok_or(BytecodeError::InvalidModule)?;
            let mut incoming = outgoing(variant, position, &live, (instruction, class))?;
            if let Some(register) = instruction
                .destination
                .filter(|register| register.class == class)
            {
                incoming.remove(&register.index);
            }
            incoming.extend(uses(instruction, class));
            let previous = live.get_mut(position).ok_or(BytecodeError::InvalidModule)?;
            changed |= *previous != incoming;
            *previous = incoming;
        }
        if !changed {
            return Ok(live);
        }
    }
}

fn outgoing(
    variant: &CodeVariant,
    position: usize,
    live: &[BTreeSet<u16>],
    (instruction, class): (&Instruction, RegisterClass),
) -> Result<BTreeSet<u16>, BytecodeError> {
    let mut outgoing = BTreeSet::new();
    let mut branching = false;
    for operand in &instruction.operands {
        if let BytecodeOperand::BlockTarget { target, arguments } = operand {
            branching = !matches!(
                instruction.opcode.as_name(),
                "task.cancel_point" | "task.scope_boundary"
            );
            let edge = branch_roots(variant, (*target, arguments), live, class)?;
            outgoing.extend(edge);
        }
    }
    if !branching
        && !matches!(
            instruction.opcode.as_name(),
            "return" | "unreachable" | "trap.missing_return"
        )
    {
        let next = position
            .checked_add(1)
            .ok_or(BytecodeError::InvalidModule)?;
        if let Some(successor) = live.get(next) {
            outgoing.extend(successor);
        }
    }
    Ok(outgoing)
}

fn uses(instruction: &Instruction, class: RegisterClass) -> BTreeSet<u16> {
    let mut used = BTreeSet::new();
    for operand in &instruction.operands {
        match operand {
            BytecodeOperand::Register(register) if register.class == class => {
                used.insert(register.index);
            }
            BytecodeOperand::FunctionTarget { arguments, .. } => {
                used.extend(
                    arguments
                        .iter()
                        .filter(|register| register.class == class)
                        .map(|register| register.index),
                );
            }
            _ => {}
        }
    }
    used
}

fn branch_roots(
    variant: &CodeVariant,
    (target, arguments): (pseudolearn_ir::BlockId, &[crate::Register]),
    live: &[BTreeSet<u16>],
    class: RegisterClass,
) -> Result<BTreeSet<u16>, BytecodeError> {
    let block = variant
        .blocks
        .iter()
        .find(|block| block.identifier == target)
        .ok_or(BytecodeError::MissingBlock)?;
    let position = usize::try_from(block.start_pc).map_err(|_| BytecodeError::InvalidModule)?;
    let mut edge = live
        .get(position)
        .ok_or(BytecodeError::InvalidModule)?
        .clone();
    let required = block
        .parameters
        .iter()
        .zip(arguments)
        .filter(|(parameter, _)| parameter.class == class && edge.contains(&parameter.index))
        .map(|(_, source)| source.index)
        .collect::<Vec<_>>();
    for parameter in &block.parameters {
        if parameter.class == class {
            edge.remove(&parameter.index);
        }
    }
    edge.extend(required);
    Ok(edge)
}
