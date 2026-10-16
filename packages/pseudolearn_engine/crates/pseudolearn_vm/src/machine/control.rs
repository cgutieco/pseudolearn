#![forbid(unsafe_code)]

use crate::evaluate::{INVALID_BYTECODE, branch_truth};
use crate::load::Edge;
use crate::machine::{Flow, Machine};
use crate::{Fault, ServiceReason};

impl Machine<'_> {
    #[inline(always)]
    pub(crate) fn jump(&mut self, edge: u32) -> Result<Flow, Fault> {
        let edge = self
            .current
            .edges
            .get(usize::try_from(edge).map_err(|_| INVALID_BYTECODE)?)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        self.take_edge(edge)
    }

    #[inline(always)]
    pub(crate) fn branch(
        &mut self,
        condition: u16,
        then_edge: u32,
        else_edge: u32,
    ) -> Result<Flow, Fault> {
        let word = self.scalar(condition)?;
        self.branch_on(word, then_edge, else_edge)
    }

    #[inline(always)]
    pub(crate) fn branch_on(
        &mut self,
        word: u64,
        then_edge: u32,
        else_edge: u32,
    ) -> Result<Flow, Fault> {
        if branch_truth(word)? {
            self.jump(then_edge)
        } else {
            self.jump(else_edge)
        }
    }

    #[inline(always)]
    fn take_edge(&mut self, edge: Edge) -> Result<Flow, Fault> {
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
        Ok(self.charge_entry(edge.mass, edge.target))
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
    pub(crate) fn charge_entry(&mut self, mass: u64, target_pc: usize) -> Flow {
        if let Some(limit) = self.options.statement_limit
            && !self.probed
            && self.statements_executed.saturating_add(mass) > limit
        {
            self.probed = true;
            if let Some(&probed_pc) = self.current.fast_to_probed_blocks.get(target_pc) {
                self.cursor.program_counter = probed_pc;
            }
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
