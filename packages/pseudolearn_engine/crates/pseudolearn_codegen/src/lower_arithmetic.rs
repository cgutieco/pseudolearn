#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::constant_folding::{Folded, fold_checked};
use crate::error::CodegenError;
use crate::lower_scalars::{predicate_of, signed_condition};
use crate::lowering::{Instruction, Lowering, bind_result, guard_trap, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::Operation;

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::IntAdd,
    Operation::IntSub,
    Operation::IntMul,
    Operation::IntNeg,
    Operation::IntDiv,
    Operation::IntMod,
    Operation::IntPow,
    Operation::IntCmp,
    Operation::IntToReal,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::IntAdd | Operation::IntSub | Operation::IntMul | Operation::IntNeg => {
            lower_checked(lowering, instruction)
        }
        Operation::IntDiv => lower_division(lowering, instruction),
        Operation::IntMod => lower_modulo(lowering, instruction),
        Operation::IntPow => lower_power(lowering, instruction),
        Operation::IntCmp => lower_comparison(lowering, instruction),
        _ => lower_widening(lowering, instruction),
    }
}

fn lower_checked(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let left = operand_value(lowering, instruction, 0)?;
    let right = match instruction.operation {
        Operation::IntNeg => None,
        _ => Some(operand_value(lowering, instruction, 1)?),
    };
    if let Some(value) = folded_value(lowering, instruction.operation, left, right) {
        bind_result(lowering, instruction, value);
        return Ok(());
    }
    if let Some((result, overflow)) =
        crate::constant_overflow::specialize(lowering, instruction.operation, left, right)
    {
        guard_trap(lowering, overflow, "integerOverflow", instruction.span)?;
        bind_result(lowering, instruction, result);
        return Ok(());
    }
    let (result, overflow) = if instruction.operation == Operation::IntNeg {
        let zero = lowering.builder.ins().iconst(types::I64, 0);
        lowering.builder.ins().ssub_overflow(zero, left)
    } else {
        let right = right.ok_or(CodegenError::InvalidModule("operand is not a value"))?;
        match instruction.operation {
            Operation::IntAdd => lowering.builder.ins().sadd_overflow(left, right),
            Operation::IntSub => lowering.builder.ins().ssub_overflow(left, right),
            _ => lowering.builder.ins().smul_overflow(left, right),
        }
    };
    guard_trap(lowering, overflow, "integerOverflow", instruction.span)?;
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_division(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let dividend = operand_value(lowering, instruction, 0)?;
    let divisor = operand_value(lowering, instruction, 1)?;
    let zero = lowering.builder.ins().icmp_imm_s(IntCC::Equal, divisor, 0);
    guard_trap(lowering, zero, "divisionByZero", instruction.span)?;
    let is_minimum = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::Equal, dividend, i64::MIN);
    let is_negative_one = lowering.builder.ins().icmp_imm_s(IntCC::Equal, divisor, -1);
    let overflow = lowering.builder.ins().band(is_minimum, is_negative_one);
    guard_trap(lowering, overflow, "integerOverflow", instruction.span)?;
    let quotient = lowering.builder.ins().sdiv(dividend, divisor);
    bind_result(lowering, instruction, quotient);
    Ok(())
}

fn lower_modulo(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let dividend = operand_value(lowering, instruction, 0)?;
    let divisor = operand_value(lowering, instruction, 1)?;
    let zero = lowering.builder.ins().icmp_imm_s(IntCC::Equal, divisor, 0);
    guard_trap(lowering, zero, "divisionByZero", instruction.span)?;
    let is_negative_one = lowering.builder.ins().icmp_imm_s(IntCC::Equal, divisor, -1);
    let one = lowering.builder.ins().iconst(types::I64, 1);
    let safe_divisor = lowering.builder.ins().select(is_negative_one, one, divisor);
    let remainder = lowering.builder.ins().srem(dividend, safe_divisor);
    bind_result(lowering, instruction, remainder);
    Ok(())
}

fn lower_power(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let base = operand_value(lowering, instruction, 0)?;
    let exponent = operand_value(lowering, instruction, 1)?;
    let operands: [Value; 2] = [base, exponent];
    let call = RuntimeCall {
        target: Entry::IntegerPower,
        code_name: "integerOverflow",
        span: instruction.span,
        operands: &operands,
    };
    let result = call_runtime(lowering, &call)?;
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_comparison(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let predicate = predicate_of(instruction)?;
    let left = operand_value(lowering, instruction, 1)?;
    let right = operand_value(lowering, instruction, 2)?;
    let result = lowering
        .builder
        .ins()
        .icmp(signed_condition(predicate), left, right);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_widening(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let result = lowering.builder.ins().fcvt_from_sint(types::F64, operand);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn folded_value(
    lowering: &mut Lowering<'_, '_>,
    operation: Operation,
    left: Value,
    right: Option<Value>,
) -> Option<Value> {
    match fold_checked(lowering, operation, left, right)? {
        Folded::Constant(number) => Some(lowering.builder.ins().iconst(types::I64, number)),
        Folded::Passthrough(value) => Some(value),
    }
}
