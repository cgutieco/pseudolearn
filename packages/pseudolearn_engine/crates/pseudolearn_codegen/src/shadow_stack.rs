#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, guard_trap};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};

pub(crate) struct RootFrame {
    previous_top: Value,
}

fn live_handles(lowering: &Lowering<'_, '_>, instruction: &Instruction<'_>) -> Vec<Value> {
    lowering
        .live_roots
        .get(&instruction.identifier)
        .map(|live| {
            live.iter()
                .filter_map(|value| lowering.values.get(value).copied())
                .collect()
        })
        .unwrap_or_default()
}

pub(crate) fn push_roots(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<Option<RootFrame>, CodegenError> {
    let handles = live_handles(lowering, instruction);
    if handles.is_empty() {
        return Ok(None);
    }
    let layout = lowering.environment.layout;
    let context = lowering.context;
    let flags = MemFlagsData::trusted();
    let top = lowering
        .builder
        .ins()
        .load(types::I32, flags, context, layout.root_top);
    let count = i64::try_from(handles.len())
        .map_err(|_| CodegenError::InvalidModule("too many live references"))?;
    let new_top = lowering.builder.ins().iadd_imm_s(top, count);
    let capacity = lowering
        .builder
        .ins()
        .load(types::I32, flags, context, layout.root_capacity);
    let overflow = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedGreaterThan, new_top, capacity);
    guard_trap(lowering, overflow, "internalFault", instruction.span)?;
    store_handles(lowering, top, &handles)?;
    lowering
        .builder
        .ins()
        .store(flags, new_top, context, layout.root_top);
    Ok(Some(RootFrame { previous_top: top }))
}

fn store_handles(
    lowering: &mut Lowering<'_, '_>,
    top: Value,
    handles: &[Value],
) -> Result<(), CodegenError> {
    let layout = lowering.environment.layout;
    let pointer = lowering.environment.frontend.pointer_type();
    let flags = MemFlagsData::trusted();
    let base = lowering
        .builder
        .ins()
        .load(pointer, flags, lowering.context, layout.roots_pointer);
    let wide = lowering.builder.ins().uextend(pointer, top);
    let scaled = lowering.builder.ins().ishl_imm_u(wide, 2);
    let start = lowering.builder.ins().iadd(base, scaled);
    for (position, handle) in handles.iter().enumerate() {
        let offset = position
            .checked_mul(4)
            .and_then(|bytes| i32::try_from(bytes).ok())
            .ok_or(CodegenError::InvalidModule("too many live references"))?;
        lowering.builder.ins().store(flags, *handle, start, offset);
    }
    Ok(())
}

pub(crate) fn pop_roots(lowering: &mut Lowering<'_, '_>, frame: Option<RootFrame>) {
    if let Some(frame) = frame {
        let offset = lowering.environment.layout.root_top;
        lowering.builder.ins().store(
            MemFlagsData::trusted(),
            frame.previous_top,
            lowering.context,
            offset,
        );
    }
}
