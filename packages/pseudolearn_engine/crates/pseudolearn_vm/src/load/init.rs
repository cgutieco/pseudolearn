#![forbid(unsafe_code)]

use super::metadata;
use super::model::{LoadedFunction, Origin};
use crate::VmTrap;
use crate::dispatch::Op;
use pseudolearn_bytecode::{BasicBlock, BytecodeFunction, ReturnPoint, SourceSpan};

struct CodeBuffers {
    code: Vec<Op>,
    mask: usize,
    spans: Vec<Option<SourceSpan>>,
    origins: Vec<Origin>,
    probed_code: Vec<Op>,
    probed_mask: usize,
    probed_spans: Vec<Option<SourceSpan>>,
    probed_origins: Vec<Origin>,
    roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
    probed_roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
}

fn code_buffers(function: &BytecodeFunction) -> Result<CodeBuffers, VmTrap> {
    Ok(CodeBuffers {
        code: Vec::with_capacity(function.fast.instructions.len()),
        mask: function.fast.instructions.len().saturating_sub(1),
        spans: metadata::spans(function, false),
        origins: Vec::with_capacity(function.fast.instructions.len()),
        probed_code: Vec::with_capacity(function.probed.instructions.len()),
        probed_mask: function.probed.instructions.len().saturating_sub(1),
        probed_spans: metadata::spans(function, true),
        probed_origins: Vec::with_capacity(function.probed.instructions.len()),
        roots: metadata::roots(function, false)?,
        probed_roots: metadata::roots(function, true)?,
    })
}

struct FunctionMappings {
    fast_to_probed_blocks: Vec<usize>,
    probed_to_fast_blocks: Vec<usize>,
    fast_to_probed_returns: Vec<usize>,
    probed_to_fast_returns: Vec<usize>,
}

fn function_mappings(function: &BytecodeFunction) -> FunctionMappings {
    let (fast_to_probed_blocks, probed_to_fast_blocks) =
        block_mappings(&function.fast.blocks, &function.probed.blocks);
    let (fast_to_probed_returns, probed_to_fast_returns) =
        return_mappings(&function.return_points);
    FunctionMappings {
        fast_to_probed_blocks,
        probed_to_fast_blocks,
        fast_to_probed_returns,
        probed_to_fast_returns,
    }
}

pub(super) fn init_loaded_function(function: &BytecodeFunction) -> Result<LoadedFunction, VmTrap> {
    let mappings = function_mappings(function);
    let windows = function_windows(function)?;
    let buffers = code_buffers(function)?;
    let entry_mass = metadata::entry_mass(function);
    let continuations = continuations(function)?;
    let mut loaded = create_skeleton(function, mappings, windows);
    attach_execution_buffers(&mut loaded, buffers, continuations, entry_mass);
    Ok(loaded)
}

fn create_skeleton(
    function: &BytecodeFunction,
    mappings: FunctionMappings,
    windows: (usize, usize),
) -> LoadedFunction {
    LoadedFunction {
        visibility: function.visibility.clone(),
        name: function.name.clone(),
        declaration_span: function.declaration_span,
        names: function.names.clone(),
        scalar_types: function.scalar_types.clone(),
        reference_types: function.reference_types.clone(),
        fast_to_probed_blocks: mappings.fast_to_probed_blocks,
        probed_to_fast_blocks: mappings.probed_to_fast_blocks,
        fast_to_probed_returns: mappings.fast_to_probed_returns,
        probed_to_fast_returns: mappings.probed_to_fast_returns,
        scalar_window: windows.0,
        reference_window: windows.1,
        ..Default::default()
    }
}

