#![forbid(unsafe_code)]

use pseudolearn_ir::{Function, Operand, Operation, ValueId};
use std::collections::HashSet;

pub(crate) fn collect(function: &Function) -> HashSet<ValueId> {
    let mut defined = HashSet::new();
    loop {
        let previous = defined.len();
        for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
            let operation = function.columns.operation(*instruction);
            let proven = operation.is_some_and(produces_defined)
                || operation == Some(Operation::ConstF64)
                    && matches!(function.columns.operands(*instruction), [Operand::LiteralF64(number)] if !number.is_nan())
                || operation == Some(Operation::ValueRequire)
                    && matches!(function.columns.operands(*instruction).first(),
                        Some(Operand::Value(value)) if defined.contains(value));
            if proven && let Some(result) = function.columns.result(*instruction) {
                defined.insert(result);
            }
        }
        if defined.len() == previous {
            return defined;
        }
    }
}

fn produces_defined(operation: Operation) -> bool {
    matches!(
        operation,
        Operation::ConstI64
            | Operation::ConstBool
            | Operation::ConstChar
            | Operation::ConstStr
            | Operation::IntToReal
            | Operation::RealAdd
            | Operation::RealSub
            | Operation::RealMul
            | Operation::RealDiv
            | Operation::IntCmp
            | Operation::RealCmp
            | Operation::BoolCmp
            | Operation::CharCmp
            | Operation::RefCmp
            | Operation::ArrayNew
            | Operation::ObjectNew
            | Operation::ObjectCopy
    )
}

#[cfg(test)]
#[path = "defined_producers_tests.rs"]
mod defined_producers_tests;
