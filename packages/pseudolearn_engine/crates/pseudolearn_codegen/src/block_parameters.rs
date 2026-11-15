#![forbid(unsafe_code)]

use cranelift_codegen::ir::{Block, BlockArg, Function, Value};
use std::collections::HashSet;

pub(crate) fn eliminate(function: &mut Function) {
    let mut live = direct_uses(function);
    loop {
        let previous = live.len();
        extend_edges(function, &mut live);
        if previous == live.len() {
            break;
        }
    }
    let entry = function.layout.entry_block();
    let blocks: Vec<_> = function
        .layout
        .blocks()
        .filter(|block| Some(*block) != entry)
        .collect();
    for block in blocks {
        let removed: Vec<_> = function
            .dfg
            .block_params(block)
            .iter()
            .enumerate()
            .filter(|(_, value)| !live.contains(&function.dfg.resolve_aliases(**value)))
            .map(|(position, value)| (position, *value))
            .collect();
        for (position, value) in removed.into_iter().rev() {
            remove_arguments(function, block, position);
            function.dfg.remove_block_param(value);
        }
    }
}

fn direct_uses(function: &Function) -> HashSet<Value> {
    function
        .layout
        .blocks()
        .flat_map(|block| function.layout.block_insts(block))
        .flat_map(|instruction| function.dfg.inst_args(instruction))
        .map(|value| function.dfg.resolve_aliases(*value))
        .collect()
}

fn extend_edges(function: &Function, live: &mut HashSet<Value>) {
    for block in function.layout.blocks() {
        for instruction in function.layout.block_insts(block) {
            for edge in function.dfg.insts[instruction]
                .branch_destination(&function.dfg.jump_tables, &function.dfg.exception_tables)
            {
                extend_edge(function, edge, live);
            }
        }
    }
}

fn extend_edge(
    function: &Function,
    edge: &cranelift_codegen::ir::BlockCall,
    live: &mut HashSet<Value>,
) {
    let destination = edge.block(&function.dfg.value_lists);
    for (parameter, argument) in function
        .dfg
        .block_params(destination)
        .iter()
        .zip(edge.args(&function.dfg.value_lists))
    {
        if live.contains(&function.dfg.resolve_aliases(*parameter))
            && let BlockArg::Value(argument) = argument
        {
            live.insert(function.dfg.resolve_aliases(argument));
        }
    }
}

fn remove_arguments(function: &mut Function, destination: Block, position: usize) {
    let instructions: Vec<_> = function
        .layout
        .blocks()
        .flat_map(|block| function.layout.block_insts(block))
        .collect();
    let graph = &mut function.dfg;
    for instruction in instructions {
        for edge in graph.insts[instruction]
            .branch_destination_mut(&mut graph.jump_tables, &mut graph.exception_tables)
        {
            if edge.block(&graph.value_lists) == destination {
                edge.remove(position, &mut graph.value_lists);
            }
        }
    }
}

#[cfg(test)]
#[path = "block_parameters_tests.rs"]
mod block_parameters_tests;
