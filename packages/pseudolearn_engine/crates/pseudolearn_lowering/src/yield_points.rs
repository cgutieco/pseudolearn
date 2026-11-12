use pseudolearn_ir::columns::{InstructionDefinition, replace_operands};
use pseudolearn_ir::dominance::DominatorTree;
use pseudolearn_ir::{Block, BlockId, Function, Operand, Operation};

pub(crate) fn insert(function: &mut Function) {
    if !function.suspendible {
        return;
    }
    let dominance = DominatorTree::compute(function);
    let original = function.blocks.clone();
    let mut next = original
        .iter()
        .map(|block| block.identifier.0)
        .max()
        .unwrap_or(0);
    for block in original {
        rewrite(function, &dominance, (block, &mut next));
    }
}

fn append_bridge(
    function: &mut Function,
    identifier: BlockId,
    target: Operand,
    span: Option<pseudolearn_ir::IrSpan>,
) {
    let yielded = function.columns.push_instruction(
        InstructionDefinition {
            operation: Operation::TaskYieldCheck,
            result: None,
            span,
        },
        &[],
    );
    let jump = function.columns.push_instruction(
        InstructionDefinition {
            operation: Operation::Jump,
            result: None,
            span,
        },
        &[target],
    );
    function.blocks.push(Block {
        identifier,
        parameters: Vec::new(),
        mass: 0,
        instructions: vec![yielded, jump],
    });
}

fn rewrite(function: &mut Function, dominance: &DominatorTree, state: (Block, &mut u32)) {
    let (block, next) = state;
    let Some(terminator) = block.instructions.last().copied() else {
        return;
    };
    let mut operands = function.columns.operands(terminator).to_vec();
    for operand in &mut operands {
        let Operand::BlockTarget {
            target_block,
            arguments,
        } = operand
        else {
            continue;
        };
        if !dominance.dominates_block(*target_block, block.identifier) {
            continue;
        }
        *next = next.saturating_add(1);
        let bridge = BlockId(*next);
        let target = Operand::BlockTarget {
            target_block: *target_block,
            arguments: arguments.clone(),
        };
        append_bridge(
            function,
            bridge,
            target,
            function
                .columns
                .span(terminator)
                .or(function.declaration_span),
        );
        *target_block = bridge;
        arguments.clear();
    }
    replace_operands(&mut function.columns, terminator, &operands);
}
