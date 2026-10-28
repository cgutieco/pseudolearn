use super::{Cursor, Flow, LoadedFunction, Machine};
use crate::load::TaskSite;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::TaskScopeId;
use std::sync::Arc;

#[derive(Clone)]
pub(super) struct TaskResume {
    function: Arc<LoadedFunction>,
    function_index: usize,
    cursor: Cursor,
    scalar_limit: usize,
    reference_limit: usize,
    depth: usize,
}

impl TaskResume {
    fn capture(machine: &Machine<'_>, edge: u32) -> Result<Self, Fault> {
        let edge = machine
            .current
            .edges
            .get(usize::try_from(edge).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        Ok(Self {
            function: Arc::clone(&machine.current),
            function_index: machine.current_function_index,
            cursor: Cursor {
                program_counter: edge.target,
                ..machine.cursor
            },
            scalar_limit: machine.scalar_limit,
            reference_limit: machine.reference_limit,
            depth: machine.frames.len(),
        })
    }

    pub(super) fn apply(self, machine: &mut Machine<'_>) {
        machine.current = self.function;
        machine.current_function_index = self.function_index;
        machine.cursor = self.cursor;
        machine.scalar_limit = self.scalar_limit;
        machine.reference_limit = self.reference_limit;
        machine.frames.truncate(self.depth);
    }
}

impl Machine<'_> {
    pub(crate) fn task_cancel_point(&mut self, site: u32) -> Result<Flow, Fault> {
        let TaskSite::CancelPoint { edge } = self.task_site(site)? else {
            return Err(INVALID_BYTECODE);
        };
        let resume = TaskResume::capture(self, edge)?;
        self.tasks
            .cancel_points
            .entry(self.tasks.current)
            .or_default()
            .insert(self.frames.len(), resume);
        Ok(Flow::Continue)
    }

    pub(crate) fn task_scope_boundary(&mut self, site: u32) -> Result<Flow, Fault> {
        let TaskSite::ScopeBoundary { scope, edge } = self.task_site(site)? else {
            return Err(INVALID_BYTECODE);
        };
        let scope = TaskScopeId(self.scalar(scope.index)?);
        let resume = TaskResume::capture(self, edge)?;
        self.tasks.scope_resumes.insert(scope, resume);
        Ok(Flow::Continue)
    }

    pub(super) fn resume_cancellation(&mut self) -> bool {
        let points = self.tasks.cancel_points.get_mut(&self.tasks.current);
        let point = points
            .and_then(|points| points.pop_last())
            .map(|(_, point)| point);
        if let Some(point) = point {
            self.tasks
                .cleanup_depths
                .insert(self.tasks.current, point.depth);
            point.apply(self);
            true
        } else {
            false
        }
    }

    pub(super) fn cancelled_return(&mut self) -> Option<Flow> {
        if self.tasks.agenda.state(self.tasks.current)
            != Some(pseudolearn_runtime::TaskState::Cleaning)
        {
            return None;
        }
        if self.tasks.cleanup_depths.get(&self.tasks.current).copied() != Some(self.frames.len()) {
            return None;
        }
        if !self.resume_cancellation() {
            return Some(Flow::Completed(None));
        }
        Some(Flow::Continue)
    }
}
