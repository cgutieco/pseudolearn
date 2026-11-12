#![forbid(unsafe_code)]

use crate::definition::{Definition, definition_of};
use crate::error::CodegenError;
use crate::lowering::{
    Instruction, Lowering, bind_result, guard_trap, operand_value, trap_and_continue,
};
use cranelift_codegen::ir::condcodes::{FloatCC, IntCC};
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::{IrType, Operand, Operation, PredicateKind, ValueId};

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
        [Operand::Type(IrType::I64)] => {
            if let Some(identifier) = instruction.result {
                lowering
                    .definitions
                    .insert(identifier, Definition::Undefined);
            }
            lowering.builder.ins().iconst(types::I64, 0)
        }
        [Operand::Type(IrType::Unit)] => {
            return Err(CodegenError::InvalidModule("undefined unit value"));
        }
        [Operand::Type(_)] => lowering.builder.ins().iconst(types::I32, 0),
        _ => return Err(CodegenError::InvalidModule("malformed value.undefined")),
    };
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_require(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("malformed value.require"));
    };
    let operand = operand_value(lowering, instruction, 0)?;
    let operand_type = lowering
        .types
        .get(identifier)
        .cloned()
        .ok_or(CodegenError::InvalidModule("untyped operand"))?;
    if lowering.defined_values.contains(identifier) {
        bind_result(lowering, instruction, operand);
        return Ok(());
    }
    if operand_type == IrType::I64 {
        require_integer(lowering, instruction, *identifier)?;
    } else {
        let missing = missing_condition(lowering, &operand_type, operand);
        guard_trap(
            lowering,
            missing,
            "uninitializedVariableRead",
            instruction.span,
        )?;
    }
    bind_result(lowering, instruction, operand);
    Ok(())
}

fn require_integer(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    identifier: ValueId,
) -> Result<(), CodegenError> {
    match definition_of(lowering, identifier) {
        Definition::Defined => Ok(()),
        Definition::Undefined => {
            trap_and_continue(lowering, "uninitializedVariableRead", instruction.span)
        }
        Definition::Flag(flag) => {
            let missing = lowering.builder.ins().icmp_imm_s(IntCC::Equal, flag, 0);
            guard_trap(
                lowering,
                missing,
                "uninitializedVariableRead",
                instruction.span,
            )
        }
    }
}

fn missing_condition(
    lowering: &mut Lowering<'_, '_>,
    operand_type: &IrType,
    operand: Value,
) -> Value {
    match operand_type {
        IrType::F64 => lowering
            .builder
            .ins()
            .fcmp(FloatCC::NotEqual, operand, operand),
        IrType::Bool => lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::Equal, operand, UNDEFINED_BOOLEAN),
        IrType::Char => {
            lowering
                .builder
                .ins()
                .icmp_imm_s(IntCC::Equal, operand, UNDEFINED_CHARACTER)
        }
        _ => lowering.builder.ins().icmp_imm_s(IntCC::Equal, operand, 0),
    }
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
    crate::lowering::guard_character_trap(lowering, invalid, operand, instruction.span)?;
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
