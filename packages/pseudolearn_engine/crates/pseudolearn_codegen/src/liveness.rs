#![forbid(unsafe_code)]

use crate::type_mapping::is_heap_reference;
use pseudolearn_ir::{
    Block, BlockId, Function, InstructionId, IrType, Operand, Operation, ValueId,
};
use std::collections::{BTreeSet, HashMap};

type LiveSet = BTreeSet<ValueId>;
type Types = HashMap<ValueId, IrType>;

pub(crate) const SAFE_POINTS: &[Operation] = &[
    Operation::Call,
    Operation::CallVirtual,
    Operation::ArrayNew,
    Operation::ObjectNew,
    Operation::ObjectCopy,
    Operation::TextConcat,
    Operation::TextFormat,
    Operation::InRead,
    Operation::ConstStr,
];

struct Analysis<'program> {
    function: &'program Function,
    types: &'program Types,
}

pub(crate) fn live_roots(
    function: &Function,
    types: &Types,
    policy: crate::target::ParameterRoots,
) -> HashMap<InstructionId, Vec<ValueId>> {
    let analysis = Analysis { function, types };
    let live_in = fixpoint(&analysis);
    let mut recorded = HashMap::new();
    for block in &function.blocks {
        let outgoing = outgoing(&analysis, block, &live_in);
        scan(&analysis, block, outgoing, Some(&mut recorded));
    }
    if policy == crate::target::ParameterRoots::Borrowed {
        let borrowed = crate::borrowed_roots::collect(function, types);
        for roots in recorded.values_mut() {
            roots.retain(|value| !borrowed.contains(value));
        }
    }
    recorded
}

fn fixpoint(analysis: &Analysis<'_>) -> HashMap<BlockId, LiveSet> {
    let mut live_in: HashMap<BlockId, LiveSet> = HashMap::new();
    let mut changed = true;
    while changed {
        changed = false;
        for block in analysis.function.blocks.iter().rev() {
            let outgoing = outgoing(analysis, block, &live_in);
            let incoming = scan(analysis, block, outgoing, None);
            if live_in.get(&block.identifier) != Some(&incoming) {
                live_in.insert(block.identifier, incoming);
                changed = true;
            }
        }
    }
    live_in
}

fn outgoing(
    analysis: &Analysis<'_>,
    block: &Block,
    live_in: &HashMap<BlockId, LiveSet>,
) -> LiveSet {
    let mut outgoing = LiveSet::new();
    let columns = &analysis.function.columns;
    for instruction in &block.instructions {
        for operand in columns.operands(*instruction) {
            if let Operand::BlockTarget {
                target_block,
                arguments,
            } = operand
            {
                outgoing.extend(edge(analysis, (*target_block, arguments), live_in));
            }
        }
    }
    outgoing
}

fn edge(
    analysis: &Analysis<'_>,
    (target, arguments): (BlockId, &[ValueId]),
    live_in: &HashMap<BlockId, LiveSet>,
) -> LiveSet {
    let Some(block) = analysis.function.block(target) else {
        return LiveSet::new();
    };
    let mut live = live_in.get(&target).cloned().unwrap_or_default();
    let mut carried = LiveSet::new();
    for ((parameter, _), source) in block.parameters.iter().zip(arguments) {
        if live.remove(parameter) && heap_value(analysis, *source) {
            carried.insert(*source);
        }
    }
    live.extend(carried);
    live
}

fn heap_value(analysis: &Analysis<'_>, value: ValueId) -> bool {
    analysis.types.get(&value).is_some_and(is_heap_reference)
}

fn scan(
    analysis: &Analysis<'_>,
    block: &Block,
    mut live: LiveSet,
    mut recorded: Option<&mut HashMap<InstructionId, Vec<ValueId>>>,
) -> LiveSet {
    let columns = &analysis.function.columns;
    for instruction in block.instructions.iter().rev() {
        if let Some(result) = columns.result(*instruction) {
            live.remove(&result);
        }
        for operand in columns.operands(*instruction) {
            live.extend(
                uses(operand)
                    .into_iter()
                    .filter(|value| heap_value(analysis, *value)),
            );
        }
        let safe = columns
            .operation(*instruction)
            .is_some_and(|operation| SAFE_POINTS.contains(&operation));
        if let (true, Some(map)) = (safe, recorded.as_deref_mut()) {
            map.insert(*instruction, live.iter().copied().collect());
        }
    }
    live
}

fn uses(operand: &Operand) -> Vec<ValueId> {
    match operand {
        Operand::Value(value) => vec![*value],
        Operand::FunctionTarget { arguments, .. } => arguments.clone(),
        _ => Vec::new(),
    }
}
