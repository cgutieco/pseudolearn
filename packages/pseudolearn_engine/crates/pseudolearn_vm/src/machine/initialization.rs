use std::marker::PhantomData;
use std::sync::Arc;

use crate::events::ChangeBuffer;
use crate::load::{LoadedFunction, LoadedProgram};
use crate::{Fuel, RunExit, RunOptions, RunResult, TwinMode, VmTrap};
use pseudolearn_runtime::{Heap, RandomState};

use super::profile::OpcodeObserver;
use super::{Cursor, Flow, Machine};

const INITIAL_BANK_WORDS: usize = 64;

macro_rules! machine_instance {
    ($program:ident, $current:ident, $function_index:ident, $fuel:ident, $options:ident, $probed:ident, $inputs:ident, $task_limit:ident, $task_runtime_enabled:ident) => {
        Machine {
            program: $program,
            current: $current,
            current_function_index: $function_index,
            program_lifetime: PhantomData,
            cursor: Cursor::default(),
            scalar_limit: 0,
            reference_limit: 0,
            scalars: Vec::new(),
            defined: Vec::new(),
            references: Vec::new(),
            frames: Vec::new(),
            remaining: $fuel,
            output: String::new(),
            heap: Heap::new($options.memory),
            literals: Vec::new(),
            random: RandomState::seeded($options.seed),
            options: $options,
            cells: Vec::new(),
            reference_watermark: 0,
            scalar_watermark: 0,
            memory_counts: Vec::new(),
            probed: $probed,
            events: Vec::new(),
            events_dropped: 0,
            change_buffer: ChangeBuffer::new(),
            inputs: $inputs,
            input_index: 0,
            diagnostics: Vec::new(),
            statements_executed: 0,
            polls_executed: 0,
            input_requested_emitted: false,
            output_suppressed: false,
            frame_dirty_from: std::cell::Cell::new(0),
            bank_delta_tracking: std::cell::Cell::new(false),
            scalar_dirty_from: std::cell::Cell::new(0),
            reference_dirty_from: std::cell::Cell::new(0),
            defined_dirty_from: std::cell::Cell::new(0),
            effect_result: None,
            effect_checkpoint: None,
            effect_seq: 0,
            tasks: super::tasks::VmTasks::with_task_limit($task_limit, $task_runtime_enabled),
        }
    };
}

pub(super) struct MachineInitialization {
    pub(super) program: LoadedProgram,
    pub(super) current: Arc<LoadedFunction>,
    pub(super) current_function_index: usize,
    pub(super) fuel: Fuel,
    pub(super) options: RunOptions,
}

pub(super) fn execute_with<Observer: OpcodeObserver>(
    program: &LoadedProgram,
    fuel: Fuel,
    options: RunOptions,
    observer: &mut Observer,
) -> RunResult {
    match Machine::start(program, fuel, options) {
        Ok(mut machine) => {
            let exit = if machine.tasks.enabled {
                machine
                    .enter_entry::<true>()
                    .unwrap_or_else(|| machine.execute::<true, _>(observer))
            } else {
                machine
                    .enter_entry::<false>()
                    .unwrap_or_else(|| machine.execute::<false, _>(observer))
            };
            machine.finish(exit, fuel)
        }
        Err(trap) => super::trapped(trap),
    }
}

impl<'program> Machine<'program> {
    pub(super) fn start(
        program: &'program LoadedProgram,
        fuel: Fuel,
        options: RunOptions,
    ) -> Result<Self, VmTrap> {
        Self::initialize(program.clone(), fuel, options)
    }

    fn initialize(program: LoadedProgram, fuel: Fuel, options: RunOptions) -> Result<Self, VmTrap> {
        let current_function_index = program.inner.entry;
        let current = program
            .inner
            .functions
            .get(current_function_index)
            .cloned()
            .ok_or_else(|| VmTrap::new("missingEntryPoint", None))?;
        let mut machine = Self::new_instance(MachineInitialization {
            program,
            current,
            current_function_index,
            fuel,
            options,
        });
        machine.initialize_storage()?;
        Ok(machine)
    }

    pub(super) fn new_instance(initialization: MachineInitialization) -> Self {
        let MachineInitialization {
            program,
            current,
            current_function_index,
            fuel,
            options,
        } = initialization;
        let probed = options.twin_mode == TwinMode::Probed;
        let inputs = options.inputs.clone();
        let task_limit = options.task_limit;
        let task_runtime_enabled = program.uses_task_runtime();
        machine_instance!(
            program,
            current,
            current_function_index,
            fuel,
            options,
            probed,
            inputs,
            task_limit,
            task_runtime_enabled
        )
    }

    fn initialize_storage(&mut self) -> Result<(), VmTrap> {
        if self.options.depth == 0 {
            return Err(self.trap_context("recursionDepthExceeded", 0));
        }
        let scalar_end = self.current.scalar_window.max(INITIAL_BANK_WORDS);
        let reference_end = self.current.reference_window.max(INITIAL_BANK_WORDS);
        self.ensure_capacity(scalar_end, reference_end)
            .map_err(|fault| VmTrap::new(fault, None))?;
        self.scalar_limit = self.current.scalar_window;
        self.reference_limit = self.current.reference_window;
        self.initialize_literals()
            .map_err(|fault| VmTrap::new(fault, None))?;
        Ok(())
    }

    pub(super) fn enter_entry<const TASK_RUNTIME: bool>(&mut self) -> Option<RunExit> {
        if self.probed {
            if let Some(&probed_start) = self.current.fast_to_probed_blocks.first() {
                self.cursor.program_counter = probed_start;
            }
            return None;
        }
        match self.charge_entry::<TASK_RUNTIME>(self.current.entry_mass, 0) {
            Flow::Service(reason) => Some(RunExit::Service(reason)),
            Flow::Continue
            | Flow::Completed(_)
            | Flow::AwaitingInput
            | Flow::AwaitingEffect(_)
            | Flow::Cancelled
            | Flow::LimitReached(_) => None,
        }
    }
}

pub fn create_owned_machine(
    program: LoadedProgram,
    fuel: Fuel,
    options: RunOptions,
) -> Result<Machine<'static>, VmTrap> {
    Machine::<'static>::initialize(program, fuel, options)
}
