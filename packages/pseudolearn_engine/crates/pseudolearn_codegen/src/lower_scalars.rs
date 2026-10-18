#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, guard_trap, operand_value};
use cranelift_codegen::ir::condcodes::{FloatCC, IntCC};
use cranelift_codegen::ir::{InstBuilder, types};
use pseudolearn_ir::{IrType, Operand, Operation, PredicateKind};

const UNDEFINED_BOOLEAN: i64 = 2;
const UNDEFINED_CHARACTER: i64 = -1;
const SCALAR_VALUE_LIMIT: i64 = 0x11_0000;
const SURROGATE_START: i64 = 0xD800;
const SURROGATE_COUNT: i64 = 0x800;

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::ConstI64,
    Operation::ConstF64,
    Operation::ConstBool,
    Operation::ConstChar,
    Operation::ValueUndefined,
    Operation::ValueRequire,
    Operation::BoolNot,
    Operation::BoolCmp,
    Operation::CharCmp,
    Operation::CharCode,
    Operation::CharFromCode,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::ConstI64 | Operation::ConstF64 | Operation::ConstBool | Operation::ConstChar => {
            lower_constant(lowering, instruction)
        }
        Operation::ValueUndefined => lower_undefined(lowering, instruction),
        Operation::ValueRequire => lower_require(lowering, instruction),
        Operation::BoolNot => {
            let operand = operand_value(lowering, instruction, 0)?;
            let result = lowering.builder.ins().bxor_imm_u(operand, 1);
            bind_result(lowering, instruction, result);
            Ok(())
        }
        Operation::BoolCmp | Operation::CharCmp => lower_comparison(lowering, instruction),
        Operation::CharCode => {
            let operand = operand_value(lowering, instruction, 0)?;
            let result = lowering.builder.ins().uextend(types::I64, operand);
            bind_result(lowering, instruction, result);
            Ok(())
        }
        _ => lower_character_from_code(lowering, instruction),
    }
}

fn lower_constant(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let result = match instruction.operands {
        [Operand::LiteralI64(number)] => lowering.builder.ins().iconst(types::I64, *number),
        [Operand::LiteralF64(number)] => lowering.builder.ins().f64const(*number),
        [Operand::LiteralBool(flag)] => lowering.builder.ins().iconst(types::I8, i64::from(*flag)),
        [Operand::LiteralChar(character)] => lowering
            .builder
            .ins()
            .iconst(types::I32, i64::from(u32::from(*character))),
        _ => return Err(CodegenError::InvalidModule("malformed constant")),
    };
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_undefined(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let result = match instruction.operands {
        [Operand::Type(IrType::Bool)] => {
            lowering.builder.ins().iconst(types::I8, UNDEFINED_BOOLEAN)
        }
        [Operand::Type(IrType::Char)] => lowering
            .builder
            .ins()
            .iconst(types::I32, UNDEFINED_CHARACTER),
        [Operand::Type(IrType::F64)] => lowering.builder.ins().f64const(f64::NAN),
        _ => return Err(CodegenError::Unsupported("value.undefined")),
    };
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_require(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let operand_type = lowering.builder.func.dfg.value_type(operand);
    let missing = if operand_type == types::F64 {
        lowering
            .builder
            .ins()
            .fcmp(FloatCC::NotEqual, operand, operand)
    } else if operand_type == types::I8 {
        lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::Equal, operand, UNDEFINED_BOOLEAN)
    } else if operand_type == types::I32 {
        lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::Equal, operand, UNDEFINED_CHARACTER)
    } else {
        lowering.builder.ins().iconst(types::I8, 0)
    };
    guard_trap(
        lowering,
        missing,
        "uninitializedVariableRead",
        instruction.span,
    )?;
    bind_result(lowering, instruction, operand);
    Ok(())
}

fn lower_comparison(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let predicate = predicate_of(instruction)?;
    let left = operand_value(lowering, instruction, 1)?;
    let right = operand_value(lowering, instruction, 2)?;
    let condition = unsigned_condition(predicate);
    let result = lowering.builder.ins().icmp(condition, left, right);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_character_from_code(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operand = operand_value(lowering, instruction, 0)?;
    let out_of_range = lowering.builder.ins().icmp_imm_s(
        IntCC::UnsignedGreaterThanOrEqual,
        operand,
        SCALAR_VALUE_LIMIT,
    );
    let offset = lowering.builder.ins().iadd_imm_s(operand, -SURROGATE_START);
    let surrogate =
        lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::UnsignedLessThan, offset, SURROGATE_COUNT);
    let invalid = lowering.builder.ins().bor(out_of_range, surrogate);
    guard_trap(lowering, invalid, "invalidCharacterCode", instruction.span)?;
    let result = lowering.builder.ins().ireduce(types::I32, operand);
    bind_result(lowering, instruction, result);
    Ok(())
}

pub(crate) fn predicate_of(instruction: &Instruction<'_>) -> Result<PredicateKind, CodegenError> {
    match instruction.operands.first() {
        Some(Operand::Predicate(predicate)) => Ok(*predicate),
        _ => Err(CodegenError::InvalidModule("comparison without predicate")),
    }
}

pub(crate) fn signed_condition(predicate: PredicateKind) -> IntCC {
    match predicate {
        PredicateKind::Equal => IntCC::Equal,
        PredicateKind::NotEqual => IntCC::NotEqual,
        PredicateKind::LessThan => IntCC::SignedLessThan,
        PredicateKind::LessEqual => IntCC::SignedLessThanOrEqual,
        PredicateKind::GreaterThan => IntCC::SignedGreaterThan,
        PredicateKind::GreaterEqual => IntCC::SignedGreaterThanOrEqual,
    }
}

pub(crate) fn unsigned_condition(predicate: PredicateKind) -> IntCC {
    match predicate {
        PredicateKind::Equal => IntCC::Equal,
        PredicateKind::NotEqual => IntCC::NotEqual,
        PredicateKind::LessThan => IntCC::UnsignedLessThan,
        PredicateKind::LessEqual => IntCC::UnsignedLessThanOrEqual,
        PredicateKind::GreaterThan => IntCC::UnsignedGreaterThan,
        PredicateKind::GreaterEqual => IntCC::UnsignedGreaterThanOrEqual,
    }
}

pub(crate) fn float_condition(predicate: PredicateKind) -> FloatCC {
    match predicate {
        PredicateKind::Equal => FloatCC::Equal,
        PredicateKind::NotEqual => FloatCC::NotEqual,
        PredicateKind::LessThan => FloatCC::LessThan,
        PredicateKind::LessEqual => FloatCC::LessThanOrEqual,
        PredicateKind::GreaterThan => FloatCC::GreaterThan,
        PredicateKind::GreaterEqual => FloatCC::GreaterThanOrEqual,
    }
}
