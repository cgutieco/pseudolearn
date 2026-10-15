#![forbid(unsafe_code)]

mod calls;
mod control;
mod output;
mod profile;
mod registers;
mod traps;

use pseudolearn_bytecode::{Register, VerifiedBytecode};

use crate::dispatch::step;
use crate::load::{LoadedFunction, LoadedProgram, load};
use crate::{Fuel, RunExit, RunResult, RuntimeValue, ServiceReason, VmTrap};

pub use profile::OpcodeProfile;
use profile::{NoOpcodeObserver, OpcodeObserver};

const INITIAL_BANK_WORDS: usize = 64;

pub(crate) enum Flow {
    Continue,
    Completed(Option<RuntimeValue>),
    Service(ServiceReason),
}

#[derive(Clone, Copy)]
struct Cursor {
    program_counter: usize,
    scalar_base: usize,
    reference_base: usize,
}

#[derive(Clone, Copy)]
struct ControlFrame<'program> {
    function: &'program LoadedFunction,
    return_point: usize,
    destination: Option<Register>,
    scalar_base: usize,
    reference_base: usize,
}

pub(crate) struct Machine<'program> {
    program: &'program LoadedProgram,
    current: &'program LoadedFunction,
    cursor: Cursor,
    scalars: Vec<u64>,
    defined: Vec<bool>,
    references: Vec<u32>,
    frames: Vec<ControlFrame<'program>>,
    remaining: Fuel,
    output: String,
}

pub fn run(program: &VerifiedBytecode, fuel: Fuel) -> RunResult {
    match load(program) {
        Ok(loaded) => run_loaded(&loaded, fuel),
        Err(trap) => trapped(trap),
    }
}

pub fn run_loaded(program: &LoadedProgram, fuel: Fuel) -> RunResult {
    execute_with(program, fuel, &mut NoOpcodeObserver)
}

pub fn run_profiled(program: &VerifiedBytecode, fuel: Fuel) -> (RunResult, OpcodeProfile) {
    let mut profile = OpcodeProfile::default();
    let result = match load(program) {
        Ok(loaded) => execute_with(&loaded, fuel, &mut profile),
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
    }
}

fn execute_with<Observer: OpcodeObserver>(
    program: &LoadedProgram,
    fuel: Fuel,
    observer: &mut Observer,
) -> RunResult {
    match Machine::start(program, fuel) {
        Ok(mut machine) => {
            let exit = machine
                .enter_entry()
                .unwrap_or_else(|| machine.execute(observer));
            machine.finish(exit, fuel)
        }
        Err(trap) => trapped(trap),
    }
}

impl<'program> Machine<'program> {
    fn start(program: &'program LoadedProgram, fuel: Fuel) -> Result<Self, VmTrap> {
        let current = program
            .functions
            .get(program.entry)
            .ok_or_else(|| VmTrap::new("missingEntryPoint", None))?;
        let mut machine = Self {
            program,
            current,
            cursor: Cursor {
                program_counter: 0,
                scalar_base: 0,
                reference_base: 0,
            },
            scalars: Vec::new(),
            defined: Vec::new(),
            references: Vec::new(),
            frames: Vec::new(),
            remaining: fuel,
            output: String::new(),
        };
        let scalar_end = current.scalar_window.max(INITIAL_BANK_WORDS);
        let reference_end = current.reference_window.max(INITIAL_BANK_WORDS);
        machine
            .ensure_capacity(scalar_end, reference_end)
            .map_err(|fault| VmTrap::new(fault, None))?;
        Ok(machine)
    }

    fn enter_entry(&mut self) -> Option<RunExit> {
        match self.charge_entry(self.current.entry_mass) {
            Flow::Service(reason) => Some(RunExit::Service(reason)),
            Flow::Continue | Flow::Completed(_) => None,
        }
    }

    fn execute<Observer: OpcodeObserver>(&mut self, observer: &mut Observer) -> RunExit {
        loop {
            let function = self.current;
            let position = self.cursor.program_counter;
            observer.record(function, position);
            self.cursor.program_counter = position.wrapping_add(1);
            match step(self, function.operation(position)) {
                Ok(Flow::Continue) => {}
                Ok(Flow::Completed(value)) => return RunExit::Completed(value),
                Ok(Flow::Service(reason)) => return RunExit::Service(reason),
                Err(fault) => return RunExit::Trap(VmTrap::new(fault, function.span(position))),
            }
        }
    }

    fn finish(self, exit: RunExit, initial: Fuel) -> RunResult {
        RunResult {
            exit,
            output: self.output,
            consumed_statements: initial.statements.saturating_sub(self.remaining.statements),
            consumed_probes: initial.probes.saturating_sub(self.remaining.probes),
        }
    }
}
