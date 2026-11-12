use pseudolearn_ir::columns::InstructionDefinition;
use pseudolearn_ir::{Block, BlockId, Function, InstructionId, Operand, Operation};
use std::collections::BTreeSet;

pub(crate) fn partition(function: &mut Function) {
    if !function.suspendible {
        return;
    }
    let mut next = function
        .blocks
        .iter()
        .map(|block| block.identifier.0)
        .max()
        .unwrap_or(0);
    let original = std::mem::take(&mut function.blocks);
    for block in original {
        let cuts = cuts(function, &block);
        let mut current = Block {
            instructions: Vec::new(),
            mass: 0,
            ..block.clone()
        };
        for instruction in block.instructions {
            current.instructions.push(instruction);
            if function.columns.operation(instruction) == Some(Operation::StmtEnter) {
                current.mass = current.mass.saturating_add(1);
            }
            if !cuts.contains(&instruction) {
                continue;
            }
            next = next.saturating_add(1);
            let identifier = BlockId(next);
            append_jump(function, &mut current, identifier, instruction);
            function.blocks.push(current);
            current = Block {
                identifier,
                parameters: Vec::new(),
                mass: 0,
                instructions: Vec::new(),
            };
        }
        function.blocks.push(current);
    }
}

fn cuts(function: &Function, block: &Block) -> BTreeSet<InstructionId> {
    let mut later_statement = false;
    let mut cuts = BTreeSet::new();
    for instruction in block.instructions.iter().rev().copied() {
        let Some(operation) = function.columns.operation(instruction) else {
            continue;
        };
        if later_statement
            && pseudolearn_ir::suspension_points::can_suspend(
                operation,
                function.columns.operands(instruction),
            )
        {
            cuts.insert(instruction);
        }
        later_statement |= operation == Operation::StmtEnter;
    }
    cuts
}

fn append_jump(function: &mut Function, block: &mut Block, target: BlockId, source: InstructionId) {
    let instruction = function.columns.push_instruction(
        InstructionDefinition {
            operation: Operation::Jump,
            result: None,
            span: function.columns.span(source).or(function.declaration_span),
        },
        &[Operand::BlockTarget {
            target_block: target,
            arguments: Vec::new(),
        }],
    );
    block.instructions.push(instruction);
}