fn attach_execution_buffers(
    loaded: &mut LoadedFunction,
    buffers: CodeBuffers,
    continuations: Vec<usize>,
    entry_mass: u64,
) {
    loaded.code = buffers.code;
    loaded.mask = buffers.mask;
    loaded.spans = buffers.spans;
    loaded.origins = buffers.origins;
    loaded.probed_code = buffers.probed_code;
    loaded.probed_mask = buffers.probed_mask;
    loaded.probed_spans = buffers.probed_spans;
    loaded.probed_origins = buffers.probed_origins;
    loaded.roots = buffers.roots;
    loaded.probed_roots = buffers.probed_roots;
    loaded.continuations = continuations;
    loaded.entry_mass = entry_mass;
}

pub(super) fn function_windows(function: &BytecodeFunction) -> Result<(usize, usize), VmTrap> {
    Ok((
        window(function.scalar_types.len())?,
        window(function.reference_types.len())?,
    ))
}

fn block_mappings(
    fast_blocks: &[BasicBlock],
    probed_blocks: &[BasicBlock],
) -> (Vec<usize>, Vec<usize>) {
    let fast_max = fast_blocks
        .iter()
        .map(|block| usize::try_from(block.start_pc).unwrap_or(0))
        .max()
        .unwrap_or(0);
    let probed_max = probed_blocks
        .iter()
        .map(|block| usize::try_from(block.start_pc).unwrap_or(0))
        .max()
        .unwrap_or(0);
    let mut fast_to_probed = vec![0; fast_max.saturating_add(1)];
    let mut probed_to_fast = vec![0; probed_max.saturating_add(1)];
    for fast_block in fast_blocks {
        if let Some(probed_block) = probed_blocks
            .iter()
            .find(|candidate| candidate.identifier == fast_block.identifier)
        {
            let fast_pc = usize::try_from(fast_block.start_pc).unwrap_or(0);
            let probed_pc = usize::try_from(probed_block.start_pc).unwrap_or(0);
            if let Some(target) = fast_to_probed.get_mut(fast_pc) {
                *target = probed_pc;
            }
            if let Some(target) = probed_to_fast.get_mut(probed_pc) {
                *target = fast_pc;
            }
        }
    }
    (fast_to_probed, probed_to_fast)
}

fn return_mappings(return_points: &[ReturnPoint]) -> (Vec<usize>, Vec<usize>) {
    let fast_max = return_points
        .iter()
        .map(|point| usize::try_from(point.fast_continuation_pc).unwrap_or(0))
        .max()
        .unwrap_or(0);
    let probed_max = return_points
        .iter()
        .map(|point| usize::try_from(point.probed_continuation_pc).unwrap_or(0))
        .max()
        .unwrap_or(0);
    let mut fast_to_probed = vec![0; fast_max.saturating_add(1)];
    let mut probed_to_fast = vec![0; probed_max.saturating_add(1)];
    for point in return_points {
        let fast_pc = usize::try_from(point.fast_continuation_pc).unwrap_or(0);
        let probed_pc = usize::try_from(point.probed_continuation_pc).unwrap_or(0);
        if let Some(target) = fast_to_probed.get_mut(fast_pc) {
            *target = probed_pc;
        }
        if let Some(target) = probed_to_fast.get_mut(probed_pc) {
            *target = fast_pc;
        }
    }
    (fast_to_probed, probed_to_fast)
}

pub(super) fn window(register_count: usize) -> Result<usize, VmTrap> {
    let size = register_count.checked_add(1).ok_or_else(super::invalid_bytecode)?;
    if u16::try_from(register_count).is_err() {
        return Err(super::invalid_bytecode());
    }
    Ok(size)
}

pub(super) fn continuations(function: &BytecodeFunction) -> Result<Vec<usize>, VmTrap> {
    let mut table = vec![usize::MAX; function.return_points.len()];
    for point in &function.return_points {
        let slot = usize::try_from(point.identifier)
            .ok()
            .and_then(|identifier| table.get_mut(identifier))
            .ok_or_else(super::invalid_bytecode)?;
        *slot = usize::try_from(point.fast_continuation_pc).map_err(|_| super::invalid_bytecode())?;
    }
    if table.contains(&usize::MAX) {
        return Err(super::invalid_bytecode());
    }
    Ok(table)
}
