use crate::{DominatorTree, Function, InstructionId, Operand, Operation};

pub(crate) fn verify(function: &Function, instruction: InstructionId) -> Result<(), &'static str> {
    let Some(operation) = function.columns.operation(instruction) else {
        return Ok(());
    };
    if crate::suspension_points::can_suspend(operation, function.columns.operands(instruction))
        && !function.suspendible
        && function.name != "@main"
    {
        return Err("IR.WELL-FORMEDNESS#R12");
    }
    if operation != Operation::TaskYieldCheck {
        return Ok(());
    }
    verify_backedge(function, instruction)
}

fn verify_backedge(function: &Function, instruction: InstructionId) -> Result<(), &'static str> {
    let dominance = DominatorTree::compute(function);
    let block = function
        .blocks
        .iter()
        .find(|block| block.instructions.contains(&instruction))
        .ok_or("IR.WELL-FORMEDNESS#R12")?;
    let position = block
        .instructions
        .iter()
        .position(|candidate| *candidate == instruction)
        .ok_or("IR.WELL-FORMEDNESS#R12")?;
    let next = block
        .instructions
        .get(position.saturating_add(1))
        .copied()
        .ok_or("IR.WELL-FORMEDNESS#R12")?;
    if function.columns.operation(next) != Some(Operation::Jump) {
        return Err("IR.WELL-FORMEDNESS#R12");
    }
    let [Operand::BlockTarget { target_block, .. }] = function.columns.operands(next) else {
        return Err("IR.WELL-FORMEDNESS#R12");
    };
    if dominance.dominates_block(*target_block, block.identifier) {
        Ok(())
    } else {
        Err("IR.WELL-FORMEDNESS#R12")
    }
}

pub(crate) fn verify_function(function: &Function) -> Result<(), &'static str> {
    for block in &function.blocks {
        for instruction in &block.instructions {
            verify(function, *instruction)?;
        }
    }
    Ok(())
}
