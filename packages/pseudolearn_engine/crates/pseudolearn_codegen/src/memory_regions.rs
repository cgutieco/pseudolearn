#![forbid(unsafe_code)]

use crate::context_layout::ContextLayout;
use cranelift_codegen::ir::{
    AliasRegion, AliasRegionData, Function, InstructionData, Opcode, Value, ValueDef,
};

pub(crate) fn assign(function: &mut Function, layout: ContextLayout) {
    let Some(entry) = function.layout.entry_block() else {
        return;
    };
    let Some(context) = function.dfg.block_params(entry).first().copied() else {
        return;
    };
    let regions = declare_regions(function);
    let instructions: Vec<_> = function
        .layout
        .blocks()
        .flat_map(|block| function.layout.block_insts(block))
        .collect();
    for instruction in instructions {
        let (address, flags) = match function.dfg.insts[instruction] {
            InstructionData::Load { arg, flags, .. } => (arg, flags),
            InstructionData::Store {
                args: [_, address],
                flags,
                ..
            } => (address, flags),
            _ => continue,
        };
        let Some(position) = classify(function, context, address, (layout, 0)) else {
            continue;
        };
        let region: Option<AliasRegion> = regions.get(position).copied();
        let flags = function.dfg.mem_flags[flags].with_alias_region(region);
        let interned = function.dfg.mem_flags.insert_unchecked(flags);
        match &mut function.dfg.insts[instruction] {
            InstructionData::Load { flags, .. } | InstructionData::Store { flags, .. } => {
                *flags = interned
            }
            _ => {}
        }
    }
}

fn classify(
    function: &Function,
    context: Value,
    address: Value,
    (layout, depth): (ContextLayout, u32),
) -> Option<usize> {
    let address = function.dfg.resolve_aliases(address);
    if address == context {
        return Some(0);
    }
    if depth >= 12 {
        return None;
    }
    let ValueDef::Result(instruction, _) = function.dfg.value_def(address) else {
        return None;
    };
    match function.dfg.insts[instruction] {
        InstructionData::Load { arg, offset, .. }
            if function.dfg.resolve_aliases(arg) == context =>
        {
            match i32::from(offset) {
                offset if offset == layout.heap_words => Some(1),
                offset if offset == layout.cells_pointer => Some(2),
                offset if offset == layout.roots_pointer => Some(3),
                _ => None,
            }
        }
        InstructionData::Binary {
            opcode: Opcode::Iadd,
            args: [left, right],
        } => classify(function, context, left, (layout, depth.saturating_add(1)))
            .or_else(|| classify(function, context, right, (layout, depth.saturating_add(1)))),
        _ => None,
    }
}

fn declare_regions(function: &mut Function) -> Vec<AliasRegion> {
    ["context", "heap", "cells", "roots"]
        .into_iter()
        .enumerate()
        .map(|(position, description)| {
            function.dfg.alias_regions.insert(AliasRegionData {
                user_id: u32::try_from(position).unwrap_or(0),
                description: description.into(),
            })
        })
        .collect()
}
