#![forbid(unsafe_code)]

use std::collections::{BTreeMap, BTreeSet};

use pseudolearn_ir::{Function, Operand, Operation, ValueId};

use crate::model::Constant;

pub(super) struct ConstantPlan {
    pub values: BTreeMap<ValueId, Constant>,
    pub register_values: BTreeSet<ValueId>,
}

pub(super) fn analyze(function: &Function) -> ConstantPlan {
    ConstantPlan {
        values: constant_values(function),
        register_values: required_register_values(function),
    }
}

fn constant_values(function: &Function) -> BTreeMap<ValueId, Constant> {
    let mut values = BTreeMap::new();
    for block in &function.blocks {
        for identifier in &block.instructions {
            let Some(operation) = function.columns.operation(*identifier) else {
                continue;
            };
            let Some(result) = function.columns.result(*identifier) else {
                continue;
            };
            let operands = function.columns.operands(*identifier);
            if let Some(constant) = constant_value(operation, operands.first()) {
                values.insert(result, constant);
            }
        }
    }
    values
}

fn required_register_values(function: &Function) -> BTreeSet<ValueId> {
    let mut register_values = BTreeSet::new();
    for block in &function.blocks {
        for identifier in &block.instructions {
            let Some(operation) = function.columns.operation(*identifier) else {
                continue;
            };
            collect_required_registers(
                operation,
                function.columns.operands(*identifier),
                &mut register_values,
            );
        }
    }
    register_values
}

fn collect_required_registers(
    operation: Operation,
    operands: &[Operand],
    register_values: &mut BTreeSet<ValueId>,
) {
    for operand in operands {
        match operand {
            Operand::Value(value) if !supports_immediate(operation) => {
                register_values.insert(*value);
            }
            Operand::BlockTarget { arguments, .. } | Operand::FunctionTarget { arguments, .. } => {
                register_values.extend(arguments.iter().copied());
            }
            _ => {}
        }
    }
}

pub(super) fn supports_immediate(operation: Operation) -> bool {
    operation.as_str().starts_with("int.")
        || operation.as_str().starts_with("real.")
        || operation.as_str().starts_with("bool.")
        || operation.as_str().starts_with("char.")
        || operation.as_str().starts_with("math.")
        || operation == Operation::OutWrite
}

pub(super) fn can_elide(
    result: ValueId,
    values: &BTreeMap<ValueId, Constant>,
    register_values: &BTreeSet<ValueId>,
) -> bool {
    values.contains_key(&result) && !register_values.contains(&result)
}

fn constant_value(operation: Operation, operand: Option<&Operand>) -> Option<Constant> {
    match (operation.as_str(), operand?) {
        ("const.i64", Operand::LiteralI64(value)) => Some(Constant::I64(*value)),
        ("const.f64", Operand::LiteralF64(value)) => Some(Constant::F64(*value)),
        ("const.bool", Operand::LiteralBool(value)) => Some(Constant::Bool(*value)),
        ("const.char", Operand::LiteralChar(value)) => Some(Constant::Char(*value)),
        ("const.str", Operand::LiteralStr(value)) => Some(Constant::Str(value.clone())),
        _ => None,
    }
}
