#![forbid(unsafe_code)]

mod calls;
mod cells;
mod channels;
mod collections;
mod control;
mod delta;
mod effect_completion;
mod effects;
mod fault_context;
mod image;
mod initialization;
mod input;
mod memory;
mod memory_arrays;
mod observation;
mod output;
mod profile;
mod registers;
mod roots;
mod select;
mod task_completion;
mod task_context;
mod task_creation;
mod task_effects;
mod task_events;
mod task_queries;
mod task_results;
mod task_resume;
mod task_roots;
mod task_scheduling;
mod task_scope_cancellation;
mod task_scopes;
mod tasks;
#[cfg(test)]
mod tasks_tests;
pub(super) use task_context::TaskContext;
mod text;
mod traps;

use std::cell::Cell as DirtyIndex;
use std::marker::PhantomData;
use std::sync::Arc;

use pseudolearn_bytecode::VerifiedBytecode;

use crate::dispatch::step;
use crate::events::{ChangeBuffer, EventPayload, TraceClass, TraceEvent};
use crate::load::{LoadedFunction, LoadedProgram, load};
use crate::model::LimitKind;
use crate::{Fuel, RunExit, RunOptions, RunResult, RuntimeValue, ServiceReason, VmTrap};
use pseudolearn_runtime::{Handle, Heap, RandomState};

pub use profile::OpcodeProfile;
use profile::{NoOpcodeObserver, OpcodeObserver};

pub(crate) enum Flow {
    Continue,
    Completed(Option<RuntimeValue>),
    Service(ServiceReason),
    AwaitingInput,
    AwaitingEffect(crate::PendingEffectRequest),
    Cancelled,
    LimitReached(LimitKind),
}

mod active_frames;
mod bank_tracking;
mod inspection;
mod query;

pub use active_frames::*;
pub use cells::Cell;
pub use delta::{MachineDelta, advance_image, compose_machine_deltas, revert_image};
pub use image::{
    MachineImage, restore_machine_image, resume_machine, snapshot_machine, snapshot_machine_lean,
    suspend_machine,
};
pub use initialization::create_owned_machine;
use initialization::execute_with;
pub use inspection::*;
pub use query::*;

mod control_state;
pub(crate) use control_state::{ControlFrame, Cursor};

pub struct Machine<'program> {
    pub(crate) program: LoadedProgram,
    pub(crate) current: Arc<LoadedFunction>,
    pub(crate) current_function_index: usize,
    pub(crate) program_lifetime: PhantomData<&'program LoadedProgram>,
    pub(crate) cursor: Cursor,
    pub(crate) scalar_limit: usize,
    pub(crate) reference_limit: usize,
    pub(crate) scalars: Vec<u64>,
    pub(crate) defined: Vec<bool>,
    pub(crate) references: Vec<u32>,
    pub(crate) frames: Vec<ControlFrame>,
    pub(crate) remaining: Fuel,
    pub(crate) output: String,
    pub(crate) heap: Heap,
    pub(crate) literals: Vec<Handle>,
    pub(crate) random: RandomState,
    pub(crate) options: RunOptions,
    pub(crate) cells: Vec<cells::Cell>,
    pub(crate) reference_watermark: usize,
    pub(crate) scalar_watermark: usize,
    pub(crate) memory_counts: Vec<crate::MemoryCount>,
    pub(crate) probed: bool,
    pub(crate) events: Vec<TraceEvent>,
    pub(crate) events_dropped: usize,
    pub(crate) change_buffer: ChangeBuffer,
    pub(crate) inputs: Vec<String>,
    pub(crate) input_index: usize,
    pub(crate) diagnostics: Vec<VmTrap>,
    pub(crate) statements_executed: u64,
    pub(crate) polls_executed: u64,
    pub(crate) input_requested_emitted: bool,
    pub(crate) output_suppressed: bool,
    pub(crate) frame_dirty_from: DirtyIndex<usize>,
    pub(crate) bank_delta_tracking: DirtyIndex<bool>,
    pub(crate) scalar_dirty_from: DirtyIndex<usize>,
    pub(crate) reference_dirty_from: DirtyIndex<usize>,
    pub(crate) defined_dirty_from: DirtyIndex<usize>,
    pub(crate) effect_result: Option<pseudolearn_runtime::HostReply>,
    pub(crate) effect_seq: u64,
    pub(crate) effect_checkpoint: Option<Box<pseudolearn_runtime::EffectCheckpoint>>,
    pub(crate) tasks: tasks::VmTasks,
}

pub fn run(program: &VerifiedBytecode, fuel: Fuel) -> RunResult {
    match load(program) {
        Ok(loaded) => run_loaded(&loaded, fuel),
        Err(trap) => trapped(trap),
    }
}

pub fn run_loaded(program: &LoadedProgram, fuel: Fuel) -> RunResult {
    run_with_options(program, fuel, RunOptions::default())
}

