#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::inline_memory::{defined_word, spill_words};
use crate::lower_arrays::operand_values;
use crate::lower_objects::field_target;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::type_mapping::kind_code;
use crate::word_conversion::{from_word, to_word};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{Block, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{
    CELL_SLOT_BYTES, CELL_SLOT_LOCAL_OFFSET, CELL_SLOT_READABLE_OFFSET, CELL_SLOT_WORD_OFFSET,
};
use pseudolearn_ir::{IrType, Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::CellLocal,
    Operation::CellElement,
    Operation::CellField,
    Operation::CellLoad,
    Operation::CellLoadRaw,
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
        Operation::CellLoad | Operation::CellLoadRaw => lower_load(lowering, instruction),
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
    let word = load_cell_word(lowering, instruction, cell)?;
    let value = from_word(lowering, word, &content)?;
    bind_result(lowering, instruction, value);
    Ok(())
}

fn cell_slot_address(
    lowering: &mut Lowering<'_, '_>,
    cell: Value,
    slow: Block,
) -> Result<Value, CodegenError> {
    let layout = lowering.environment.layout;
    let flags = MemFlagsData::trusted();
    let slot_bytes = i64::try_from(CELL_SLOT_BYTES)
        .map_err(|_| CodegenError::InvalidModule("cell slot size out of range"))?;
    let in_table = lowering.builder.create_block();
    let wide = lowering.builder.ins().uextend(types::I64, cell);
    let index = lowering.builder.ins().iadd_imm_s(wide, -1);
    let length =
        lowering
            .builder
            .ins()
            .load(types::I64, flags, lowering.context, layout.cells_length);
    let within = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedLessThan, index, length);
    lowering
        .builder
        .ins()
        .brif(within, in_table, &[], slow, &[]);
    lowering.builder.switch_to_block(in_table);
    let table =
        lowering
            .builder
            .ins()
            .load(types::I64, flags, lowering.context, layout.cells_pointer);
    let scaled = lowering.builder.ins().imul_imm_s(index, slot_bytes);
    Ok(lowering.builder.ins().iadd(table, scaled))
}

fn load_cell_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    cell: Value,
) -> Result<Value, CodegenError> {
    let flags = MemFlagsData::trusted();
    let readable_offset = i32::try_from(CELL_SLOT_READABLE_OFFSET)
        .map_err(|_| CodegenError::InvalidModule("cell slot offset out of range"))?;
    let word_offset = i32::try_from(CELL_SLOT_WORD_OFFSET)
        .map_err(|_| CodegenError::InvalidModule("cell slot offset out of range"))?;
    let fast = lowering.builder.create_block();
    let slow = lowering.builder.create_block();
    let merge = lowering.builder.create_block();
    lowering.builder.set_cold_block(slow);
    let word = lowering.builder.append_block_param(merge, types::I64);
    let slot = cell_slot_address(lowering, cell, slow)?;
    let readable = lowering
        .builder
        .ins()
        .load(types::I64, flags, slot, readable_offset);
    if instruction.operation == Operation::CellLoadRaw {
        lowering.builder.ins().jump(fast, &[]);
    } else {
        lowering.builder.ins().brif(readable, fast, &[], slow, &[]);
    }
    lowering.builder.switch_to_block(fast);
    let direct = lowering
        .builder
        .ins()
        .load(types::I64, flags, slot, word_offset);
    lowering.builder.ins().jump(merge, &[direct.into()]);
    lowering.builder.switch_to_block(slow);
    let fallback = call_cell(lowering, instruction, (Entry::CellLoad, &[cell]))?;
    lowering.builder.ins().jump(merge, &[fallback.into()]);
    lowering.builder.switch_to_block(merge);
    Ok(word)
}

fn lower_store(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let content = cell_content(lowering, instruction)?;
    let cell = operand_value(lowering, instruction, 0)?;
    let value = operand_value(lowering, instruction, 1)?;
    let readable = readable_flag(lowering, value, &content);
    let word = to_word(lowering, value, &content)?;
    store_cell_word(lowering, instruction, (cell, word), readable)
}

fn readable_flag(lowering: &mut Lowering<'_, '_>, value: Value, content: &IrType) -> Value {
    match defined_word(lowering, value, content) {
        Some(flag) => lowering.builder.ins().uextend(types::I64, flag),
        None => lowering.builder.ins().iconst(types::I64, 1),
    }
}

fn store_cell_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (cell, word): (Value, Value),
    readable: Value,
) -> Result<(), CodegenError> {
    let flags = MemFlagsData::trusted();
    let local_offset = i32::try_from(CELL_SLOT_LOCAL_OFFSET)
        .map_err(|_| CodegenError::InvalidModule("cell slot offset out of range"))?;
    let readable_offset = i32::try_from(CELL_SLOT_READABLE_OFFSET)
        .map_err(|_| CodegenError::InvalidModule("cell slot offset out of range"))?;
    let word_offset = i32::try_from(CELL_SLOT_WORD_OFFSET)
        .map_err(|_| CodegenError::InvalidModule("cell slot offset out of range"))?;
    let fast = lowering.builder.create_block();
    let slow = lowering.builder.create_block();
    let merge = lowering.builder.create_block();
    lowering.builder.set_cold_block(slow);
    let slot = cell_slot_address(lowering, cell, slow)?;
    let local = lowering
        .builder
        .ins()
        .load(types::I64, flags, slot, local_offset);
    lowering.builder.ins().brif(local, fast, &[], slow, &[]);
    lowering.builder.switch_to_block(fast);
    lowering.builder.ins().store(flags, word, slot, word_offset);
    lowering
        .builder
        .ins()
        .store(flags, readable, slot, readable_offset);
    lowering.builder.ins().jump(merge, &[]);
    lowering.builder.switch_to_block(slow);
    call_cell(lowering, instruction, (Entry::CellStore, &[cell, word]))?;
    lowering.builder.ins().jump(merge, &[]);
    lowering.builder.switch_to_block(merge);
    Ok(())
}
