use std::sync::Arc;

use pseudolearn_bytecode::Register;
use pseudolearn_runtime::{Heap, RandomState};

use crate::RunExit;
use crate::dispatch::step;
use crate::machine::cells::Cell;
use crate::machine::{ControlFrame, Flow, Machine};

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SavedControlFrame {
    pub function_index: usize,
    pub return_point: usize,
    pub destination: Option<Register>,
    pub scalar_base: usize,
    pub reference_base: usize,
    pub scalar_limit: usize,
    pub reference_limit: usize,
    pub cell_count: usize,
}

#[derive(Clone, Debug, PartialEq)]
pub struct MachineStateRecord {
    pub cursor_pc: usize,
    pub cursor_scalar_base: usize,
    pub cursor_reference_base: usize,
    pub current_function_index: usize,
    pub frames: Vec<SavedControlFrame>,
    pub scalar_watermark: usize,
    pub reference_watermark: usize,
    pub scalar_limit: usize,
    pub reference_limit: usize,
    pub scalars: Vec<u64>,
    pub references: Vec<u32>,
    pub defined: Vec<bool>,
    pub cells: Vec<Cell>,
    pub random: RandomState,
    pub arena_used: usize,
    pub output_length: usize,
    pub input_index: usize,
    pub statements_executed: u64,
    pub polls_executed: u64,
    pub event_count: usize,
    pub heap_used: usize,
    pub heap_ordinal: u64,
    pub heap_allocated_cells: u64,
    pub heap_live_cells: u64,
}

impl MachineStateRecord {
    pub(super) fn clone_control(&self) -> Self {
        Self {
            cursor_pc: self.cursor_pc,
            cursor_scalar_base: self.cursor_scalar_base,
            cursor_reference_base: self.cursor_reference_base,
            current_function_index: self.current_function_index,
            frames: Vec::new(),
            scalar_watermark: self.scalar_watermark,
            reference_watermark: self.reference_watermark,
            scalar_limit: self.scalar_limit,
            reference_limit: self.reference_limit,
            scalars: Vec::new(),
            references: Vec::new(),
            defined: Vec::new(),
            cells: Vec::new(),
            random: self.random,
            arena_used: self.arena_used,
            output_length: self.output_length,
            input_index: self.input_index,
            statements_executed: self.statements_executed,
            polls_executed: self.polls_executed,
            event_count: self.event_count,
            heap_used: self.heap_used,
            heap_ordinal: self.heap_ordinal,
            heap_allocated_cells: self.heap_allocated_cells,
            heap_live_cells: self.heap_live_cells,
        }
    }
}

impl<'program> Machine<'program> {
    pub fn step_instruction(&mut self) -> Option<RunExit> {
        let function = self.current.as_ref();
        let position = self.cursor.program_counter;
        self.cursor.program_counter = position.wrapping_add(1);
        match step(self, function.operation(position, self.probed)) {
            Ok(Flow::Continue) => None,
            Ok(Flow::Completed(value)) => Some(RunExit::Completed(value)),
            Ok(Flow::Service(reason)) => Some(RunExit::Service(reason)),
            Ok(Flow::AwaitingInput) => Some(RunExit::AwaitingInput),
            Ok(Flow::Cancelled) => Some(RunExit::Cancelled),
            Ok(Flow::LimitReached(kind)) => Some(RunExit::LimitReached { kind }),
            Err(fault) => {
                let trap = self.trap_context(fault, position);
                self.record_failure(&trap);
                Some(RunExit::Trap(trap))
            }
        }
    }

    pub fn capture_machine_state(&self) -> MachineStateRecord {
        let mut record = self.capture_control_record();
        record.frames = capture_saved_frames(self);
        record.scalars.clone_from(&self.scalars);
        record.references.clone_from(&self.references);
        record.defined.clone_from(&self.defined);
        record.cells = self.cells.clone();
        record
    }

    pub(crate) fn capture_control_record(&self) -> MachineStateRecord {
        MachineStateRecord {
            cursor_pc: self.cursor.program_counter,
            cursor_scalar_base: self.cursor.scalar_base,
            cursor_reference_base: self.cursor.reference_base,
            current_function_index: self.current_function_index,
            frames: Vec::new(),
            scalar_watermark: self.scalar_watermark,
            reference_watermark: self.reference_watermark,
            scalar_limit: self.scalar_limit,
            reference_limit: self.reference_limit,
            scalars: Vec::new(),
            references: Vec::new(),
            defined: Vec::new(),
            cells: Vec::new(),
            random: self.random,
            arena_used: pseudolearn_runtime::arena_length(&self.heap),
            output_length: self.output.len(),
            input_index: self.input_index,
            statements_executed: self.statements_executed,
            polls_executed: self.polls_executed,
            event_count: self.events_dropped.saturating_add(self.events.len()),
            heap_used: pseudolearn_runtime::heap_used_words(&self.heap),
            heap_ordinal: pseudolearn_runtime::heap_ordinal(&self.heap),
            heap_allocated_cells: pseudolearn_runtime::heap_allocated_cells(&self.heap),
            heap_live_cells: pseudolearn_runtime::heap_live_cells(&self.heap),
        }
    }

