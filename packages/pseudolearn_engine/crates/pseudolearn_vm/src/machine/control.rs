#![forbid(unsafe_code)]

use crate::evaluate::{INVALID_BYTECODE, branch_truth};
use crate::load::Edge;
use crate::machine::{Flow, Machine};
use crate::{Fault, ServiceReason};

impl Machine<'_> {
    #[inline(always)]
    pub(crate) fn jump<const TASK_RUNTIME: bool>(&mut self, edge: u32) -> Result<Flow, Fault> {
        let edge = self
            .current
            .edges
            .get(usize::try_from(edge).map_err(|_| INVALID_BYTECODE)?)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        self.take_edge::<TASK_RUNTIME>(edge)
    }

    #[inline(always)]
    pub(crate) fn switch<const TASK_RUNTIME: bool>(
        &mut self,
        source: u16,
        table: u32,
    ) -> Result<Flow, Fault> {
        let ordinal = self.scalar(source)?;
        let table = self
            .current
            .switches
            .get(usize::try_from(table).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        let edge = usize::try_from(ordinal)
            .ok()
            .and_then(|index| table.targets.get(index))
            .copied()
            .unwrap_or(table.default);
        self.jump::<TASK_RUNTIME>(edge)
    }

    #[inline(always)]
    pub(crate) fn branch<const TASK_RUNTIME: bool>(
        &mut self,
        condition: u16,
        then_edge: u32,
        else_edge: u32,
    ) -> Result<Flow, Fault> {
        let word = self.scalar(condition)?;
        self.branch_on::<TASK_RUNTIME>(word, then_edge, else_edge)
    }

    #[inline(always)]
    pub(crate) fn branch_on<const TASK_RUNTIME: bool>(
        &mut self,
        word: u64,
        then_edge: u32,
        else_edge: u32,
    ) -> Result<Flow, Fault> {
        if branch_truth(word)? {
            self.jump::<TASK_RUNTIME>(then_edge)
        } else {
            self.jump::<TASK_RUNTIME>(else_edge)
        }
    }

    #[inline(always)]
    fn take_edge<const TASK_RUNTIME: bool>(&mut self, edge: Edge) -> Result<Flow, Fault> {
        if edge.probe {
            if self.remaining.probes == 0 {
                return Ok(Flow::Service(ServiceReason::Probe));
            }
            self.remaining.probes = self.remaining.probes.saturating_sub(1);
        }
        if edge.moves_start != edge.moves_end {
            self.apply_moves(edge.moves_start, edge.moves_end)?;
        }
        self.cursor.program_counter = edge.target;
        Ok(self.charge_entry::<TASK_RUNTIME>(edge.mass, edge.target))
    }

    fn apply_moves(&mut self, start: usize, end: usize) -> Result<(), Fault> {
        let function = std::sync::Arc::clone(&self.current);
        let moves = function.moves.get(start..end).ok_or(INVALID_BYTECODE)?;
        for entry in moves {
            self.move_within(entry)?;
        }
        Ok(())
    }

    #[inline(always)]
    pub(crate) fn charge_entry<const TASK_RUNTIME: bool>(
        &mut self,
        mass: u64,
        target_pc: usize,
    ) -> Flow {
        if let Some(limit) = self.options.statement_limit
            && !self.probed
            && self.statements_executed.saturating_add(mass) > limit
        {
            self.probed = true;
            if let Some(&probed_pc) = self.current.fast_to_probed_blocks.get(target_pc) {
                self.cursor.program_counter = probed_pc;
            }
        }
        if TASK_RUNTIME {
            self.tasks.quantum.charge(self.tasks.current, mass);
        }
        match self.remaining.statements.checked_sub(mass) {
            Some(remaining) => {
                self.remaining.statements = remaining;
                Flow::Continue
            }
            None => Flow::Service(ServiceReason::Statements),
        }
    }
}
