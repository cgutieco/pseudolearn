#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lower_scalars::{predicate_of, signed_condition};
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::type_mapping::kind_code;
use crate::word_conversion::to_word;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{CHARACTER_OPERAND_FLAG, TEXT_LENGTH, TEXT_TO_INTEGER, TEXT_TO_REAL};
use pseudolearn_ir::{IrType, Operand, Operation, ValueId};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::ConstStr,
    Operation::TextConcat,
    Operation::TextLength,
    Operation::TextCharAt,
    Operation::TextCmp,
    Operation::TextFormat,
    Operation::TextToInteger,
    Operation::TextToReal,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::ConstStr => lower_literal(lowering, instruction),
        Operation::TextConcat => lower_concatenation(lowering, instruction),
        Operation::TextLength => lower_query(lowering, instruction, TEXT_LENGTH),
        Operation::TextToInteger => lower_query(lowering, instruction, TEXT_TO_INTEGER),
        Operation::TextToReal => lower_real_query(lowering, instruction),
        Operation::TextCharAt => lower_character_at(lowering, instruction),
        Operation::TextCmp => lower_comparison(lowering, instruction),
        _ => lower_format(lowering, instruction),
    }
}

fn call_text(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (target, operands): (Entry, &[Value]),
) -> Result<Value, CodegenError> {
    let call = RuntimeCall {
        target,
        code_name: "stringToNumberConversionFailed",
        span: instruction.span,
        operands,
    };
    call_runtime(lowering, &call)
}

fn allocating_call(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (target, operands): (Entry, &[Value]),
) -> Result<(), CodegenError> {
    let frame = push_roots(lowering, instruction)?;
    let word = call_text(lowering, instruction, (target, operands))?;
    pop_roots(lowering, frame);
    let handle = lowering.builder.ins().ireduce(types::I32, word);
    bind_result(lowering, instruction, handle);
    Ok(())
}

fn lower_literal(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::LiteralStr(content)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("const.str without literal"));
    };
    let global = lowering
        .environment
        .literals
        .get(content)
        .copied()
        .ok_or(CodegenError::InvalidModule("undeclared literal"))?;
    let pointer = lowering.environment.frontend.pointer_type();
    let length = i64::try_from(content.len())
        .map_err(|_| CodegenError::InvalidModule("literal too long"))?;
    let address = lowering.builder.ins().symbol_value(pointer, global);
    let size = lowering.builder.ins().iconst(pointer, length);
    allocating_call(
        lowering,
        instruction,
        (Entry::TextLiteral, &[address, size]),
    )
}

fn text_operand(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    position: usize,
) -> Result<Value, CodegenError> {
    let value = operand_value(lowering, instruction, position)?;
    let is_character = matches!(
        instruction.operands.get(position),
        Some(Operand::Value(identifier)) if lowering.types.get(identifier) == Some(&IrType::Char)
    );
    let wide = lowering.builder.ins().uextend(types::I64, value);
    if is_character {
        let flag = i64::try_from(CHARACTER_OPERAND_FLAG)
            .map_err(|_| CodegenError::InvalidModule("character flag"))?;
        return Ok(lowering.builder.ins().iadd_imm_s(wide, flag));
    }
    Ok(wide)
}

fn lower_concatenation(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let left = text_operand(lowering, instruction, 0)?;
    let right = text_operand(lowering, instruction, 1)?;
    allocating_call(lowering, instruction, (Entry::TextConcat, &[left, right]))
}

fn lower_query(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    query: u32,
) -> Result<(), CodegenError> {
    let handle = text_operand(lowering, instruction, 0)?;
    let selector = lowering.builder.ins().iconst(types::I32, i64::from(query));
    let word = call_text(
        lowering,
        instruction,
        (Entry::TextQuery, &[selector, handle]),
    )?;
    bind_result(lowering, instruction, word);
    Ok(())
}

fn lower_real_query(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let handle = text_operand(lowering, instruction, 0)?;
    let selector = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(TEXT_TO_REAL));
    let word = call_text(
        lowering,
        instruction,
        (Entry::TextQuery, &[selector, handle]),
    )?;
    let real = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), word);
    bind_result(lowering, instruction, real);
    Ok(())
}

fn lower_character_at(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let handle = text_operand(lowering, instruction, 0)?;
    let position = operand_value(lowering, instruction, 1)?;
    let word = call_text(
        lowering,
        instruction,
        (Entry::TextCharacter, &[handle, position]),
    )?;
    let character = lowering.builder.ins().ireduce(types::I32, word);
    bind_result(lowering, instruction, character);
    Ok(())
}

fn lower_comparison(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let predicate = predicate_of(instruction)?;
    let left = text_operand(lowering, instruction, 1)?;
    let right = text_operand(lowering, instruction, 2)?;
    let sign = call_text(lowering, instruction, (Entry::TextCompare, &[left, right]))?;
    let result = lowering
        .builder
        .ins()
        .icmp_imm_s(signed_condition(predicate), sign, 0);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn lower_format(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("text.format without value"));
    };
    let value_type = value_type_of(lowering, *identifier)?;
    let value = operand_value(lowering, instruction, 0)?;
    let word = to_word(lowering, value, &value_type)?;
    let kind = kind_code(&value_type).ok_or(CodegenError::InvalidModule("format of unit"))?;
    let descriptor = lowering.builder.ins().iconst(types::I32, i64::from(kind));
    allocating_call(
        lowering,
        instruction,
        (Entry::TextFormat, &[word, descriptor]),
    )
}

pub(crate) fn value_type_of(
    lowering: &Lowering<'_, '_>,
    identifier: ValueId,
) -> Result<IrType, CodegenError> {
    lowering
        .types
        .get(&identifier)
        .cloned()
        .ok_or(CodegenError::InvalidModule("untyped operand"))
}
