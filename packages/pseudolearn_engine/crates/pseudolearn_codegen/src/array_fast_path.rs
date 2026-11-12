#![forbid(unsafe_code)]

use crate::inline_memory::{
    BOUNDARY_WORD, MASK_WORD, TOTAL_WORD, branch_unless, element_slot, is_present,
};
use crate::lowering::Lowering;
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{Block, InstBuilder, MemFlagsData, Value, types};

const ELEMENTS_START_RANK_ONE: i32 = 40;
const ELEMENTS_START_BASE: usize = 5;

pub(crate) struct Located {
    pub(crate) words: Value,
    pub(crate) base: Value,
    pub(crate) linear: Value,
    pub(crate) offset: i32,
}

pub(crate) fn locate(
    lowering: &mut Lowering<'_, '_>,
    (words, base): (Value, Value),
    indices: &[Value],
    slow: Block,
) -> Option<Located> {
    let flags = MemFlagsData::trusted();
    let mut linear: Option<Value> = None;
    for (position, index) in indices.iter().enumerate() {
        let extent_offset = extent_offset(indices.len(), position)?;
        let extent = lowering
            .builder
            .ins()
            .load(types::I64, flags, base, extent_offset);
        let within = lowering
            .builder
            .ins()
            .icmp(IntCC::UnsignedLessThan, *index, extent);
        branch_unless(lowering, within, slow);
        linear = Some(match linear {
            None => *index,
            Some(previous) => {
                let scaled = lowering.builder.ins().imul(previous, extent);
                lowering.builder.ins().iadd(scaled, *index)
            }
        });
    }
    Some(Located {
        words,
        base,
        linear: linear?,
        offset: elements_offset(indices.len())?,
    })
}

pub(crate) fn locate_verified((words, base): (Value, Value), index: Value) -> Option<Located> {
    Some(Located {
        words,
        base,
        linear: index,
        offset: elements_offset(1)?,
    })
}

fn extent_offset(rank: usize, position: usize) -> Option<i32> {
    if rank <= 1 {
        return Some(TOTAL_WORD);
    }
    ELEMENTS_START_BASE
        .checked_add(position)
        .and_then(|word| word.checked_mul(8))
        .and_then(|bytes| i32::try_from(bytes).ok())
}

fn elements_offset(rank: usize) -> Option<i32> {
    if rank <= 1 {
        return Some(ELEMENTS_START_RANK_ONE);
    }
    ELEMENTS_START_BASE
        .checked_add(rank)
        .and_then(|word| word.checked_mul(8))
        .and_then(|bytes| i32::try_from(bytes).ok())
}

pub(crate) fn element_address(lowering: &mut Lowering<'_, '_>, located: &Located) -> Value {
    element_slot(lowering, located.base, located.linear)
}

pub(crate) fn require_present(lowering: &mut Lowering<'_, '_>, handle: Value, slow: Block) {
    let present = is_present(lowering, handle);
    branch_unless(lowering, present, slow);
}

pub(crate) fn require_dense(lowering: &mut Lowering<'_, '_>, located: &Located, slow: Block) {
    let flags = MemFlagsData::trusted();
    let total = lowering
        .builder
        .ins()
        .load(types::I64, flags, located.base, TOTAL_WORD);
    let boundary = lowering
        .builder
        .ins()
        .load(types::I64, flags, located.base, BOUNDARY_WORD);
    let dense = lowering.builder.ins().icmp(IntCC::Equal, total, boundary);
    let accepted = lowering.builder.create_block();
    let masked = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(dense, accepted, &[], masked, &[]);
    lowering.builder.switch_to_block(masked);
    let definition = definition_bit(lowering, located);
    let selected = lowering
        .builder
        .ins()
        .band(definition.current, definition.bit);
    let defined = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::NotEqual, selected, 0);
    lowering
        .builder
        .ins()
        .brif(defined, accepted, &[], slow, &[]);
    lowering.builder.switch_to_block(accepted);
}

pub(crate) fn define_integer(lowering: &mut Lowering<'_, '_>, located: &Located) {
    let flags = MemFlagsData::trusted();
    let total = lowering
        .builder
        .ins()
        .load(types::I64, flags, located.base, TOTAL_WORD);
    let boundary = lowering
        .builder
        .ins()
        .load(types::I64, flags, located.base, BOUNDARY_WORD);
    let dense = lowering.builder.ins().icmp(IntCC::Equal, total, boundary);
    let store = lowering.builder.create_block();
    let masked = lowering.builder.create_block();
    lowering.builder.ins().brif(dense, store, &[], masked, &[]);
    lowering.builder.switch_to_block(masked);
    mark_defined(lowering, located, (boundary, total), store);
    lowering.builder.switch_to_block(store);
}

struct DefinitionBit {
    slot: Value,
    current: Value,
    bit: Value,
}

fn definition_bit(lowering: &mut Lowering<'_, '_>, located: &Located) -> DefinitionBit {
    let flags = MemFlagsData::trusted();
    let map = lowering
        .builder
        .ins()
        .load(types::I64, flags, located.base, MASK_WORD);
    let group = lowering.builder.ins().ushr_imm_u(located.linear, 6);
    let position = lowering.builder.ins().iadd(map, group);
    let slot = element_slot(lowering, located.words, position);
    let current = lowering.builder.ins().load(types::I64, flags, slot, 0);
    let shift = lowering.builder.ins().band_imm_u(located.linear, 63);
    let one = lowering.builder.ins().iconst(types::I64, 1);
    let bit = lowering.builder.ins().ishl(one, shift);
    DefinitionBit { slot, current, bit }
}

fn mark_defined(
    lowering: &mut Lowering<'_, '_>,
    located: &Located,
    (boundary, total): (Value, Value),
    store: Block,
) {
    let definition = definition_bit(lowering, located);
    let already = lowering
        .builder
        .ins()
        .band(definition.current, definition.bit);
    let defined = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::NotEqual, already, 0);
    let record = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(defined, store, &[], record, &[]);
    lowering.builder.switch_to_block(record);
    record_definition(lowering, &definition);
    advance_boundary(lowering, located, (boundary, total), store);
}

fn record_definition(lowering: &mut Lowering<'_, '_>, definition: &DefinitionBit) {
    let updated = lowering
        .builder
        .ins()
        .bor(definition.current, definition.bit);
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), updated, definition.slot, 0);
}

fn advance_boundary(
    lowering: &mut Lowering<'_, '_>,
    located: &Located,
    (boundary, total): (Value, Value),
    store: Block,
) {
    let flags = MemFlagsData::trusted();
    let advanced = lowering.builder.ins().iadd_imm_s(boundary, 1);
    lowering
        .builder
        .ins()
        .store(flags, advanced, located.base, BOUNDARY_WORD);
    let complete = lowering.builder.ins().icmp(IntCC::Equal, advanced, total);
    let clear = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(complete, clear, &[], store, &[]);
    lowering.builder.switch_to_block(clear);
    let zero = lowering.builder.ins().iconst(types::I64, 0);
    lowering
        .builder
        .ins()
        .store(flags, zero, located.base, MASK_WORD);
    lowering.builder.ins().jump(store, &[]);
}