    pub fn restore_machine_state(&mut self, record: &MachineStateRecord) {
        self.cursor.program_counter = record.cursor_pc;
        self.cursor.scalar_base = record.cursor_scalar_base;
        self.cursor.reference_base = record.cursor_reference_base;
        self.current_function_index = record.current_function_index;
        self.scalar_limit = record.scalar_limit;
        self.reference_limit = record.reference_limit;
        if let Some(function) = self
            .program
            .inner
            .functions
            .get(record.current_function_index)
        {
            self.current = Arc::clone(function);
        }
        self.restore_frames_from_record(&record.frames);
        self.restore_banks_from_record(record);
        self.cells = record.cells.clone();
        self.random = record.random;
        pseudolearn_runtime::truncate_arena(&mut self.heap, record.arena_used);
        self.output.truncate(record.output_length);
        self.input_index = record.input_index;
        self.statements_executed = record.statements_executed;
        self.polls_executed = record.polls_executed;
        self.events
            .truncate(record.event_count.saturating_sub(self.events_dropped));
        pseudolearn_runtime::set_heap_used_words(&mut self.heap, record.heap_used);
        pseudolearn_runtime::set_heap_ordinal(&mut self.heap, record.heap_ordinal);
        pseudolearn_runtime::set_heap_allocated_cells(&mut self.heap, record.heap_allocated_cells);
        pseudolearn_runtime::set_heap_live_cells(&mut self.heap, record.heap_live_cells);
    }

    fn restore_frames_from_record(&mut self, frames: &[SavedControlFrame]) {
        self.frames.clear();
        for saved in frames {
            if let Some(function) = self.program.inner.functions.get(saved.function_index) {
                self.frames.push(ControlFrame {
                    function: Arc::clone(function),
                    function_index: saved.function_index,
                    return_point: saved.return_point,
                    destination: saved.destination,
                    scalar_base: saved.scalar_base,
                    reference_base: saved.reference_base,
                    scalar_limit: saved.scalar_limit,
                    reference_limit: saved.reference_limit,
                    cell_count: saved.cell_count,
                });
            }
        }
        self.frame_dirty_from.set(self.frames.len());
    }

    fn restore_banks_from_record(&mut self, record: &MachineStateRecord) {
        self.scalar_watermark = record.scalar_watermark;
        self.reference_watermark = record.reference_watermark;
        self.scalars.resize(record.scalar_limit, 0);
        let scalar_count = self.scalars.len().min(record.scalars.len());
        if let (Some(destination), Some(source)) = (
            self.scalars.get_mut(..scalar_count),
            record.scalars.get(..scalar_count),
        ) {
            destination.copy_from_slice(source);
        }
        self.references.resize(record.reference_limit, 0);
        let reference_count = self.references.len().min(record.references.len());
        if let (Some(destination), Some(source)) = (
            self.references.get_mut(..reference_count),
            record.references.get(..reference_count),
        ) {
            destination.copy_from_slice(source);
        }
        self.defined.resize(record.scalar_limit, false);
        let defined_count = self.defined.len().min(record.defined.len());
        if let (Some(destination), Some(source)) = (
            self.defined.get_mut(..defined_count),
            record.defined.get(..defined_count),
        ) {
            destination.copy_from_slice(source);
        }
        self.reset_bank_delta_tracking();
    }

    pub fn heap(&self) -> &Heap {
        &self.heap
    }

    pub fn heap_mut(&mut self) -> &mut Heap {
        &mut self.heap
    }
}

pub(super) fn capture_saved_frames(machine: &Machine) -> Vec<SavedControlFrame> {
    machine
        .frames
        .iter()
        .map(|frame| SavedControlFrame {
            function_index: frame.function_index,
            return_point: frame.return_point,
            destination: frame.destination,
            scalar_base: frame.scalar_base,
            reference_base: frame.reference_base,
            scalar_limit: frame.scalar_limit,
            reference_limit: frame.reference_limit,
            cell_count: frame.cell_count,
        })
        .collect()
}