pub fn run_with_options(program: &LoadedProgram, fuel: Fuel, options: RunOptions) -> RunResult {
    execute_with(program, fuel, options, &mut NoOpcodeObserver)
}

pub fn run_profiled(program: &VerifiedBytecode, fuel: Fuel) -> (RunResult, OpcodeProfile) {
    let mut profile = OpcodeProfile::default();
    let result = match load(program) {
        Ok(loaded) => execute_with(&loaded, fuel, RunOptions::default(), &mut profile),
        Err(trap) => trapped(trap),
    };
    (result, profile)
}

fn trapped(trap: VmTrap) -> RunResult {
    RunResult {
        exit: RunExit::Trap(trap),
        output: String::new(),
        consumed_statements: 0,
        consumed_probes: 0,
        memory_counts: Vec::new(),
        events: Vec::new(),
        inputs_consumed: 0,
        diagnostics: Vec::new(),
    }
}

impl<'program> Machine<'program> {
    fn execute<const TASK_RUNTIME: bool, Observer: OpcodeObserver>(
        &mut self,
        observer: &mut Observer,
    ) -> RunExit {
        self.execute_loop::<TASK_RUNTIME, _>(observer)
    }

    fn execute_loop<const TASK_RUNTIME: bool, Observer: OpcodeObserver>(
        &mut self,
        observer: &mut Observer,
    ) -> RunExit {
        loop {
            if TASK_RUNTIME && let Some(exit) = self.task_preflight() {
                return exit;
            }
            if let Some(exit) = self.execute_instruction::<TASK_RUNTIME, _>(observer) {
                return exit;
            }
        }
    }

    #[inline(always)]
    fn execute_instruction<const TASK_RUNTIME: bool, Observer: OpcodeObserver>(
        &mut self,
        observer: &mut Observer,
    ) -> Option<RunExit> {
        let function = self.current.as_ref();
        let position = self.cursor.program_counter;
        observer.record(function, position);
        self.cursor.program_counter = position.wrapping_add(1);
        match step::<TASK_RUNTIME>(
            self,
            position,
            self.probed,
            function.operation(position, self.probed),
        ) {
            Ok(Flow::Continue) => None,
            Ok(Flow::Completed(value)) => match self.complete_task(value) {
                Ok(exit) => exit,
                Err(fault) => {
                    let trap = self.trap_context(fault, position);
                    self.record_failure(&trap);
                    Some(RunExit::Trap(trap))
                }
            },
            Ok(Flow::Service(reason)) => Some(RunExit::Service(reason)),
            Ok(Flow::AwaitingInput) => Some(RunExit::AwaitingInput),
            Ok(Flow::AwaitingEffect(request)) => Some(RunExit::AwaitingEffect(request)),
            Ok(Flow::Cancelled) => Some(RunExit::Cancelled),
            Ok(Flow::LimitReached(kind)) => Some(RunExit::LimitReached { kind }),
            Err(fault) => {
                let trap = self.trap_context(fault, position);
                self.record_failure(&trap);
                Some(RunExit::Trap(trap))
            }
        }
    }

    fn task_preflight(&mut self) -> Option<RunExit> {
        if let Some(request) = self.tasks.pending_delivery.take() {
            return Some(RunExit::AwaitingEffect(request));
        }
        if !self.tasks.current_is_running() {
            return Some(RunExit::Trap(VmTrap::new(
                crate::evaluate::INVALID_BYTECODE,
                None,
            )));
        }
        None
    }

    pub(crate) fn current_span(&self) -> Option<pseudolearn_bytecode::SourceSpan> {
        let position = self.cursor.program_counter.saturating_sub(1);
        self.current
            .span(position, self.probed)
            .or(self.current.declaration_span)
    }

    pub(crate) fn current_line(&self) -> u32 {
        self.current_span().map(|span| span.start_line).unwrap_or(1)
    }

    pub(crate) fn current_depth(&self) -> u32 {
        u32::try_from(self.frames.len().saturating_add(1)).unwrap_or(1)
    }

    fn record_failure(&mut self, trap: &VmTrap) {
        if self.probed {
            let line = trap
                .span
                .map(|span| span.start_line)
                .unwrap_or_else(|| self.current_line());
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Failure,
                line,
                depth,
                span: trap.span.or_else(|| self.current_span()),
                payload: Some(EventPayload::Failure {
                    codigo: trap.code.to_owned(),
                }),
            });
        }
    }

    fn finish(self, exit: RunExit, initial: Fuel) -> RunResult {
        RunResult {
            exit,
            output: self.output,
            consumed_statements: initial.statements.saturating_sub(self.remaining.statements),
            consumed_probes: initial.probes.saturating_sub(self.remaining.probes),
            memory_counts: self.memory_counts,
            events: self.events,
            inputs_consumed: self.input_index,
            diagnostics: self.diagnostics,
        }
    }
}

mod lexical_names;

mod snapshot_copy;

mod task_spill;

mod channel_buffers;

mod task_storage;

mod suspension_maps;
mod suspension_storage;
