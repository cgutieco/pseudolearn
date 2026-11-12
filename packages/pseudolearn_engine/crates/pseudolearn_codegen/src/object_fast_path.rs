#![forbid(unsafe_code)]

use crate::lowering::Lowering;
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{Block, InstBuilder, MemFlagsData, Value, types};

const DENSE_PAYLOAD: i64 = 2;
const MASK_START_WORD: u32 = 2;

pub(crate) fn mask_location(index: u32) -> Option<(i32, i64)> {
    let word = MASK_START_WORD.checked_add(index.checked_div(64)?)?;
    let offset = i32::try_from(word.checked_mul(8)?).ok()?;
    let bit = 1_u64.checked_shl(index.checked_rem(64)?)?;
    Some((offset, i64::from_ne_bytes(bit.to_ne_bytes())))
}

pub(crate) fn require_defined(
    lowering: &mut Lowering<'_, '_>,
    (base, payload, index): (Value, Value, u32),
    slow: Block,
) -> Option<()> {
    let (offset, bit) = mask_location(index)?;
    let dense = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::Equal, payload, DENSE_PAYLOAD);
    let accepted = lowering.builder.create_block();
    let masked = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(dense, accepted, &[], masked, &[]);
    lowering.builder.switch_to_block(masked);
    let word = lowering
        .builder
        .ins()
        .load(types::I64, MemFlagsData::trusted(), base, offset);
    let selected = lowering.builder.ins().band_imm_s(word, bit);
    let defined = lowering.builder.ins().icmp_imm_s(IntCC::Equal, selected, 0);
    lowering
        .builder
        .ins()
        .brif(defined, accepted, &[], slow, &[]);
    lowering.builder.switch_to_block(accepted);
    Some(())
}

pub(crate) fn define(
    lowering: &mut Lowering<'_, '_>,
    (base, payload, index): (Value, Value, u32),
) -> Option<()> {
    let (offset, bit) = mask_location(index)?;
    let dense = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::Equal, payload, DENSE_PAYLOAD);
    let stored = lowering.builder.create_block();
    let masked = lowering.builder.create_block();
    lowering.builder.ins().brif(dense, stored, &[], masked, &[]);
    lowering.builder.switch_to_block(masked);
    let flags = MemFlagsData::trusted();
    let word = lowering.builder.ins().load(types::I64, flags, base, offset);
    let cleared = lowering.builder.ins().band_imm_s(word, !bit);
    lowering.builder.ins().store(flags, cleared, base, offset);
    lowering.builder.ins().jump(stored, &[]);
    lowering.builder.switch_to_block(stored);
    Some(())
}
