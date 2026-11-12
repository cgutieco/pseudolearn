#![forbid(unsafe_code)]

use pseudolearn_ir::{Function, IrType, Operand, Operation, ValueId};
use std::collections::{HashMap, HashSet};

pub(crate) fn collect(function: &Function, types: &HashMap<ValueId, IrType>) -> HashSet<ValueId> {
    let mut borrowed: HashSet<_> = function
        .parameters
        .iter()
        .filter(|(_, kind)| crate::type_mapping::is_heap_reference(kind))
        .map(|(value, _)| *value)
        .collect();
    loop {
        let previous = borrowed.len();
        for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
            if function.columns.operation(*instruction) != Some(Operation::ValueRequire) {
                continue;
            }
            let Some(Operand::Value(source)) = function.columns.operands(*instruction).first()
            else {
                continue;
            };
            if borrowed.contains(source)
                && let Some(result) = function.columns.result(*instruction)
            {
                borrowed.insert(result);
            }
        }
        if previous == borrowed.len() {
            break;
        }
    }
    borrowed.retain(|value| {
        types
            .get(value)
            .is_some_and(crate::type_mapping::is_heap_reference)
    });
    borrowed
}

#[cfg(test)]
#[path = "borrowed_roots_tests.rs"]
mod borrowed_roots_tests;
