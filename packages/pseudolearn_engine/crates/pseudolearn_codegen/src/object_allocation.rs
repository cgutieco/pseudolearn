#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::inline_memory::{begin_fast_path, branch_unless, finish_fast_path, heap_base};
use crate::lower_objects::allocate_handle;
use crate::lowering::{Instruction, Lowering};
use crate::shadow_stack::live_count;
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{BlockArg, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_aot_rt::{INLINE_PHYSICAL_SHIFT, INLINE_RECORD_WORDS, InlineObjectImage};

struct Window {
    used: Value,
    ordinal: Value,
    pending_length: Value,
}

pub(crate) fn allocate_inline(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (image, class_value): (&InlineObjectImage, Value),
) -> Result<Value, CodegenError> {
    let joined = begin_fast_path(lowering, Some(types::I32));
    let window = guard_window(lowering, instruction, image, joined.slow)?;
    let handle = write_object(lowering, image, &window)?;
    lowering
        .builder
        .ins()
        .jump(joined.merge, &[BlockArg::Value(handle)]);
    lowering.builder.switch_to_block(joined.slow);
    let fallback = allocate_handle(lowering, instruction, (Entry::ObjectNew, class_value))?;
    lowering
        .builder
        .ins()
        .jump(joined.merge, &[BlockArg::Value(fallback)]);
    finish_fast_path(lowering, &joined)
        .ok_or(CodegenError::InvalidModule("allocation without result"))
}

fn load_word(lowering: &mut Lowering<'_, '_>, offset: i32) -> Value {
    lowering.builder.ins().load(
        types::I64,
        MemFlagsData::trusted(),
        lowering.context,
        offset,
    )
}

fn store_word(lowering: &mut Lowering<'_, '_>, value: Value, offset: i32) {
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), value, lowering.context, offset);
}

fn guard_window(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    image: &InlineObjectImage,
    slow: cranelift_codegen::ir::Block,
) -> Result<Window, CodegenError> {
    guard_collection_room(lowering, image, slow)?;
    let layout = lowering.environment.layout.allocation;
    let used = load_word(lowering, layout.used);
    let end = lowering
        .builder
        .ins()
        .iadd_imm_s(used, i64::from(image.physical));
    let limit = load_word(lowering, layout.limit);
    let inside = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedLessThanOrEqual, end, limit);
    branch_unless(lowering, inside, slow);
    let pending_length = load_word(lowering, layout.pending_length);
    let capacity = load_word(lowering, layout.pending_capacity);
    let vacant = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedLessThan, pending_length, capacity);
    branch_unless(lowering, vacant, slow);
    guard_roots(lowering, instruction, slow)?;
    let ordinal = load_word(lowering, layout.ordinal);
    Ok(Window {
        used,
        ordinal,
        pending_length,
    })
}

fn guard_collection_room(
    lowering: &mut Lowering<'_, '_>,
    image: &InlineObjectImage,
    slow: cranelift_codegen::ir::Block,
) -> Result<(), CodegenError> {
    let layout = lowering.environment.layout.allocation;
    let cells = i64::try_from(image.cells)
        .map_err(|_| CodegenError::InvalidModule("object cells out of range"))?;
    let mask = load_word(lowering, layout.free_size_mask);
    let bit = 1_i64.wrapping_shl(image.physical.min(63));
    let taken = lowering.builder.ins().band_imm_s(mask, bit);
    let free = lowering.builder.ins().icmp_imm_s(IntCC::Equal, taken, 0);
    branch_unless(lowering, free, slow);
    let threshold = load_word(lowering, layout.room_threshold);
    let below = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::SignedGreaterThan, threshold, 0);
    branch_unless(lowering, below, slow);
    let room = load_word(lowering, layout.room_cells);
    let fits = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::SignedGreaterThanOrEqual, room, cells);
    branch_unless(lowering, fits, slow);
    Ok(())
}

