#![forbid(unsafe_code)]

use crate::error::{BytecodeError, VerificationRule};
use crate::model::{CodeVariant, Instruction};

pub(super) fn verify_superinstructions(variant: &CodeVariant) -> Result<(), BytecodeError> {
    let mut branch_targets = std::collections::BTreeSet::new();
    for (compare_pc, branch_pc) in &variant.superinstructions {
        if !branch_targets.insert(*branch_pc)
            || verify_superinstruction(variant, *compare_pc, *branch_pc).is_err()
        {
            return Err(BytecodeError::Verification(
                VerificationRule::SuperInstruction,
            ));
        }
    }
    Ok(())
}

fn verify_superinstruction(
    variant: &CodeVariant,
    compare_pc: u32,
    branch_pc: u32,
) -> Result<(), BytecodeError> {
    let expected_branch_pc = compare_pc
        .checked_add(1)
        .ok_or(BytecodeError::InvalidModule)?;
    let compare = instruction_at(variant, compare_pc)?;
    let branch = instruction_at(variant, branch_pc)?;
    let same_block = variant.blocks.iter().any(|block| {
        block.start_pc <= compare_pc
            && !variant
                .blocks
                .iter()
                .any(|candidate| compare_pc < candidate.start_pc && candidate.start_pc <= branch_pc)
    });
    if branch_pc == expected_branch_pc
        && matches!(compare.opcode.as_name(), "int.cmp" | "real.cmp")
        && branch.opcode.as_name() == "branch"
        && same_block
    {
        Ok(())
    } else {
        Err(BytecodeError::InvalidModule)
    }
}

fn instruction_at(
    variant: &CodeVariant,
    program_counter: u32,
) -> Result<&Instruction, BytecodeError> {
    let position = usize::try_from(program_counter).map_err(|_| BytecodeError::InvalidModule)?;
    variant
        .instructions
        .get(position)
        .ok_or(BytecodeError::InvalidModule)
}
