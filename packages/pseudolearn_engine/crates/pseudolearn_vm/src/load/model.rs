#![forbid(unsafe_code)]

use super::invalid_bytecode;
use super::memory;
use crate::VmTrap;
use crate::dispatch::{CompactOp, Op, TaskOp, compact_operation};
use pseudolearn_bytecode::{Opcode, Register, RegisterClass, SourceSpan};

const NO_TASK_OPERATION: u32 = u32::MAX;

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
    pub indirect: Option<u16>,
    pub function: usize,
    pub destination: Option<Register>,
    pub return_point: usize,
    pub arguments_start: usize,
    pub arguments_end: usize,
    pub receiver: Option<u16>,
    pub targets_start: usize,
    pub targets_end: usize,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct EffectSite {
    pub awaited: bool,
    pub destination: Option<Register>,
    pub capability: u16,
    pub operation: String,
    pub arguments: Vec<u16>,
    pub result_cells: Vec<u16>,
    pub result_class: u32,
    pub source_node_id: u32,
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

#[derive(Clone, Debug, Default, PartialEq)]
pub(crate) struct LoadedFunction {
    pub task_sites: Vec<super::instructions::task_results::TaskSite>,
    pub channel_sites: Vec<super::instructions::channels::ChannelSite>,
    pub visibility: std::collections::BTreeMap<Register, SourceSpan>,
    pub name: String,
    pub declaration_span: Option<SourceSpan>,
    pub names: std::collections::BTreeMap<Register, String>,
    pub scalar_types: Vec<pseudolearn_bytecode::ValueType>,
    pub reference_types: Vec<pseudolearn_bytecode::ValueType>,
    pub code: Vec<CompactOp>,
    pub task_operations: Vec<TaskOp>,
    pub mask: usize,
    pub spans: Vec<Option<SourceSpan>>,
    pub origins: Vec<Origin>,
    pub probed_code: Vec<CompactOp>,
    pub task_operation_indices: Vec<u32>,
    pub probed_task_operation_indices: Vec<u32>,
    pub probed_mask: usize,
    pub probed_spans: Vec<Option<SourceSpan>>,
    pub probed_origins: Vec<Origin>,
    pub probed_statement_enters: Vec<usize>,
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
    pub reference_live: Vec<Vec<(u16, bool)>>,
    pub probed_reference_live: Vec<Vec<(u16, bool)>>,
    pub continuation_capacity: (usize, usize),
    pub scalar_live: Vec<Vec<u16>>,
    pub probed_scalar_live: Vec<Vec<u16>>,
    pub roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
    pub probed_roots: std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
    pub effect_sites: Vec<EffectSite>,
}

impl LoadedFunction {
    pub(crate) fn store_operation(
        &mut self,
        decoded: Op,
        position: usize,
        probed: bool,
    ) -> Result<CompactOp, VmTrap> {
        let (operation, task_index) = compact_operation(decoded, &mut self.task_operations)
            .map_err(|_| invalid_bytecode())?;
        self.push_task_operation_index(position, probed, task_index)?;
        Ok(operation)
    }

    pub(crate) fn store_unreachable(
        &mut self,
        position: usize,
        probed: bool,
    ) -> Result<(), VmTrap> {
        self.push_task_operation_index(position, probed, None)
    }

    fn push_task_operation_index(
        &mut self,
        position: usize,
        probed: bool,
        task_index: Option<u32>,
    ) -> Result<(), VmTrap> {
        let indices = if probed {
            &mut self.probed_task_operation_indices
        } else {
            &mut self.task_operation_indices
        };
        if indices.is_empty() {
            if let Some(index) = task_index {
                indices.resize(position, NO_TASK_OPERATION);
                indices.push(index);
            }
            return Ok(());
        }
        if indices.len() != position {
            return Err(invalid_bytecode());
        }
        let index = match task_index {
            Some(index) => index,
            None => NO_TASK_OPERATION,
        };
        indices.push(index);
        Ok(())
    }

    pub(crate) fn task_operation(&self, position: usize, probed: bool) -> Option<TaskOp> {
        let indices = if probed {
            &self.probed_task_operation_indices
        } else {
            &self.task_operation_indices
        };
        let stored_index = *indices.get(position)?;
        if stored_index == NO_TASK_OPERATION {
            return None;
        }
        let index = usize::try_from(stored_index).ok()?;
        self.task_operations.get(index).copied()
    }

    #[inline(always)]
    pub(crate) fn operation(&self, program_counter: usize, probed: bool) -> CompactOp {
        if probed && !self.probed_code.is_empty() {
            self.probed_code
                .get(program_counter & self.probed_mask)
                .copied()
                .unwrap_or(CompactOp::Unreachable)
        } else {
            self.code
                .get(program_counter & self.mask)
                .copied()
                .unwrap_or(CompactOp::Unreachable)
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
    pub(crate) uses_task_runtime: bool,
    pub(crate) literals: Vec<String>,
    pub(crate) classes: Vec<pseudolearn_bytecode::BytecodeClass>,
    pub(crate) vocabulary: String,
    pub(crate) profiles: Vec<pseudolearn_bytecode::SourceProfile>,
    pub(crate) layouts: Vec<std::sync::Arc<pseudolearn_runtime::ObjectLayout>>,
}

impl LoadedProgram {
    pub(crate) fn uses_task_runtime(&self) -> bool {
        self.inner.uses_task_runtime
    }

    pub fn uses_effects(&self) -> bool {
        self.inner
            .functions
            .iter()
            .any(|function| !function.effect_sites.is_empty())
    }

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
