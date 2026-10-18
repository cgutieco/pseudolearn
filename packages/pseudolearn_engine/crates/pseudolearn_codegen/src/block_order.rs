#![forbid(unsafe_code)]

use pseudolearn_ir::{BlockId, Function, Operand};
use std::collections::HashSet;

pub(crate) fn reverse_postorder(function: &Function) -> Vec<BlockId> {
    let Some(entry) = function.blocks.first() else {
        return Vec::new();
    };
    let mut visited = HashSet::from([entry.identifier]);
    let mut order = Vec::new();
    let mut stack = vec![(entry.identifier, successors(function, entry.identifier))];
    while let Some(top) = stack.last_mut() {
        let current = top.0;
        match top.1.pop() {
            Some(next) if visited.insert(next) => stack.push((next, successors(function, next))),
            Some(_) => {}
            None => {
                order.push(current);
                stack.pop();
            }
        }
    }
    order.reverse();
    order
}

fn successors(function: &Function, identifier: BlockId) -> Vec<BlockId> {
    let Some(last) = function
        .block(identifier)
        .and_then(|block| block.instructions.last())
    else {
        return Vec::new();
    };
    let mut targets: Vec<BlockId> = function
        .columns
        .operands(*last)
        .iter()
        .filter_map(|operand| match operand {
            Operand::BlockTarget { target_block, .. } => Some(*target_block),
            _ => None,
        })
        .collect();
    targets.reverse();
    targets
}
