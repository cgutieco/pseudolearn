#![forbid(unsafe_code)]

use crate::columns::InstructionColumns;
use crate::identities::BlockId;
use crate::model::{Block, Function};
use crate::operand::Operand;
use std::collections::HashMap;

pub struct DominatorTree {
    immediate_dominators: HashMap<BlockId, BlockId>,
    entry_block: Option<BlockId>,
}

struct DominancePass<'context> {
    rpo_blocks: &'context [BlockId],
    entry: Option<BlockId>,
    predecessors: &'context HashMap<BlockId, Vec<BlockId>>,
    rpo_indices: &'context HashMap<BlockId, usize>,
}

impl DominatorTree {
    pub fn compute(function: &Function) -> Self {
        let entry = function.blocks.first().map(|block| block.identifier);
        let predecessors = compute_predecessors(function);
        let (rpo_blocks, rpo_indices) = compute_reverse_post_order(function);

        let mut immediate_dominators: HashMap<BlockId, BlockId> = HashMap::new();
        if let Some(entry_id) = entry {
            immediate_dominators.insert(entry_id, entry_id);
        }

        let pass = DominancePass {
            rpo_blocks: &rpo_blocks,
            entry,
            predecessors: &predecessors,
            rpo_indices: &rpo_indices,
        };

        let mut changed = true;
        while changed {
            changed = refine_dominators(&pass, &mut immediate_dominators);
        }

        Self {
            immediate_dominators,
            entry_block: entry,
        }
    }

    pub fn entry_block(&self) -> Option<BlockId> {
        self.entry_block
    }

    pub fn dominates_block(&self, dominator: BlockId, mut block: BlockId) -> bool {
        if dominator == block {
            return true;
        }
        while let Some(&parent) = self.immediate_dominators.get(&block) {
            if parent == block {
                break;
            }
            if parent == dominator {
                return true;
            }
            block = parent;
        }
        false
    }
}

fn refine_dominators(
    pass: &DominancePass<'_>,
    immediate_dominators: &mut HashMap<BlockId, BlockId>,
) -> bool {
    let mut changed = false;
    for &block_id in pass.rpo_blocks {
        if Some(block_id) == pass.entry {
            continue;
        }
        let empty_predecessors = Vec::new();
        let incoming_predecessors = pass
            .predecessors
            .get(&block_id)
            .unwrap_or(&empty_predecessors);
        let mut processed = incoming_predecessors
            .iter()
            .copied()
            .filter(|pred| immediate_dominators.contains_key(pred));

        let Some(first_predecessor) = processed.next() else {
            continue;
        };
        let mut new_dominator = first_predecessor;
        for other_predecessor in processed {
            new_dominator = intersect(
                other_predecessor,
                new_dominator,
                immediate_dominators,
                pass.rpo_indices,
            );
        }

        if immediate_dominators.get(&block_id) != Some(&new_dominator) {
            immediate_dominators.insert(block_id, new_dominator);
            changed = true;
        }
    }
    changed
}

fn collect_block_successors(block: &Block, columns: &InstructionColumns) -> Vec<BlockId> {
    let mut targets = Vec::new();
    for &instruction_id in &block.instructions {
        for operand in columns.operands(instruction_id) {
            if let Operand::BlockTarget { target_block, .. } = operand {
                targets.push(*target_block);
            }
        }
    }
    targets
}

fn compute_predecessors(function: &Function) -> HashMap<BlockId, Vec<BlockId>> {
    let mut predecessors: HashMap<BlockId, Vec<BlockId>> = HashMap::new();
    for block in &function.blocks {
        predecessors.entry(block.identifier).or_default();
        let targets = collect_block_successors(block, &function.columns);
        for target in targets {
            predecessors
                .entry(target)
                .or_default()
                .push(block.identifier);
        }
    }
    predecessors
}

fn compute_reverse_post_order(function: &Function) -> (Vec<BlockId>, HashMap<BlockId, usize>) {
    let mut visited: HashMap<BlockId, bool> = HashMap::new();
    let mut post_order = Vec::new();
    let successors = compute_successors(function);

    if let Some(entry) = function.blocks.first() {
        dfs_post_order(entry.identifier, &successors, &mut visited, &mut post_order);
    }

    post_order.reverse();
    let mut indices = HashMap::new();
    for (index, &block_id) in post_order.iter().enumerate() {
        indices.insert(block_id, index);
    }
    (post_order, indices)
}

fn dfs_post_order(
    current: BlockId,
    successors: &HashMap<BlockId, Vec<BlockId>>,
    visited: &mut HashMap<BlockId, bool>,
    post_order: &mut Vec<BlockId>,
) {
    visited.insert(current, true);
    let empty_successors = Vec::new();
    for &successor in successors.get(&current).unwrap_or(&empty_successors) {
        if !visited.get(&successor).copied().unwrap_or(false) {
            dfs_post_order(successor, successors, visited, post_order);
        }
    }
    post_order.push(current);
}

fn compute_successors(function: &Function) -> HashMap<BlockId, Vec<BlockId>> {
    let mut successors: HashMap<BlockId, Vec<BlockId>> = HashMap::new();
    for block in &function.blocks {
        successors.insert(
            block.identifier,
            collect_block_successors(block, &function.columns),
        );
    }
    successors
}

fn advance_finger(
    mut finger: BlockId,
    target_index: usize,
    dominators: &HashMap<BlockId, BlockId>,
    rpo_indices: &HashMap<BlockId, usize>,
) -> BlockId {
    while rpo_indices.get(&finger).copied().unwrap_or(usize::MAX) > target_index {
        let parent = match dominators.get(&finger) {
            Some(&parent_block) if parent_block != finger => parent_block,
            _ => break,
        };
        finger = parent;
    }
    finger
}

fn intersect(
    mut finger1: BlockId,
    mut finger2: BlockId,
    dominators: &HashMap<BlockId, BlockId>,
    rpo_indices: &HashMap<BlockId, usize>,
) -> BlockId {
    while finger1 != finger2 {
        let index2 = rpo_indices.get(&finger2).copied().unwrap_or(usize::MAX);
        finger1 = advance_finger(finger1, index2, dominators, rpo_indices);
        let index1 = rpo_indices.get(&finger1).copied().unwrap_or(usize::MAX);
        finger2 = advance_finger(finger2, index1, dominators, rpo_indices);
    }
    finger1
}
