#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Register, RegisterClass};

use super::instructions::DecodeContext;
use super::parallel_copy::sequentialize;
use super::{Definition, Edge, LoadedFunction, Move, invalid_bytecode, scratch_register};
use crate::VmTrap;

pub(super) fn add_edge(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    source_pc: u32,
    operand: Option<&BytecodeOperand>,
) -> Result<u32, VmTrap> {
    let Some(BytecodeOperand::BlockTarget { target, arguments }) = operand else {
        return Err(invalid_bytecode());
    };
    let block = context
        .function
        .fast
        .blocks
        .iter()
        .find(|block| block.identifier == *target)
        .ok_or_else(invalid_bytecode)?;
    if block.parameters.len() != arguments.len() {
        return Err(invalid_bytecode());
    }
    let pairs = arguments
        .iter()
        .copied()
        .zip(block.parameters.iter().copied())
        .collect::<Vec<_>>();
    let moves_start = loaded.moves.len();
    append_moves(context, loaded, &pairs)?;
    let edge = Edge {
        target: usize::try_from(block.start_pc).map_err(|_| invalid_bytecode())?,
        mass: u64::from(block.mass),
        probe: block.start_pc <= source_pc && block.mass == 0,
        moves_start,
        moves_end: loaded.moves.len(),
    };
    let index = u32::try_from(loaded.edges.len()).map_err(|_| invalid_bytecode())?;
    loaded.edges.push(edge);
    Ok(index)
}

fn append_moves(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    pairs: &[(Register, Register)],
) -> Result<(), VmTrap> {
    for class in [RegisterClass::Scalar, RegisterClass::Reference] {
        let pending = class_moves(context, pairs, class);
        let scratch = scratch_register(context.function, class)?;
        loaded.moves.extend(sequentialize(pending, scratch));
    }
    Ok(())
}

fn class_moves(
    context: &DecodeContext<'_>,
    pairs: &[(Register, Register)],
    class: RegisterClass,
) -> Vec<Move> {
    pairs
        .iter()
        .filter(|(source, destination)| source.class == class && destination.class == class)
        .map(|(source, destination)| Move {
            source: source.index,
            destination: destination.index,
            class,
            definition: block_definition(context, *source, *destination),
        })
        .collect()
}

fn block_definition(
    context: &DecodeContext<'_>,
    source: Register,
    destination: Register,
) -> Definition {
    let tracked = context.definedness.is_tracked(destination);
    context.definedness.definition_into(source, tracked)
}
