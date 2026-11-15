#![forbid(unsafe_code)]

use crate::constant_folding::known_integer;
use crate::lowering::Lowering;
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, Value};
use pseudolearn_ir::Operation;

pub(crate) fn specialize(
    lowering: &mut Lowering<'_, '_>,
    operation: Operation,
    left: Value,
    right: Option<Value>,
) -> Option<(Value, Value)> {
    let right = right?;
    match operation {
        Operation::IntAdd => {
            let (variable, constant) = constant_operand(lowering, left, right)?;
            let result = lowering.builder.ins().iadd(left, right);
            Some((result, addition_guard(lowering, variable, constant)))
        }
        Operation::IntSub => subtraction(lowering, left, right),
        _ => None,
    }
}

fn constant_operand(
    lowering: &Lowering<'_, '_>,
    left: Value,
    right: Value,
) -> Option<(Value, i64)> {
    known_integer(lowering, right)
        .map(|constant| (left, constant))
        .or_else(|| known_integer(lowering, left).map(|constant| (right, constant)))
}

fn addition_guard(lowering: &mut Lowering<'_, '_>, variable: Value, constant: i64) -> Value {
    let (condition, boundary) = if constant >= 0 {
        (IntCC::SignedGreaterThan, i64::MAX.saturating_sub(constant))
    } else {
        (IntCC::SignedLessThan, i64::MIN.saturating_sub(constant))
    };
    lowering
        .builder
        .ins()
        .icmp_imm_s(condition, variable, boundary)
}

fn subtraction(
    lowering: &mut Lowering<'_, '_>,
    left: Value,
    right: Value,
) -> Option<(Value, Value)> {
    let (variable, condition, boundary) = if let Some(constant) = known_integer(lowering, right) {
        if constant >= 0 {
            (left, IntCC::SignedLessThan, i64::MIN.checked_add(constant)?)
        } else {
            (
                left,
                IntCC::SignedGreaterThan,
                i64::MAX.checked_add(constant)?,
            )
        }
    } else {
        let constant = known_integer(lowering, left)?;
        if constant >= 0 {
            (
                right,
                IntCC::SignedLessThan,
                constant.checked_sub(i64::MAX)?,
            )
        } else {
            (
                right,
                IntCC::SignedGreaterThan,
                constant.checked_sub(i64::MIN)?,
            )
        }
    };
    let result = lowering.builder.ins().isub(left, right);
    let overflow = lowering
        .builder
        .ins()
        .icmp_imm_s(condition, variable, boundary);
    Some((result, overflow))
}
