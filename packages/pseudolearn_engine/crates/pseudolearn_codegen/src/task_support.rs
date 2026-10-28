use crate::instruction_dispatch::UNSUPPORTED_OPERATIONS;
use pseudolearn_ir::{Function, Module};

pub fn module_uses_tasks(module: &Module) -> bool {
    module.functions.iter().any(function_uses_tasks)
}

fn function_uses_tasks(function: &Function) -> bool {
    function
        .blocks
        .iter()
        .flat_map(|block| block.instructions.iter())
        .filter_map(|instruction| function.columns.operation(*instruction))
        .any(|operation| UNSUPPORTED_OPERATIONS.contains(&operation))
}
