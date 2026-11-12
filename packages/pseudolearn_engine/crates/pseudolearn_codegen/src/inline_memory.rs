#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::Lowering;
use cranelift_codegen::ir::condcodes::{FloatCC, IntCC};
use cranelift_codegen::ir::{
    Block, InstBuilder, MemFlagsData, StackSlotData, StackSlotKind, Type, Value, types,
};
use pseudolearn_ir::IrType;

pub(crate) const TOTAL_WORD: i32 = 16;
pub(crate) const BOUNDARY_WORD: i32 = 24;
pub(crate) const MASK_WORD: i32 = 32;

pub(crate) struct Joined {
    pub(crate) slow: Block,
    pub(crate) merge: Block,
}

pub(crate) fn begin_fast_path(lowering: &mut Lowering<'_, '_>, result: Option<Type>) -> Joined {
    let slow = lowering.builder.create_block();
    lowering.builder.set_cold_block(slow);
    let merge = lowering.builder.create_block();
    if let Some(value_type) = result {
        lowering.builder.append_block_param(merge, value_type);
    }
    Joined { slow, merge }
}

pub(crate) fn finish_fast_path(lowering: &mut Lowering<'_, '_>, joined: &Joined) -> Option<Value> {
    lowering.builder.switch_to_block(joined.merge);
    lowering.builder.block_params(joined.merge).first().copied()
}

pub(crate) fn branch_unless(lowering: &mut Lowering<'_, '_>, condition: Value, slow: Block) {
    let next = lowering.builder.create_block();
    lowering.builder.ins().brif(condition, next, &[], slow, &[]);
    lowering.builder.switch_to_block(next);
}

pub(crate) fn heap_base(lowering: &mut Lowering<'_, '_>, handle: Value) -> (Value, Value) {
    let pointer = lowering.environment.frontend.pointer_type();
    let offset = lowering.environment.layout.heap_words;
    let words =
        lowering
            .builder
            .ins()
            .load(pointer, MemFlagsData::trusted(), lowering.context, offset);
    let wide = lowering.builder.ins().uextend(pointer, handle);
    let scaled = lowering.builder.ins().ishl_imm_u(wide, 3);
    let base = lowering.builder.ins().iadd(words, scaled);
    (words, base)
}

pub(crate) fn is_present(lowering: &mut Lowering<'_, '_>, handle: Value) -> Value {
    lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::NotEqual, handle, 0)
}

pub(crate) fn defined_word(
    lowering: &mut Lowering<'_, '_>,
    value: Value,
    value_type: &IrType,
) -> Option<Value> {
    Some(match value_type {
        IrType::F64 => lowering.builder.ins().fcmp(FloatCC::Ordered, value, value),
        IrType::Bool => lowering.builder.ins().icmp_imm_s(IntCC::NotEqual, value, 2),
        IrType::Char => lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::NotEqual, value, -1),
        IrType::I64 | IrType::Unit => return None,
        _ => lowering.builder.ins().icmp_imm_s(IntCC::NotEqual, value, 0),
    })
}

pub(crate) fn spill_words(
    lowering: &mut Lowering<'_, '_>,
    words: &[Value],
) -> Result<Value, CodegenError> {
    let size = words
        .len()
        .checked_mul(8)
        .and_then(|bytes| u32::try_from(bytes).ok())
        .ok_or(CodegenError::InvalidModule("operand buffer too large"))?;
    let slot = lowering.builder.create_sized_stack_slot(StackSlotData::new(
        StackSlotKind::ExplicitSlot,
        size,
        3,
    ));
    let pointer = lowering.environment.frontend.pointer_type();
    for (position, word) in words.iter().enumerate() {
        let offset = position
            .checked_mul(8)
            .and_then(|bytes| i32::try_from(bytes).ok())
            .ok_or(CodegenError::InvalidModule("operand buffer too large"))?;
        lowering
            .builder
            .ins()
            .stack_store(pointer, *word, slot, offset);
    }
    Ok(lowering.builder.ins().stack_addr(pointer, slot, 0))
}

pub(crate) fn element_slot(lowering: &mut Lowering<'_, '_>, base: Value, position: Value) -> Value {
    let scaled = lowering.builder.ins().ishl_imm_u(position, 3);
    lowering.builder.ins().iadd(base, scaled)
}

pub(crate) fn clif_load(value_type: &IrType) -> Type {
    match value_type {
        IrType::I64 => types::I64,
        IrType::F64 => types::F64,
        IrType::Bool => types::I8,
        _ => types::I32,
    }
}
