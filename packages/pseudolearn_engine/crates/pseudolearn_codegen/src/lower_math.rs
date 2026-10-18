#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, guard_trap, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use cranelift_codegen::ir::condcodes::FloatCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, types};
use pseudolearn_aot_rt::{
    MATH_ARCTANGENT, MATH_COSINE, MATH_EXPONENTIAL, MATH_LOGARITHM, MATH_SINE,
};
use pseudolearn_ir::Operation;

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::MathSqrt,
    Operation::MathAbs,
    Operation::MathLn,
    Operation::MathExp,
    Operation::MathSin,
    Operation::MathCos,
    Operation::MathAtan,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let selector = match instruction.operation {
        Operation::MathSqrt => return lower_square_root(lowering, instruction),
        Operation::MathAbs => return lower_absolute(lowering, instruction),
        Operation::MathLn => MATH_LOGARITHM,
        Operation::MathExp => MATH_EXPONENTIAL,
        Operation::MathSin => MATH_SINE,
        Operation::MathCos => MATH_COSINE,
        _ => MATH_ARCTANGENT,
    };
    lower_library(lowering, instruction, selector)
}

fn lower_square_root(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let zero = lowering.builder.ins().f64const(0.0);
    let negative = lowering
        .builder
        .ins()
        .fcmp(FloatCC::LessThan, operand, zero);
    guard_trap(lowering, negative, "nonFiniteRealResult", instruction.span)?;
    let result = lowering.builder.ins().sqrt(operand);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_absolute(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let result = lowering.builder.ins().fabs(operand);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_library(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    selector: u32,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let bits = lowering
        .builder
        .ins()
        .bitcast(types::I64, MemFlagsData::new(), operand);
    let selector_value = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(selector));
    let operands = [selector_value, bits];
    let call = RuntimeCall {
        target: Entry::MathUnary,
        code_name: "nonFiniteRealResult",
        span: instruction.span,
        operands: &operands,
    };
    let result_bits = call_runtime(lowering, &call)?;
    let result = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), result_bits);
    bind_result(lowering, instruction, result);
    Ok(())
}
