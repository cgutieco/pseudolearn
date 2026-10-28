#![forbid(unsafe_code)]

mod definedness;
mod definitions;
mod edges;
mod indirect_targets;
mod init;
mod instructions;
pub(crate) mod memory;
mod metadata;
mod operands;
mod parallel_copy;

#[cfg(test)]
mod parallel_copy_tests;

use std::sync::Arc;

use pseudolearn_bytecode::{BytecodeFunction, BytecodeModule, RegisterClass, VerifiedBytecode};

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
        .map(|function| load_function(module, function, &literals).map(Arc::new))
        .collect::<Result<Vec<_>, _>>()?;
    Ok(LoadedProgram::new(model::LoadedProgramInner {
        name: module.name.clone(),
        functions,
        entry,
        literals,
        classes: module.classes.clone(),
        vocabulary: module.vocabulary.clone(),
        profiles: module.profiles.clone(),
        layouts: metadata::layouts(module)?,
    }))
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
    let mut loaded = init::init_loaded_function(function)?;
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

pub(crate) use instructions::task_results::TaskSite;
