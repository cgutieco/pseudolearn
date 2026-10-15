#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BasicBlock, BytecodeFunction, BytecodeModule, Instruction, VerifiedBytecode,
};

use crate::VmTrap;

pub(super) fn fetch_instruction(
    program: &VerifiedBytecode,
    function_index: u16,
    program_counter: u32,
) -> Result<&Instruction, VmTrap> {
    let position =
        usize::try_from(program_counter).map_err(|_| VmTrap::new("invalidBytecode", None))?;
    function_at(program.module(), function_index)?
        .fast
        .instructions
        .get(position)
        .ok_or_else(|| VmTrap::new("invalidBytecode", None))
}

pub(super) fn entry_index(module: &BytecodeModule) -> Result<u16, VmTrap> {
    module
        .functions
        .iter()
        .position(|function| function.name.trim_start_matches('@') == "main")
        .and_then(|index| u16::try_from(index).ok())
        .ok_or_else(|| VmTrap::new("missingEntryPoint", None))
}

pub(super) fn function_at(
    module: &BytecodeModule,
    index: u16,
) -> Result<&BytecodeFunction, VmTrap> {
    module
        .functions
        .get(usize::from(index))
        .ok_or_else(|| VmTrap::new("invalidBytecode", None))
}

pub(super) fn is_empty_backedge(source_pc: u32, target: &BasicBlock) -> bool {
    target.start_pc <= source_pc && target.mass == 0
}
