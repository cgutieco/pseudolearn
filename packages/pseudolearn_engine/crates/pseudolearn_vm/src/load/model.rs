use super::memory;
use crate::dispatch::Op;
use pseudolearn_bytecode::{Opcode, Register, RegisterClass, SourceSpan};

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
    pub receiver: Option<u16>,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub(crate) struct Origin {
    pub first: Option<Opcode>,
    pub second: Option<Opcode>,
}

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct LoadedFunction {
    pub name: String,
    pub declaration_span: Option<SourceSpan>,
    pub names: std::collections::BTreeMap<Register, String>,
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
    pub scalar_outgoing: usize,
    pub reference_outgoing: usize,
    pub entry_mass: u64,
    pub memory: Vec<memory::MemoryOp>,
    pub roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
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
    pub(crate) literals: Vec<String>,
    pub(crate) classes: Vec<pseudolearn_bytecode::BytecodeClass>,
    pub(crate) vocabulary: String,
    pub(crate) layouts: Vec<std::sync::Arc<pseudolearn_runtime::ObjectLayout>>,
}
