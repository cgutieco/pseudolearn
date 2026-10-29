#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::inline_memory::spill_words;
use crate::lower_text::value_type_of;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::word_conversion::to_word;
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::{IrType, Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[Operation::EffectCall];

const FIRST_ARGUMENT: usize = 4;

struct EffectShape<'operands> {
    identity: &'operands str,
    result_type: &'operands IrType,
    source_node: u32,
}

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let shape = shape_of(instruction)?;
    let operation = pseudolearn_aot_rt::effect_operation_index(shape.identity)
        .ok_or(CodegenError::InvalidModule("unknown effect operation"))?;
    check_arity(instruction, shape.identity)?;
    let class = result_class(lowering, shape.result_type)?;
    let mut words = vec![
        capability_word(lowering, instruction)?,
        constant_word(lowering, u64::from(shape.source_node)),
        constant_word(lowering, u64::from(class)),
    ];
    words.extend(operand_words(lowering, instruction)?);
    let buffer = spill_words(lowering, &words)?;
    let descriptor = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(operation));
    let call = RuntimeCall {
        target: Entry::EffectCall,
        code_name: "internalFault",
        span: instruction.span,
        operands: &[descriptor, buffer],
    };
    let frame = push_roots(lowering, instruction)?;
    let result = call_runtime(lowering, &call)?;
    pop_roots(lowering, frame);
    bind_result(lowering, instruction, result);
    Ok(())
}

fn check_arity(instruction: &Instruction<'_>, identity: &str) -> Result<(), CodegenError> {
    let (arguments, cells) = pseudolearn_aot_rt::effect_operation_cells(identity)
        .ok_or(CodegenError::InvalidModule("unknown effect operation"))?;
    let expected = arguments
        .checked_add(cells)
        .and_then(|count| count.checked_add(FIRST_ARGUMENT));
    if expected == Some(instruction.operands.len()) {
        return Ok(());
    }
    Err(CodegenError::InvalidModule("effect call arity"))
}

fn shape_of<'operands>(
    instruction: &Instruction<'operands>,
) -> Result<EffectShape<'operands>, CodegenError> {
    let (
        Some(Operand::Identifier(identity)),
        Some(Operand::Type(result_type)),
        Some(Operand::Identifier(source)),
    ) = (
        instruction.operands.get(1),
        instruction.operands.get(2),
        instruction.operands.get(3),
    )
    else {
        return Err(CodegenError::InvalidModule("effect call operands"));
    };
    let source_node = source
        .strip_prefix('n')
        .and_then(|digits| digits.parse().ok())
        .ok_or(CodegenError::InvalidModule("effect call source"))?;
    Ok(EffectShape {
        identity,
        result_type,
        source_node,
    })
}

fn constant_word(lowering: &mut Lowering<'_, '_>, word: u64) -> Value {
    let signed = i64::from_ne_bytes(word.to_ne_bytes());
    lowering.builder.ins().iconst(types::I64, signed)
}

fn operand_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    position: usize,
) -> Result<Value, CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.get(position) else {
        return Err(CodegenError::InvalidModule("effect operand is not a value"));
    };
    let value_type = value_type_of(lowering, *identifier)?;
    let value = operand_value(lowering, instruction, position)?;
    to_word(lowering, value, &value_type)
}

fn capability_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<Value, CodegenError> {
    operand_word(lowering, instruction, 0)
}

fn operand_words(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<Vec<Value>, CodegenError> {
    (FIRST_ARGUMENT..instruction.operands.len())
        .map(|position| operand_word(lowering, instruction, position))
        .collect()
}

fn result_class(lowering: &Lowering<'_, '_>, result_type: &IrType) -> Result<u32, CodegenError> {
    let IrType::Object(name) = result_type else {
        return Ok(0);
    };
    let index = lowering
        .environment
        .classes
        .class_index(name)
        .ok_or(CodegenError::InvalidModule("unknown effect result class"))?;
    u32::try_from(index).map_err(|_| CodegenError::InvalidModule("unknown effect result class"))
}
