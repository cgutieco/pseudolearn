#![forbid(unsafe_code)]

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
    pub targets_start: usize,
    pub targets_end: usize,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub(crate) struct Origin {
    pub first: Option<Opcode>,
    pub second: Option<Opcode>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum ObservationKind {
    StatementEnter,
    StatementExit,
    DecideBool { condition: u16 },
    DecideCase { index: u16 },
    DecideDefault,
    DecideNone,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct ObservationSite {
    pub kind: ObservationKind,
    pub line: u32,
}

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct LoadedFunction {
    pub name: String,
    pub declaration_span: Option<SourceSpan>,
    pub names: std::collections::BTreeMap<Register, String>,
    pub scalar_types: Vec<pseudolearn_bytecode::ValueType>,
    pub reference_types: Vec<pseudolearn_bytecode::ValueType>,
    pub code: Vec<Op>,
    pub mask: usize,
    pub spans: Vec<Option<SourceSpan>>,
    pub origins: Vec<Origin>,
    pub probed_code: Vec<Op>,
    pub probed_mask: usize,
    pub probed_spans: Vec<Option<SourceSpan>>,
    pub probed_origins: Vec<Origin>,
    pub observations: Vec<ObservationSite>,
    pub fast_to_probed_blocks: Vec<usize>,
    pub probed_to_fast_blocks: Vec<usize>,
    pub fast_to_probed_returns: Vec<usize>,
    pub probed_to_fast_returns: Vec<usize>,
    pub edges: Vec<Edge>,
    pub switches: Vec<SwitchTable>,
    pub moves: Vec<Move>,
    pub calls: Vec<CallSite>,
    pub virtual_targets: Vec<Option<u16>>,
    pub continuations: Vec<usize>,
    pub scalar_window: usize,
    pub reference_window: usize,
    pub scalar_outgoing: usize,
    pub reference_outgoing: usize,
    pub entry_mass: u64,
    pub memory: Vec<memory::MemoryOp>,
    pub roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
    pub probed_roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
}

impl LoadedFunction {
    #[inline(always)]
    pub(crate) fn operation(&self, program_counter: usize, probed: bool) -> Op {
        if probed && !self.probed_code.is_empty() {
            self.probed_code
                .get(program_counter & self.probed_mask)
                .copied()
                .unwrap_or(Op::Unreachable)
        } else {
            self.code
                .get(program_counter & self.mask)
                .copied()
                .unwrap_or(Op::Unreachable)
        }
    }

    pub(crate) fn span(&self, program_counter: usize, probed: bool) -> Option<SourceSpan> {
        if probed && !self.probed_spans.is_empty() {
            self.probed_spans.get(program_counter).copied().flatten()
        } else {
            self.spans.get(program_counter).copied().flatten()
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct LoadedProgram {
    pub(crate) inner: std::sync::Arc<LoadedProgramInner>,
}

#[derive(Debug, PartialEq)]
pub(crate) struct LoadedProgramInner {
    pub(crate) name: String,
    pub(crate) functions: Vec<std::sync::Arc<LoadedFunction>>,
    pub(crate) entry: usize,
    pub(crate) literals: Vec<String>,
    pub(crate) classes: Vec<pseudolearn_bytecode::BytecodeClass>,
    pub(crate) vocabulary: String,
    pub(crate) profiles: Vec<pseudolearn_bytecode::SourceProfile>,
    pub(crate) layouts: Vec<std::sync::Arc<pseudolearn_runtime::ObjectLayout>>,
}

impl LoadedProgram {
    pub(crate) fn new(inner: LoadedProgramInner) -> Self {
        Self {
            inner: std::sync::Arc::new(inner),
        }
    }

    pub fn class_schema(&self, identifier: u32) -> Option<&pseudolearn_bytecode::BytecodeClass> {
        self.inner.classes.get(usize::try_from(identifier).ok()?)
    }
}

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct SwitchTable {
    pub default: u32,
    pub targets: Vec<u32>,
}
