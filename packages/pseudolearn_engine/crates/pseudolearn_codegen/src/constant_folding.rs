#![forbid(unsafe_code)]

use crate::lowering::Lowering;
use cranelift_codegen::ir::{InstructionData, Opcode, Value, ValueDef};
use pseudolearn_ir::Operation;

pub(crate) enum Folded {
    Constant(i64),
    Passthrough(Value),
}

pub(crate) fn known_integer(lowering: &Lowering<'_, '_>, value: Value) -> Option<i64> {
    let dfg = &lowering.builder.func.dfg;
    let ValueDef::Result(instruction, _) = dfg.value_def(value) else {
        return None;
    };
    match dfg.insts[instruction] {
        InstructionData::UnaryImm {
            opcode: Opcode::Iconst,
            imm,
        } => Some(imm.bits()),
        _ => None,
    }
}

#[derive(Clone, Copy)]
struct Known {
    value: Value,
    number: Option<i64>,
}

pub(crate) fn fold_checked(
    lowering: &Lowering<'_, '_>,
    operation: Operation,
    left: Value,
    right: Option<Value>,
) -> Option<Folded> {
    let describe = |value: Value| Known {
        value,
        number: known_integer(lowering, value),
    };
    let left = describe(left);
    let right = right.map(describe);
    if let (Some(left_number), Some(right_number)) =
        (left.number, right.and_then(|known| known.number))
    {
        return fold_constants(operation, left_number, right_number).map(Folded::Constant);
    }
    if operation == Operation::IntNeg {
        return left.number.and_then(i64::checked_neg).map(Folded::Constant);
    }
    identity_operand(operation, left, right?)
}

fn fold_constants(operation: Operation, left: i64, right: i64) -> Option<i64> {
    match operation {
        Operation::IntAdd => left.checked_add(right),
        Operation::IntSub => left.checked_sub(right),
        Operation::IntMul => left.checked_mul(right),
        _ => None,
    }
}

fn identity_operand(operation: Operation, left: Known, right: Known) -> Option<Folded> {
    match operation {
        Operation::IntAdd if right.number == Some(0) => Some(Folded::Passthrough(left.value)),
        Operation::IntAdd if left.number == Some(0) => Some(Folded::Passthrough(right.value)),
        Operation::IntSub if right.number == Some(0) => Some(Folded::Passthrough(left.value)),
        Operation::IntMul if right.number == Some(1) => Some(Folded::Passthrough(left.value)),
        Operation::IntMul if left.number == Some(1) => Some(Folded::Passthrough(right.value)),
        _ => None,
    }
}
