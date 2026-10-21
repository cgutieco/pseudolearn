#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::array_fast_path::{
    Located, define_integer, element_address, locate, locate_verified, require_dense,
    require_present,
};
use crate::dominated_facts::{SlotKey, remember_slot, slot_key, slot_verified};
use crate::error::CodegenError;
use crate::inline_memory::{
    begin_fast_path, branch_unless, clif_load, defined_word, finish_fast_path, heap_base,
    spill_words,
};
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::type_mapping::{element_type, kind_code};
use crate::word_conversion::{from_word, to_word};
use cranelift_codegen::ir::{Block, BlockArg, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::RANK_SHIFT;
use pseudolearn_ir::{IrType, Operand, Operation, ValueId};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::ArrayNew,
    Operation::ArrayLoad,
    Operation::ArrayStore,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::ArrayNew => lower_new(lowering, instruction),
        Operation::ArrayLoad => lower_load(lowering, instruction),
        _ => lower_store(lowering, instruction),
    }
}

pub(crate) fn operand_values(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    range: std::ops::Range<usize>,
) -> Result<Vec<Value>, CodegenError> {
    range
        .map(|position| operand_value(lowering, instruction, position))
        .collect()
}

pub(crate) fn array_element(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<IrType, CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("array operation without array"));
    };
    element_of(lowering, *identifier)
}

fn element_of(lowering: &Lowering<'_, '_>, identifier: ValueId) -> Result<IrType, CodegenError> {
    match lowering.types.get(&identifier) {
        Some(IrType::Array { element, .. }) => Ok(element.as_ref().clone()),
        _ => Err(CodegenError::InvalidModule("operand is not an array")),
    }
}

fn lower_new(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Type(declared)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("array.new without type"));
    };
    let kind =
        kind_code(&element_type(declared)).ok_or(CodegenError::InvalidModule("array of unit"))?;
    let extents = operand_values(lowering, instruction, 1..instruction.operands.len())?;
    let rank = u32::try_from(extents.len())
        .map_err(|_| CodegenError::InvalidModule("array rank out of range"))?;
    let descriptor = kind | rank.wrapping_shl(RANK_SHIFT);
    let frame = push_roots(lowering, instruction)?;
    let buffer = spill_words(lowering, &extents)?;
    let descriptor_value = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(descriptor));
    let operands = [descriptor_value, buffer];
    let call = RuntimeCall {
        target: Entry::ArrayNew,
        code_name: "cellLimitExceeded",
        span: instruction.span,
        operands: &operands,
    };
    let word = call_runtime(lowering, &call)?;
    pop_roots(lowering, frame);
    let handle = lowering.builder.ins().ireduce(types::I32, word);
    bind_result(lowering, instruction, handle);
    Ok(())
}

struct ArrayRead<'access> {
    array: Value,
    indices: &'access [Value],
    element: &'access IrType,
}

fn lower_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let element = array_element(lowering, instruction)?;
    let array = operand_value(lowering, instruction, 0)?;
    let indices = operand_values(lowering, instruction, 1..instruction.operands.len())?;
    let read = ArrayRead {
        array,
        indices: &indices,
        element: &element,
    };
    let joined = begin_fast_path(lowering, Some(clif_load(&element)));
    let fast = fast_load(lowering, &read, joined.slow)?;
    lowering
        .builder
        .ins()
        .jump(joined.merge, &[BlockArg::Value(fast)]);
    lowering.builder.switch_to_block(joined.slow);
    let slow = slow_load(lowering, instruction, &read)?;
    if indices.len() == 1 {
        crate::lowering::jump_to_trap(lowering, "internalFault", instruction.span)?;
    } else {
        lowering
            .builder
            .ins()
            .jump(joined.merge, &[BlockArg::Value(slow)]);
    }
    let merged = finish_fast_path(lowering, &joined)
        .ok_or(CodegenError::InvalidModule("missing merged value"))?;
    bind_result(lowering, instruction, merged);
    Ok(())
}

fn fast_load(
    lowering: &mut Lowering<'_, '_>,
    read: &ArrayRead<'_>,
    slow: Block,
) -> Result<Value, CodegenError> {
    let located = locate_access(lowering, (read.array, read.indices), slow)?;
    let address = element_address(lowering, &located);
    let value = lowering.builder.ins().load(
        clif_load(read.element),
        MemFlagsData::trusted(),
        address,
        located.offset,
    );
    match defined_word(lowering, value, read.element) {
        Some(condition) => branch_unless(lowering, condition, slow),
        None => require_dense(lowering, &located, slow),
    }
    Ok(value)
}

fn slot_of(lowering: &Lowering<'_, '_>, array: Value, indices: &[Value]) -> Option<SlotKey> {
    match indices {
        [index] => Some(slot_key(lowering, array, *index)),
        _ => None,
    }
}

fn locate_access(
    lowering: &mut Lowering<'_, '_>,
    (array, indices): (Value, &[Value]),
    slow: Block,
) -> Result<Located, CodegenError> {
    let key = slot_of(lowering, array, indices);
    let verified = key.is_some_and(|key| slot_verified(lowering, &key));
    if !verified {
        require_present(lowering, array, slow);
    }
    let heap = heap_base(lowering, array);
    let located = match indices {
        [index] if verified => locate_verified(heap, *index),
        _ => locate(lowering, heap, indices, slow),
    }
    .ok_or(CodegenError::InvalidModule("array rank out of range"))?;
    if let Some(key) = key {
        remember_slot(lowering, key);
    }
    Ok(located)
}

fn slow_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    read: &ArrayRead<'_>,
) -> Result<Value, CodegenError> {
    let buffer = spill_words(lowering, read.indices)?;
    let operands = [read.array, buffer];
    let call = RuntimeCall {
        target: Entry::ArrayLoad,
        code_name: "arrayIndexOutOfRange",
        span: instruction.span,
        operands: &operands,
    };
    let word = call_runtime(lowering, &call)?;
    from_word(lowering, word, read.element)
}

fn lower_store(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let element = array_element(lowering, instruction)?;
    let array = operand_value(lowering, instruction, 0)?;
    let last = instruction.operands.len().saturating_sub(1);
    let indices = operand_values(lowering, instruction, 1..last)?;
    let value = operand_value(lowering, instruction, last)?;
    let word = to_word(lowering, value, &element)?;
    let joined = begin_fast_path(lowering, None);
    let located = locate_access(lowering, (array, &indices), joined.slow)?;
    if element == IrType::I64 {
        define_integer(lowering, &located);
    }
    let address = element_address(lowering, &located);
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), word, address, located.offset);
    lowering.builder.ins().jump(joined.merge, &[]);
    lowering.builder.switch_to_block(joined.slow);
    slow_store(lowering, instruction, (array, &indices), word)?;
    if indices.len() == 1 {
        crate::lowering::jump_to_trap(lowering, "internalFault", instruction.span)?;
    } else {
        lowering.builder.ins().jump(joined.merge, &[]);
    }
    finish_fast_path(lowering, &joined);
    Ok(())
}

fn slow_store(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (array, indices): (Value, &[Value]),
    word: Value,
) -> Result<(), CodegenError> {
    let mut operands = indices.to_vec();
    operands.push(word);
    let buffer = spill_words(lowering, &operands)?;
    let call_operands = [array, buffer];
    let call = RuntimeCall {
        target: Entry::ArrayStore,
        code_name: "arrayIndexOutOfRange",
        span: instruction.span,
        operands: &call_operands,
    };
    call_runtime(lowering, &call)?;
    Ok(())
}