fn guard_roots(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    slow: cranelift_codegen::ir::Block,
) -> Result<(), CodegenError> {
    let live = live_count(lowering, instruction);
    if live == 0 {
        return Ok(());
    }
    let layout = lowering.environment.layout;
    let flags = MemFlagsData::trusted();
    let count =
        i64::try_from(live).map_err(|_| CodegenError::InvalidModule("too many live references"))?;
    let top = lowering
        .builder
        .ins()
        .load(types::I32, flags, lowering.context, layout.root_top);
    let capacity =
        lowering
            .builder
            .ins()
            .load(types::I32, flags, lowering.context, layout.root_capacity);
    let new_top = lowering.builder.ins().iadd_imm_s(top, count);
    let within = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedLessThanOrEqual, new_top, capacity);
    branch_unless(lowering, within, slow);
    Ok(())
}

fn write_object(
    lowering: &mut Lowering<'_, '_>,
    image: &InlineObjectImage,
    window: &Window,
) -> Result<Value, CodegenError> {
    let layout = lowering.environment.layout.allocation;
    let flags = MemFlagsData::trusted();
    let handle = lowering.builder.ins().ireduce(types::I32, window.used);
    let (_, base) = heap_base(lowering, handle);
    let header = lowering
        .builder
        .ins()
        .iconst(types::I64, i64::from_ne_bytes(image.header.to_ne_bytes()));
    let identity = lowering.builder.ins().iadd_imm_s(window.ordinal, 1);
    lowering.builder.ins().store(flags, header, base, 0);
    lowering.builder.ins().store(flags, identity, base, 8);
    for (position, word) in image.words.iter().enumerate() {
        let offset = position
            .checked_add(2)
            .and_then(|slot| slot.checked_mul(8))
            .and_then(|bytes| i32::try_from(bytes).ok())
            .ok_or(CodegenError::InvalidModule("object image too large"))?;
        let constant = lowering
            .builder
            .ins()
            .iconst(types::I64, i64::from_ne_bytes(word.to_ne_bytes()));
        lowering.builder.ins().store(flags, constant, base, offset);
    }
    store_word(lowering, identity, layout.ordinal);
    advance_window(lowering, image, window)?;
    register_block(lowering, image, (window, handle))?;
    Ok(handle)
}

fn advance_window(
    lowering: &mut Lowering<'_, '_>,
    image: &InlineObjectImage,
    window: &Window,
) -> Result<(), CodegenError> {
    let layout = lowering.environment.layout.allocation;
    let cells = i64::try_from(image.cells)
        .map_err(|_| CodegenError::InvalidModule("object cells out of range"))?;
    let advanced = lowering
        .builder
        .ins()
        .iadd_imm_s(window.used, i64::from(image.physical));
    store_word(lowering, advanced, layout.used);
    for offset in [layout.room_cells, layout.room_threshold] {
        let current = load_word(lowering, offset);
        let reduced = lowering
            .builder
            .ins()
            .iadd_imm_s(current, cells.wrapping_neg());
        store_word(lowering, reduced, offset);
    }
    Ok(())
}

fn register_block(
    lowering: &mut Lowering<'_, '_>,
    image: &InlineObjectImage,
    (window, handle): (&Window, Value),
) -> Result<(), CodegenError> {
    let layout = lowering.environment.layout.allocation;
    let flags = MemFlagsData::trusted();
    let pointer = lowering.environment.frontend.pointer_type();
    let table =
        lowering
            .builder
            .ins()
            .load(pointer, flags, lowering.context, layout.pending_pointer);
    let record_bytes = i64::try_from(INLINE_RECORD_WORDS)
        .ok()
        .and_then(|words| words.checked_mul(8))
        .ok_or(CodegenError::InvalidModule("pending record size"))?;
    let scaled = lowering
        .builder
        .ins()
        .imul_imm_s(window.pending_length, record_bytes);
    let record = lowering.builder.ins().iadd(table, scaled);
    let wide = lowering.builder.ins().uextend(types::I64, handle);
    let shape = i64::from(image.physical).wrapping_shl(INLINE_PHYSICAL_SHIFT);
    let packed = lowering.builder.ins().bor_imm_s(wide, shape);
    let cells = i64::try_from(image.cells)
        .map_err(|_| CodegenError::InvalidModule("object cells out of range"))?;
    let cell_count = lowering.builder.ins().iconst(types::I64, cells);
    lowering.builder.ins().store(flags, packed, record, 0);
    lowering.builder.ins().store(flags, cell_count, record, 8);
    let length = lowering.builder.ins().iadd_imm_s(window.pending_length, 1);
    store_word(lowering, length, layout.pending_length);
    Ok(())
}
