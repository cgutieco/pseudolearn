#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::inline_memory::spill_words;
use crate::lower_arrays::operand_values;
use crate::lower_objects::field_target;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::type_mapping::kind_code;
use crate::word_conversion::{from_word, to_word};
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::{IrType, Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::CellLocal,
    Operation::CellElement,
    Operation::CellField,
    Operation::CellLoad,
    Operation::CellStore,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::CellLocal => lower_local(lowering, instruction),
        Operation::CellElement => lower_element(lowering, instruction),
        Operation::CellField => lower_field(lowering, instruction),
        Operation::CellLoad => lower_load(lowering, instruction),
        _ => lower_store(lowering, instruction),
    }
}

fn call_cell(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (target, operands): (Entry, &[Value]),
) -> Result<Value, CodegenError> {
    let call = RuntimeCall {
        target,
        code_name: "uninitializedVariableRead",
        span: instruction.span,
        operands,
    };
    call_runtime(lowering, &call)
}

fn bind_cell(lowering: &mut Lowering<'_, '_>, instruction: &Instruction<'_>, word: Value) {
    let cell = lowering.builder.ins().ireduce(types::I32, word);
    bind_result(lowering, instruction, cell);
}

fn lower_local(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Type(stored)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("cell.local without type"));
    };
    let kind = kind_code(stored).ok_or(CodegenError::InvalidModule("cell of unit"))?;
    let kind_value = lowering.builder.ins().iconst(types::I32, i64::from(kind));
    let word = call_cell(lowering, instruction, (Entry::CellLocal, &[kind_value]))?;
    bind_cell(lowering, instruction, word);
    Ok(())
}

fn lower_element(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let array = operand_value(lowering, instruction, 0)?;
    let indices = operand_values(lowering, instruction, 1..instruction.operands.len())?;
    let buffer = spill_words(lowering, &indices)?;
    let word = call_cell(
        lowering,
        instruction,
        (Entry::CellElement, &[array, buffer]),
    )?;
    bind_cell(lowering, instruction, word);
    Ok(())
}

fn lower_field(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = field_target(lowering, instruction)?;
    let object = operand_value(lowering, instruction, 0)?;
    let index = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(target.index));
    let word = call_cell(lowering, instruction, (Entry::CellField, &[object, index]))?;
    bind_cell(lowering, instruction, word);
    Ok(())
}

fn cell_content(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<IrType, CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("cell access without cell"));
    };
    match lowering.types.get(identifier) {
        Some(IrType::Cell(inner)) => Ok(inner.as_ref().clone()),
        _ => Err(CodegenError::InvalidModule("operand is not a cell")),
    }
}

fn lower_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let content = cell_content(lowering, instruction)?;
    let cell = operand_value(lowering, instruction, 0)?;
    let word = call_cell(lowering, instruction, (Entry::CellLoad, &[cell]))?;
    let value = from_word(lowering, word, &content)?;
    bind_result(lowering, instruction, value);
    Ok(())
}

fn lower_store(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let content = cell_content(lowering, instruction)?;
    let cell = operand_value(lowering, instruction, 0)?;
    let value = operand_value(lowering, instruction, 1)?;
    let word = to_word(lowering, value, &content)?;
    call_cell(lowering, instruction, (Entry::CellStore, &[cell, word]))?;
    Ok(())
}
