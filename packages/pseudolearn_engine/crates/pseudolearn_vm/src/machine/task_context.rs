use std::sync::Arc;

use super::cells::Cell;
use super::{ControlFrame, Cursor, LoadedFunction, Machine};

pub(crate) struct TaskContext {
    pub(super) current: Arc<LoadedFunction>,
    pub(super) current_function_index: usize,
    pub(super) cursor: Cursor,
    pub(super) root_position: usize,
    pub(super) scalar_limit: usize,
    pub(super) reference_limit: usize,
    pub(super) scalars: Vec<u64>,
    pub(super) defined: Vec<bool>,
    pub(super) references: Vec<u32>,
    pub(super) frames: Vec<ControlFrame>,
    pub(super) cells: Vec<Cell>,
    pub(super) scalar_watermark: usize,
    pub(super) reference_watermark: usize,
}

impl TaskContext {
    pub(super) fn capture(machine: &mut Machine<'_>, reexecute_current: bool) -> Self {
        let root_position = if reexecute_current {
            machine.cursor.program_counter
        } else {
            machine.cursor.program_counter.saturating_sub(1)
        };
        Self {
            current: Arc::clone(&machine.current),
            current_function_index: machine.current_function_index,
            cursor: machine.cursor,
            root_position,
            scalar_limit: machine.scalar_limit,
            reference_limit: machine.reference_limit,
            scalars: std::mem::take(&mut machine.scalars),
            defined: std::mem::take(&mut machine.defined),
            references: std::mem::take(&mut machine.references),
            frames: std::mem::take(&mut machine.frames),
            cells: std::mem::take(&mut machine.cells),
            scalar_watermark: machine.scalar_watermark,
            reference_watermark: machine.reference_watermark,
        }
    }

    pub(super) fn restore(self, machine: &mut Machine<'_>) {
        machine.current = self.current;
        machine.current_function_index = self.current_function_index;
        machine.cursor = self.cursor;
        machine.scalar_limit = self.scalar_limit;
        machine.reference_limit = self.reference_limit;
        machine.scalars = self.scalars;
        machine.defined = self.defined;
        machine.references = self.references;
        machine.frames = self.frames;
        machine.cells = self.cells;
        machine.scalar_watermark = self.scalar_watermark;
        machine.reference_watermark = self.reference_watermark;
    }
}
