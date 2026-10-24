#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lower_text::value_type_of;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::type_mapping::kind_code;
use crate::word_conversion::{from_word, to_word};
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{NEWLINE_FLAG, PROFILE_SHIFT};
use pseudolearn_ir::{Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::OutWrite,
    Operation::InRead,
    Operation::HostRandom,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::OutWrite => lower_write(lowering, instruction),
        Operation::InRead => lower_read(lowering, instruction),
        _ => lower_random(lowering, instruction),
    }
}

fn call_io(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (target, operands): (Entry, &[Value]),
) -> Result<Value, CodegenError> {
    let call = RuntimeCall {
        target,
        code_name: "internalFault",
        span: instruction.span,
        operands,
    };
    call_runtime(lowering, &call)
}

fn lower_write(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let newline = instruction.operands.last() == Some(&Operand::Newline);
    let count = instruction
        .operands
        .len()
        .saturating_sub(usize::from(newline));
    for position in 0..count {
        let Some(Operand::Value(identifier)) = instruction.operands.get(position) else {
            return Err(CodegenError::InvalidModule("out.write operand"));
        };
        let value_type = value_type_of(lowering, *identifier)?;
        let value = operand_value(lowering, instruction, position)?;
        let word = to_word(lowering, value, &value_type)?;
        let kind = kind_code(&value_type).ok_or(CodegenError::InvalidModule("write of unit"))?;
        let last = position.saturating_add(1) == count;
        let flags = if newline && last { NEWLINE_FLAG } else { 0 };
        let profile = profile_bits(lowering, instruction);
        let descriptor = lowering
            .builder
            .ins()
            .iconst(types::I32, i64::from(kind | flags | profile));
        call_io(lowering, instruction, (Entry::Write, &[word, descriptor]))?;
    }
    Ok(())
}

pub(crate) fn profile_bits(lowering: &Lowering<'_, '_>, instruction: &Instruction<'_>) -> u32 {
    let module = lowering.environment.module;
    if module.profiles.is_empty() {
        return 0;
    }
    let index = u32::try_from(module.vocabulary_index_of(instruction.span)).unwrap_or(0);
    index << PROFILE_SHIFT
}

fn lower_read(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Type(value_type)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("in.read without type"));
    };
    let kind = kind_code(value_type).ok_or(CodegenError::InvalidModule("read of unit"))?;
    let kind_value = lowering.builder.ins().iconst(types::I32, i64::from(kind));
    let frame = push_roots(lowering, instruction)?;
    let word = call_io(lowering, instruction, (Entry::Read, &[kind_value]))?;
    pop_roots(lowering, frame);
    let value = from_word(lowering, word, value_type)?;
    bind_result(lowering, instruction, value);
    Ok(())
}

fn lower_random(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let bits = call_io(lowering, instruction, (Entry::RandomReal, &[]))?;
    let real = lowering
        .builder
        .ins()
        .bitcast(types::F64, MemFlagsData::new(), bits);
    bind_result(lowering, instruction, real);
    Ok(())
}
