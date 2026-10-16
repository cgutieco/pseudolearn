use std::collections::BTreeMap;

use pseudolearn_bytecode::{Register, ValueType};
use pseudolearn_runtime::{Handle, Heap, RandomState};

use crate::RunExit;
use crate::dispatch::step;
use crate::load::{LoadedFunction, LoadedProgram};
use crate::machine::cells::Cell;
use crate::machine::{ControlFrame, Flow, Machine};

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SavedControlFrame {
    pub function_index: usize,
    pub return_point: usize,
    pub destination: Option<Register>,
    pub scalar_base: usize,
    pub reference_base: usize,
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

#[derive(Clone, Debug)]
pub struct ActiveFrameInspection<'program> {
    pub function_name: &'program str,
    pub names: &'program BTreeMap<Register, String>,
    pub scalar_base: usize,
    pub reference_base: usize,
    pub receiver_handle: Option<Handle>,
    pub scalar_types: &'program [ValueType],
    pub reference_types: &'program [ValueType],
}

impl<'program> Machine<'program> {
    pub fn step_instruction(&mut self) -> Option<RunExit> {
        let function = self.current;
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
        let current_function_index = function_index_of(self.program, self.current);
        let frames = capture_saved_frames(self);
        let (scalars, references, defined) = capture_saved_banks(self);
        MachineStateRecord {
            cursor_pc: self.cursor.program_counter,
            cursor_scalar_base: self.cursor.scalar_base,
            cursor_reference_base: self.cursor.reference_base,
            current_function_index,
            frames,
            scalar_watermark: self.scalar_watermark,
            reference_watermark: self.reference_watermark,
            scalars,
            references,
            defined,
            cells: self.cells.clone(),
            random: self.random,
            arena_used: pseudolearn_runtime::arena_length(&self.heap),
            output_length: self.output.len(),
            input_index: self.input_index,
            statements_executed: self.statements_executed,
            polls_executed: self.polls_executed,
            event_count: self.events.len(),
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
        if let Some(function) = self.program.functions.get(record.current_function_index) {
            self.current = function;
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
        self.events.truncate(record.event_count);
        pseudolearn_runtime::set_heap_used_words(&mut self.heap, record.heap_used);
        pseudolearn_runtime::set_heap_ordinal(&mut self.heap, record.heap_ordinal);
        pseudolearn_runtime::set_heap_allocated_cells(&mut self.heap, record.heap_allocated_cells);
        pseudolearn_runtime::set_heap_live_cells(&mut self.heap, record.heap_live_cells);
    }

    fn restore_frames_from_record(&mut self, frames: &[SavedControlFrame]) {
        self.frames.clear();
        for saved in frames {
            if let Some(function) = self.program.functions.get(saved.function_index) {
                self.frames.push(ControlFrame {
                    function,
                    return_point: saved.return_point,
                    destination: saved.destination,
                    scalar_base: saved.scalar_base,
                    reference_base: saved.reference_base,
                    cell_count: saved.cell_count,
                });
            }
        }
    }

    fn restore_banks_from_record(&mut self, record: &MachineStateRecord) {
        self.scalar_watermark = record.scalar_watermark;
        self.reference_watermark = record.reference_watermark;
        self.scalars.resize(record.scalars.len(), 0);
        self.scalars.copy_from_slice(&record.scalars);
        self.references.resize(record.references.len(), 0);
        self.references.copy_from_slice(&record.references);
        self.defined.resize(record.defined.len(), false);
        self.defined.copy_from_slice(&record.defined);
    }

    pub fn active_frames_count(&self) -> usize {
        self.frames.len().saturating_add(1)
    }

    pub fn active_frame(&self, frame_position: usize) -> Option<ActiveFrameInspection<'program>> {
        let total_frames = self.active_frames_count();
        if frame_position >= total_frames {
            return None;
        }
        if frame_position < self.frames.len() {
            let frame = self.frames.get(frame_position)?;
            Some(ActiveFrameInspection {
                function_name: if frame.function.name.trim_start_matches('@') == "main" {
                    &self.program.name
                } else {
                    &frame.function.name
                },
                names: &frame.function.names,
                scalar_base: frame.scalar_base,
                reference_base: frame.reference_base,
                receiver_handle: frame_receiver(self, frame.reference_base),
                scalar_types: &frame.function.scalar_types,
                reference_types: &frame.function.reference_types,
            })
        } else {
            Some(ActiveFrameInspection {
                function_name: if self.current.name.trim_start_matches('@') == "main" {
                    &self.program.name
                } else {
                    &self.current.name
                },
                names: &self.current.names,
                scalar_base: self.cursor.scalar_base,
                reference_base: self.cursor.reference_base,
                receiver_handle: frame_receiver(self, self.cursor.reference_base),
                scalar_types: &self.current.scalar_types,
                reference_types: &self.current.reference_types,
            })
        }
    }

    pub fn heap(&self) -> &Heap {
        &self.heap
    }

    pub fn heap_mut(&mut self) -> &mut Heap {
        &mut self.heap
    }
}

fn function_index_of(program: &LoadedProgram, target: &LoadedFunction) -> usize {
    program
        .functions
        .iter()
        .position(|function| std::ptr::eq(function, target))
        .unwrap_or(0)
}

fn frame_receiver(machine: &Machine, reference_base: usize) -> Option<Handle> {
    let handle_word = machine.references.get(reference_base).copied()?;
    if handle_word == 0 {
        None
    } else {
        Some(Handle(handle_word))
    }
}

fn capture_saved_frames(machine: &Machine) -> Vec<SavedControlFrame> {
    machine
        .frames
        .iter()
        .map(|frame| SavedControlFrame {
            function_index: function_index_of(machine.program, frame.function),
            return_point: frame.return_point,
            destination: frame.destination,
            scalar_base: frame.scalar_base,
            reference_base: frame.reference_base,
            cell_count: frame.cell_count,
        })
        .collect()
}

fn capture_saved_banks(machine: &Machine) -> (Vec<u64>, Vec<u32>, Vec<bool>) {
    let scalars = machine
        .scalars
        .get(..machine.scalar_watermark)
        .map_or_else(Vec::new, <[u64]>::to_vec);
    let references = machine
        .references
        .get(..machine.reference_watermark)
        .map_or_else(Vec::new, <[u32]>::to_vec);
    let defined = machine
        .defined
        .get(..machine.scalar_watermark)
        .map_or_else(Vec::new, <[bool]>::to_vec);
    (scalars, references, defined)
}
