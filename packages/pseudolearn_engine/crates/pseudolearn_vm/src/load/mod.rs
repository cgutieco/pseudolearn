#![forbid(unsafe_code)]

mod definedness;
mod definitions;
mod edges;
mod instructions;
pub(crate) mod memory;
mod metadata;
mod operands;
mod parallel_copy;

#[cfg(test)]
mod parallel_copy_tests;

use pseudolearn_bytecode::{
    BasicBlock, BytecodeFunction, BytecodeModule, RegisterClass, ReturnPoint, VerifiedBytecode,
};

use crate::VmTrap;
use definedness::Definedness;

pub(crate) mod model;
pub use model::LoadedProgram;
pub(crate) use model::{
    CallSite, Definition, Edge, LoadedFunction, Move, Origin, Sentinel, Source,
};

pub fn load(program: &VerifiedBytecode) -> Result<LoadedProgram, VmTrap> {
    let module = program.module();
    let entry = module
        .functions
        .iter()
        .position(|function| function.name.trim_start_matches('@') == "main")
        .ok_or_else(|| VmTrap::new("missingEntryPoint", None))?;
    let literals = metadata::literals(module);
    let functions = module
        .functions
        .iter()
        .map(|function| load_function(module, function, &literals))
        .collect::<Result<Vec<_>, _>>()?;
    Ok(LoadedProgram {
        functions,
        entry,
        literals,
        classes: module.classes.clone(),
        layouts: metadata::layouts(module)?,
        vocabulary: module.vocabulary.clone(),
    })
}

pub(crate) fn invalid_bytecode() -> VmTrap {
    VmTrap::new("invalidBytecode", None)
}

fn load_function(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    literals: &[String],
) -> Result<LoadedFunction, VmTrap> {
    let definedness = Definedness::analyze(function);
    let mut loaded = init_loaded_function(function)?;
    let context = instructions::DecodeContext {
        module,
        function,
        definedness: &definedness,
        literals,
    };
    instructions::decode_all(&context, &mut loaded)?;
    reserve_outgoing(&mut loaded, function)?;
    if !loaded.code.len().is_power_of_two() || !loaded.probed_code.len().is_power_of_two() {
        return Err(invalid_bytecode());
    }
    Ok(loaded)
}

fn init_loaded_function(function: &BytecodeFunction) -> Result<LoadedFunction, VmTrap> {
    let (fast_to_probed_blocks, probed_to_fast_blocks) =
        block_mappings(&function.fast.blocks, &function.probed.blocks);
    let (fast_to_probed_returns, probed_to_fast_returns) = return_mappings(&function.return_points);
    Ok(LoadedFunction {
        name: function.name.clone(),
        declaration_span: function.declaration_span,
        names: function.names.clone(),
        scalar_types: function.scalar_types.clone(),
        reference_types: function.reference_types.clone(),
        code: Vec::with_capacity(function.fast.instructions.len()),
        mask: function.fast.instructions.len().saturating_sub(1),
        spans: metadata::spans(function, false),
        origins: Vec::with_capacity(function.fast.instructions.len()),
        probed_code: Vec::with_capacity(function.probed.instructions.len()),
        probed_mask: function.probed.instructions.len().saturating_sub(1),
        probed_spans: metadata::spans(function, true),
        probed_origins: Vec::with_capacity(function.probed.instructions.len()),
        observations: Vec::new(),
        fast_to_probed_blocks,
        probed_to_fast_blocks,
        fast_to_probed_returns,
        probed_to_fast_returns,
        edges: Vec::new(),
        moves: Vec::new(),
        calls: Vec::new(),
        continuations: continuations(function)?,
        scalar_window: window(function.scalar_types.len())?,
        reference_window: window(function.reference_types.len())?,
        scalar_outgoing: 0,
        reference_outgoing: 0,
        entry_mass: metadata::entry_mass(function),
        memory: Vec::new(),
        roots: metadata::roots(function)?,
    })
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

fn window(register_count: usize) -> Result<usize, VmTrap> {
    let size = register_count.checked_add(1).ok_or_else(invalid_bytecode)?;
    if u16::try_from(register_count).is_err() {
        return Err(invalid_bytecode());
    }
    Ok(size)
}

fn reserve_outgoing(
    loaded: &mut LoadedFunction,
    function: &BytecodeFunction,
) -> Result<(), VmTrap> {
    for instruction in &function.fast.instructions {
        for operand in &instruction.operands {
            if let pseudolearn_bytecode::BytecodeOperand::FunctionTarget { arguments, .. } = operand
            {
                let scalars = arguments
                    .iter()
                    .filter(|register| register.class == RegisterClass::Scalar)
                    .count();
                let references = arguments.len().saturating_sub(scalars);
                loaded.scalar_outgoing = loaded.scalar_outgoing.max(scalars);
                loaded.reference_outgoing = loaded.reference_outgoing.max(references);
            }
        }
    }
    loaded.scalar_window = loaded
        .scalar_window
        .checked_add(loaded.scalar_outgoing)
        .ok_or_else(invalid_bytecode)?;
    loaded.reference_window = loaded
        .reference_window
        .checked_add(loaded.reference_outgoing)
        .ok_or_else(invalid_bytecode)?;
    Ok(())
}

pub(crate) fn scratch_register(
    function: &BytecodeFunction,
    class: RegisterClass,
) -> Result<u16, VmTrap> {
    let count = match class {
        RegisterClass::Scalar => function.scalar_types.len(),
        RegisterClass::Reference => function.reference_types.len(),
    };
    u16::try_from(count).map_err(|_| invalid_bytecode())
}

fn continuations(function: &BytecodeFunction) -> Result<Vec<usize>, VmTrap> {
    let mut table = vec![usize::MAX; function.return_points.len()];
    for point in &function.return_points {
        let slot = usize::try_from(point.identifier)
            .ok()
            .and_then(|identifier| table.get_mut(identifier))
            .ok_or_else(invalid_bytecode)?;
        *slot = usize::try_from(point.fast_continuation_pc).map_err(|_| invalid_bytecode())?;
    }
    if table.contains(&usize::MAX) {
        return Err(invalid_bytecode());
    }
    Ok(table)
}
