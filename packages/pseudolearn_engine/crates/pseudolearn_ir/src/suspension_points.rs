use crate::{Function, InstructionId, Operand, Operation};

pub fn can_suspend(operation: Operation, operands: &[Operand]) -> bool {
    match operation {
        Operation::TaskAwait | Operation::TaskScopeJoin | Operation::CallSuspendible
        | Operation::EffectAwait | Operation::TaskYieldCheck => true,
        Operation::TaskChannel => operands.iter().any(|operand| matches!(operand,
            Operand::Identifier(command) if matches!(command.as_str(), "send" | "receive" | "select"))),
        _ => false,
    }
}

pub fn points(function: &Function) -> Vec<InstructionId> {
    function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .copied()
        .filter(|instruction| {
            function
                .columns
                .operation(*instruction)
                .is_some_and(|operation| {
                    can_suspend(operation, function.columns.operands(*instruction))
                })
        })
        .collect()
}
