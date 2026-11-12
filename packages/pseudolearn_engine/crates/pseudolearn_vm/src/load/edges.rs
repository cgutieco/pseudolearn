#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Register, RegisterClass};

use super::instructions::DecodeContext;
use super::parallel_copy::sequentialize;
use super::{Definition, Edge, LoadedFunction, Move, invalid_bytecode, scratch_register};
use crate::VmTrap;

pub(super) fn add_edge(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    (source_pc, probed): (u32, bool),
    operand: Option<&BytecodeOperand>,
) -> Result<u32, VmTrap> {
    let Some(BytecodeOperand::BlockTarget { target, arguments }) = operand else {
        return Err(invalid_bytecode());
    };
    let variant = if probed {
        &context.function.probed
    } else {
        &context.function.fast
    };
    let block = variant
        .blocks
        .iter()
        .find(|block| block.identifier == *target)
        .ok_or_else(invalid_bytecode)?;
    if block.parameters.len() != arguments.len() {
        return Err(invalid_bytecode());
    }
    let moves_start = loaded.moves.len();
    append_block_moves(
        context,
        loaded,
        (arguments, &block.parameters),
        (source_pc, probed),
    )?;
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

fn append_block_moves(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    (arguments, parameters): (&[Register], &[Register]),
    (source_pc, probed): (u32, bool),
) -> Result<(), VmTrap> {
    let pairs = arguments
        .iter()
        .copied()
        .zip(parameters.iter().copied())
        .collect::<Vec<_>>();
    append_moves(context, loaded, &pairs, (source_pc, probed))
}

fn append_moves(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    pairs: &[(Register, Register)],
    (source_pc, probed): (u32, bool),
) -> Result<(), VmTrap> {
    for class in [RegisterClass::Scalar, RegisterClass::Reference] {
        let pending = class_moves(context, pairs, (class, source_pc), probed);
        let scratch = scratch_register(context.function, class)?;
        loaded.moves.extend(sequentialize(pending, scratch));
    }
    Ok(())
}

fn class_moves(
    context: &DecodeContext<'_>,
    pairs: &[(Register, Register)],
    (class, source_pc): (RegisterClass, u32),
    probed: bool,
) -> Vec<Move> {
    pairs
        .iter()
        .filter(|(source, destination)| source.class == class && destination.class == class)
        .map(|(source, destination)| Move {
            source: source.index,
            destination: destination.index,
            class,
            definition: block_definition(context, *source, (*destination, source_pc), probed),
        })
        .collect()
}

fn block_definition(
    context: &DecodeContext<'_>,
    source: Register,
    (destination, source_pc): (Register, u32),
    probed: bool,
) -> Definition {
    let tracked = context.definedness.is_tracked(destination);
    let variant = if probed {
        &context.function.probed
    } else {
        &context.function.fast
    };
    let instruction = usize::try_from(source_pc)
        .ok()
        .and_then(|position| variant.instructions.get(position));
    instruction.map_or(Definition::Untracked, |instruction| {
        super::definitions::source_definition(context, (instruction, source), tracked)
    })
}
