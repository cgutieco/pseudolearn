#![forbid(unsafe_code)]

use crate::block_order::reverse_postorder;
use pseudolearn_ir::type_checker::check_instruction_types;
use pseudolearn_ir::{Function, IrType, Module, ValueId};
use std::collections::HashMap;

pub(crate) fn infer(module: &Module, function: &Function) -> HashMap<ValueId, IrType> {
    let mut types: HashMap<ValueId, IrType> = function.parameters.iter().cloned().collect();
    for block in &function.blocks {
        types.extend(block.parameters.iter().cloned());
    }
    for identifier in reverse_postorder(function) {
        let Some(block) = function.block(identifier) else {
            continue;
        };
        for instruction in &block.instructions {
            let columns = &function.columns;
            let (Some(operation), Some(result)) = (
                columns.operation(*instruction),
                columns.result(*instruction),
            ) else {
                continue;
            };
            let operands = columns.operands(*instruction);
            let lookup = |value: ValueId| types.get(&value).cloned();
            if let Ok(Some(result_type)) =
                check_instruction_types(operation, operands, lookup, module)
            {
                types.insert(result, result_type);
            }
        }
    }
    types
}
