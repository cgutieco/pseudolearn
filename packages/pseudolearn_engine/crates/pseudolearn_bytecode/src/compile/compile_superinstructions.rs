#![forbid(unsafe_code)]

use crate::Opcode;
use crate::error::BytecodeError;
use crate::model::CodeVariant;

pub(super) fn select_compare_branches(variant: &mut CodeVariant) -> Result<(), BytecodeError> {
    let mut ranges = variant
        .blocks
        .iter()
        .map(|block| usize::try_from(block.start_pc).map_err(|_| BytecodeError::InvalidModule))
        .collect::<Result<Vec<_>, _>>()?;
    ranges.push(variant.instructions.len());
    for pair in ranges.windows(2) {
        let start = pair.first().copied().ok_or(BytecodeError::InvalidModule)?;
        let end = pair.get(1).copied().ok_or(BytecodeError::InvalidModule)?;
        select_block_compare_branches(variant, start, end)?;
    }
    Ok(())
}

fn select_block_compare_branches(
    variant: &mut CodeVariant,
    start: usize,
    end: usize,
) -> Result<(), BytecodeError> {
    if end.saturating_sub(start) < 2 {
        return Ok(());
    }
    for first in start..end.saturating_sub(1) {
        let second = first.checked_add(1).ok_or(BytecodeError::InvalidModule)?;
        let pair = (
            variant.instructions.get(first),
            variant.instructions.get(second),
        );
        let (Some(compare), Some(branch)) = pair else {
            return Err(BytecodeError::InvalidModule);
        };
        if matches!(compare.opcode.as_name(), "int.cmp" | "real.cmp")
            && branch.opcode.as_name() == "branch"
        {
            let compare_pc = u32::try_from(first).map_err(|_| BytecodeError::InvalidModule)?;
            let branch_pc = compare_pc
                .checked_add(1)
                .ok_or(BytecodeError::InvalidModule)?;
            variant.superinstructions.insert(compare_pc, branch_pc);
        }
    }
    Ok(())
}

pub(super) fn select_arithmetic_superinstructions(
    variant: &mut CodeVariant,
) -> Result<(), BytecodeError> {
    let mut ranges = variant
        .blocks
        .iter()
        .map(|block| usize::try_from(block.start_pc).map_err(|_| BytecodeError::InvalidModule))
        .collect::<Result<Vec<_>, _>>()?;
    ranges.push(variant.instructions.len());
    for pair in ranges.windows(2) {
        let start = pair.first().copied().ok_or(BytecodeError::InvalidModule)?;
        let end = pair.get(1).copied().ok_or(BytecodeError::InvalidModule)?;
        select_block_arithmetic(variant, start, end)?;
    }
    Ok(())
}

fn select_block_arithmetic(
    variant: &mut CodeVariant,
    start: usize,
    end: usize,
) -> Result<(), BytecodeError> {
    if end.saturating_sub(start) < 2 {
        return Ok(());
    }
    let mut current = start;
    while current < end.saturating_sub(1) {
        let next = current.checked_add(1).ok_or(BytecodeError::InvalidModule)?;
        if let (Some(first), Some(second)) = (
            variant.instructions.get(current),
            variant.instructions.get(next),
        ) && is_pure_arithmetic(first.opcode)
            && is_pure_arithmetic(second.opcode)
        {
            let first_pc = u32::try_from(current).map_err(|_| BytecodeError::InvalidModule)?;
            let second_pc = first_pc
                .checked_add(1)
                .ok_or(BytecodeError::InvalidModule)?;
            variant.superinstructions.insert(first_pc, second_pc);
            current = current.saturating_add(2);
            continue;
        }
        current = current.saturating_add(1);
    }
    Ok(())
}

pub(crate) fn is_pure_arithmetic(opcode: Opcode) -> bool {
    matches!(
        opcode.as_name(),
        "int.add"
            | "int.sub"
            | "int.mul"
            | "int.div"
            | "int.mod"
            | "int.pow"
            | "int.neg"
            | "real.add"
            | "real.sub"
            | "real.mul"
            | "real.div"
            | "real.pow"
            | "real.neg"
    )
}
