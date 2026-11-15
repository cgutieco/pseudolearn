#![forbid(unsafe_code)]

use crate::block_order::{reverse_postorder, successors};
use pseudolearn_ir::{BlockId, Function};
use std::collections::HashMap;

type Dominators = HashMap<BlockId, BlockId>;
type Positions = HashMap<BlockId, usize>;
type Predecessors = HashMap<BlockId, Vec<BlockId>>;

pub(crate) fn immediate_dominators(function: &Function) -> Dominators {
    let order = reverse_postorder(function);
    let positions: Positions = order
        .iter()
        .enumerate()
        .map(|(position, block)| (*block, position))
        .collect();
    let predecessors = predecessors_of(function, &order);
    let mut dominators = Dominators::new();
    if let Some(entry) = order.first() {
        dominators.insert(*entry, *entry);
    }
    let mut changed = true;
    while changed {
        changed = false;
        for block in order.iter().skip(1) {
            let candidate = refine(predecessors.get(block), &dominators, &positions);
            if let Some(candidate) = candidate
                && dominators.get(block) != Some(&candidate)
            {
                dominators.insert(*block, candidate);
                changed = true;
            }
        }
    }
    dominators
}

fn predecessors_of(function: &Function, order: &[BlockId]) -> Predecessors {
    let mut predecessors = Predecessors::new();
    for block in order {
        for target in successors(function, *block) {
            predecessors.entry(target).or_default().push(*block);
        }
    }
    predecessors
}

fn refine(
    candidates: Option<&Vec<BlockId>>,
    dominators: &Dominators,
    positions: &Positions,
) -> Option<BlockId> {
    let mut chosen: Option<BlockId> = None;
    for predecessor in candidates?
        .iter()
        .filter(|block| dominators.contains_key(block))
    {
        chosen = match chosen {
            None => Some(*predecessor),
            Some(current) => intersect(current, *predecessor, dominators, positions),
        };
        chosen?;
    }
    chosen
}

fn intersect(
    first: BlockId,
    second: BlockId,
    dominators: &Dominators,
    positions: &Positions,
) -> Option<BlockId> {
    let (mut left, mut right) = (first, second);
    for _ in 0..positions.len().saturating_mul(2).saturating_add(1) {
        if left == right {
            return Some(left);
        }
        if positions.get(&left)? > positions.get(&right)? {
            left = *dominators.get(&left)?;
        } else {
            right = *dominators.get(&right)?;
        }
    }
    None
}
