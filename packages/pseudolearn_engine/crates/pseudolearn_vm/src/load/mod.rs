#![forbid(unsafe_code)]

mod definedness;
mod edges;
mod instructions;
mod operands;
mod parallel_copy;

#[cfg(test)]
mod parallel_copy_tests;

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeModule, Opcode, Register, RegisterClass, SourceSpan, VerifiedBytecode,
};

use crate::VmTrap;
use crate::dispatch::Op;
use definedness::Definedness;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Source {
    Register(u16),
    Immediate(u64),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Sentinel {
    Real,
    Boolean,
    Character,
    Unit,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Definition {
    Untracked,
    Defined,
    Undefined,
    Copied,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct Move {
    pub source: u16,
    pub destination: u16,
    pub class: RegisterClass,
    pub definition: Definition,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct Edge {
    pub target: usize,
    pub mass: u64,
    pub probe: bool,
    pub moves_start: usize,
    pub moves_end: usize,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct CallSite {
    pub function: usize,
    pub destination: Option<Register>,
    pub return_point: usize,
    pub arguments_start: usize,
    pub arguments_end: usize,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub(crate) struct Origin {
    pub first: Option<Opcode>,
    pub second: Option<Opcode>,
}

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct LoadedFunction {
    pub code: Vec<Op>,
    pub mask: usize,
    pub spans: Vec<Option<SourceSpan>>,
    pub origins: Vec<Origin>,
    pub edges: Vec<Edge>,
    pub moves: Vec<Move>,
    pub calls: Vec<CallSite>,
    pub continuations: Vec<usize>,
    pub scalar_window: usize,
    pub reference_window: usize,
    pub entry_mass: u64,
}

impl LoadedFunction {
    #[inline(always)]
    pub(crate) fn operation(&self, program_counter: usize) -> Op {
        self.code
            .get(program_counter & self.mask)
            .copied()
            .unwrap_or(Op::Unreachable)
    }

    pub(crate) fn span(&self, program_counter: usize) -> Option<SourceSpan> {
        self.spans.get(program_counter).copied().flatten()
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct LoadedProgram {
    pub(crate) functions: Vec<LoadedFunction>,
    pub(crate) entry: usize,
}

pub fn load(program: &VerifiedBytecode) -> Result<LoadedProgram, VmTrap> {
    let module = program.module();
    let entry = module
        .functions
        .iter()
        .position(|function| function.name.trim_start_matches('@') == "main")
        .ok_or_else(|| VmTrap::new("missingEntryPoint", None))?;
    let functions = module
        .functions
        .iter()
        .map(|function| load_function(module, function))
        .collect::<Result<Vec<_>, _>>()?;
    Ok(LoadedProgram { functions, entry })
}

pub(crate) fn invalid_bytecode() -> VmTrap {
    VmTrap::new("invalidBytecode", None)
}

fn load_function(
    module: &BytecodeModule,
    function: &BytecodeFunction,
) -> Result<LoadedFunction, VmTrap> {
    let definedness = Definedness::analyze(function);
    let mut loaded = LoadedFunction {
        code: Vec::with_capacity(function.fast.instructions.len()),
        mask: function.fast.instructions.len().saturating_sub(1),
        spans: function
            .fast
            .instructions
            .iter()
            .map(|entry| entry.span)
            .collect(),
        origins: Vec::with_capacity(function.fast.instructions.len()),
        edges: Vec::new(),
        moves: Vec::new(),
        calls: Vec::new(),
        continuations: continuations(function)?,
        scalar_window: window(function.scalar_types.len())?,
        reference_window: window(function.reference_types.len())?,
        entry_mass: function
            .fast
            .blocks
            .first()
            .map_or(0, |block| u64::from(block.mass)),
    };
    let context = instructions::DecodeContext {
        module,
        function,
        definedness: &definedness,
    };
    instructions::decode_all(&context, &mut loaded)?;
    if !loaded.code.len().is_power_of_two() {
        return Err(invalid_bytecode());
    }
    Ok(loaded)
}

fn window(register_count: usize) -> Result<usize, VmTrap> {
    let size = register_count.checked_add(1).ok_or_else(invalid_bytecode)?;
    if u16::try_from(register_count).is_err() {
        return Err(invalid_bytecode());
    }
    Ok(size)
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
