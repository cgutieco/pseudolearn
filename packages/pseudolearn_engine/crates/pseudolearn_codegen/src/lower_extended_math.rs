#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{
    MATH_ARC_COSINE, MATH_ARC_SINE, MATH_ARC_TANGENT2, MATH_CEILING, MATH_FLOOR, MATH_LOGARITHM2,
    MATH_LOGARITHM10, MATH_REAL_MAXIMUM, MATH_REAL_MINIMUM, MATH_TANGENT,
};
use pseudolearn_ir::Operation;

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::MathTan,
    Operation::MathAsin,
    Operation::MathAcos,
    Operation::MathLog2,
    Operation::MathLog10,
    Operation::MathAtan2,
    Operation::RealFloor,
    Operation::RealCeil,
    Operation::RealMin,
    Operation::RealMax,
    Operation::IntMin,
    Operation::IntMax,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::MathTan => lower_real_unary(lowering, instruction, MATH_TANGENT),
        Operation::MathAsin => lower_real_unary(lowering, instruction, MATH_ARC_SINE),
        Operation::MathAcos => lower_real_unary(lowering, instruction, MATH_ARC_COSINE),
        Operation::MathLog2 => lower_real_unary(lowering, instruction, MATH_LOGARITHM2),
        Operation::MathLog10 => lower_real_unary(lowering, instruction, MATH_LOGARITHM10),
        Operation::RealFloor => lower_integer_rounding(lowering, instruction, MATH_FLOOR),
        Operation::RealCeil => lower_integer_rounding(lowering, instruction, MATH_CEILING),
        Operation::MathAtan2 => lower_real_binary(lowering, instruction, MATH_ARC_TANGENT2),
        Operation::RealMin => lower_real_binary(lowering, instruction, MATH_REAL_MINIMUM),
        Operation::RealMax => lower_real_binary(lowering, instruction, MATH_REAL_MAXIMUM),
        _ => lower_integer_extreme(lowering, instruction),
    }
}

fn real_bits(lowering: &mut Lowering<'_, '_>, value: Value) -> Value {
    lowering
        .builder
        .ins()
        .bitcast(types::I64, MemFlagsData::new(), value)
}

fn unary_call(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    selector: u32,
    code_name: &'static str,
) -> Result<Value, CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let bits = real_bits(lowering, operand);
    let selector_value = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(selector));
    let operands = [selector_value, bits];
    call_runtime(
        lowering,
        &RuntimeCall {
            target: Entry::MathUnary,
            code_name,
            span: instruction.span,
            operands: &operands,
        },
    )
}

fn lower_real_unary(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    selector: u32,
) -> Result<(), CodegenError> {
    let bits = unary_call(lowering, instruction, selector, "nonFiniteRealResult")?;
    let result = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), bits);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_integer_rounding(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    selector: u32,
) -> Result<(), CodegenError> {
    let result = unary_call(lowering, instruction, selector, "integerOverflow")?;
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_real_binary(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    selector: u32,
) -> Result<(), CodegenError> {
    let left = operand_value(lowering, instruction, 0)?;
    let right = operand_value(lowering, instruction, 1)?;
    let left_bits = real_bits(lowering, left);
    let right_bits = real_bits(lowering, right);
    let selector_value = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(selector));
    let operands = [selector_value, left_bits, right_bits];
    let bits = call_runtime(
        lowering,
        &RuntimeCall {
            target: Entry::MathBinary,
            code_name: "nonFiniteRealResult",
            span: instruction.span,
            operands: &operands,
        },
    )?;
    let result = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), bits);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_integer_extreme(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let left = operand_value(lowering, instruction, 0)?;
    let right = operand_value(lowering, instruction, 1)?;
    let result = if instruction.operation == Operation::IntMin {
        lowering.builder.ins().smin(left, right)
    } else {
        lowering.builder.ins().smax(left, right)
    };
    bind_result(lowering, instruction, result);
    Ok(())
}
