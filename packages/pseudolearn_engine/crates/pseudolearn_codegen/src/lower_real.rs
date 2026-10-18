#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lower_scalars::{float_condition, predicate_of};
use crate::lowering::{Instruction, Lowering, bind_result, guard_trap, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use cranelift_codegen::ir::condcodes::FloatCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{MATH_ROUND, MATH_TRUNCATE};
use pseudolearn_ir::Operation;

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::RealAdd,
    Operation::RealSub,
    Operation::RealMul,
    Operation::RealDiv,
    Operation::RealNeg,
    Operation::RealPow,
    Operation::RealCmp,
    Operation::RealTrunc,
    Operation::RealRound,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::RealAdd | Operation::RealSub | Operation::RealMul => {
            lower_checked(lowering, instruction)
        }
        Operation::RealDiv => lower_division(lowering, instruction),
        Operation::RealNeg => {
            let operand = operand_value(lowering, instruction, 0)?;
            let result = lowering.builder.ins().fneg(operand);
            bind_result(lowering, instruction, result);
            Ok(())
        }
        Operation::RealPow => lower_power(lowering, instruction),
        Operation::RealCmp => lower_comparison(lowering, instruction),
        _ => lower_rounding(lowering, instruction),
    }
}

fn require_finite(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    result: Value,
) -> Result<(), CodegenError> {
    let magnitude = lowering.builder.ins().fabs(result);
    let infinity = lowering.builder.ins().f64const(f64::INFINITY);
    let finite = lowering
        .builder
        .ins()
        .fcmp(FloatCC::LessThan, magnitude, infinity);
    let non_finite = lowering.builder.ins().bxor_imm_u(finite, 1);
    guard_trap(
        lowering,
        non_finite,
        "nonFiniteRealResult",
        instruction.span,
    )
}

fn lower_checked(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let left = operand_value(lowering, instruction, 0)?;
    let right = operand_value(lowering, instruction, 1)?;
    let result = match instruction.operation {
        Operation::RealAdd => lowering.builder.ins().fadd(left, right),
        Operation::RealSub => lowering.builder.ins().fsub(left, right),
        _ => lowering.builder.ins().fmul(left, right),
    };
    require_finite(lowering, instruction, result)?;
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_division(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let left = operand_value(lowering, instruction, 0)?;
    let right = operand_value(lowering, instruction, 1)?;
    let zero = lowering.builder.ins().f64const(0.0);
    let is_zero = lowering.builder.ins().fcmp(FloatCC::Equal, right, zero);
    guard_trap(lowering, is_zero, "divisionByZero", instruction.span)?;
    let result = lowering.builder.ins().fdiv(left, right);
    require_finite(lowering, instruction, result)?;
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
        .fcmp(float_condition(predicate), left, right);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_power(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let base = operand_value(lowering, instruction, 0)?;
    let exponent = operand_value(lowering, instruction, 1)?;
    let base_bits = lowering
        .builder
        .ins()
        .bitcast(types::I64, MemFlagsData::new(), base);
    let exponent_bits = lowering
        .builder
        .ins()
        .bitcast(types::I64, MemFlagsData::new(), exponent);
    let operands = [base_bits, exponent_bits];
    let call = RuntimeCall {
        target: lowering.environment.runtime.real_power,
        code_name: "nonFiniteRealResult",
        span: instruction.span,
        operands: &operands,
    };
    let bits = call_runtime(lowering, &call)?;
    let result = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), bits);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_rounding(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let bits = lowering
        .builder
        .ins()
        .bitcast(types::I64, MemFlagsData::new(), operand);
    let selector = if instruction.operation == Operation::RealTrunc {
        MATH_TRUNCATE
    } else {
        MATH_ROUND
    };
    let selector_value = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(selector));
    let operands = [selector_value, bits];
    let call = RuntimeCall {
        target: lowering.environment.runtime.math_unary,
        code_name: "integerOverflow",
        span: instruction.span,
        operands: &operands,
    };
    let result = call_runtime(lowering, &call)?;
    bind_result(lowering, instruction, result);
    Ok(())
}
