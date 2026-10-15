#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BasicBlock, BytecodeFunction, Instruction, Register, SourceSpan, VerifiedBytecode,
};

use crate::frame::Frame;
use crate::{Fuel, RunExit, RunResult, RuntimeValue, ServiceReason, VmTrap};

mod execute;
mod lookup;
mod profile;

pub use execute::run;
pub use execute::run_profiled;
pub use profile::OpcodeProfile;
pub(super) use profile::{NoOpcodeObserver, OpcodeObserver};

struct Machine<'program> {
    program: &'program VerifiedBytecode,
    frames: Vec<Frame>,
    remaining: Fuel,
    consumed_statements: u64,
    consumed_probes: u64,
    output: String,
}

struct BlockTransfer<'block> {
    program_counter: u32,
    target: &'block BasicBlock,
    arguments: &'block [Register],
    span: Option<SourceSpan>,
}

struct Invocation<'arguments> {
    target_index: u16,
    arguments: &'arguments [Register],
    destination: Option<Register>,
    return_point: Option<u32>,
    span: Option<SourceSpan>,
}

struct CompareBranch<'code> {
    compare_pc: u32,
    compare: &'code Instruction,
    branch_pc: u32,
    branch: &'code Instruction,
}

enum StepOutcome {
    Continue,
    Exit(RunExit),
}

impl<'program> Machine<'program> {
    fn start(program: &'program VerifiedBytecode, fuel: Fuel) -> Result<Self, VmTrap> {
        let module = program.module();
        let entry_index = lookup::entry_index(module)?;
        let function = lookup::function_at(module, entry_index)?;
        let frame = Frame::new(entry_index, function, None, None)?;
        Ok(Self {
            program,
            frames: vec![frame],
            remaining: fuel,
            consumed_statements: 0,
            consumed_probes: 0,
            output: String::new(),
        })
    }

    fn execute<Observer: OpcodeObserver>(mut self, observer: &mut Observer) -> RunResult {
        loop {
            match self.charge_block() {
                Ok(Some(reason)) => return self.finish(RunExit::Service(reason)),
                Err(trap) => return self.finish(RunExit::Trap(trap)),
                Ok(None) => {}
            }
            match self.execute_step(observer) {
                Ok(StepOutcome::Continue) => {}
                Ok(StepOutcome::Exit(exit)) => return self.finish(exit),
                Err(trap) => return self.finish(RunExit::Trap(trap)),
            }
        }
    }

    fn execute_step<Observer: OpcodeObserver>(
        &mut self,
        observer: &mut Observer,
    ) -> Result<StepOutcome, VmTrap> {
        let frame = self
            .frames
            .last()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        let function_index = frame.function_index;
        let program_counter = frame.program_counter;
        let instruction = lookup::fetch_instruction(self.program, function_index, program_counter)?;
        observer.record(instruction.opcode);
        let branch_pc = self
            .program
            .module()
            .functions
            .get(usize::from(function_index))
            .and_then(|function| function.fast.superinstructions.get(&program_counter))
            .copied();
        match branch_pc {
            Some(branch_pc) => self.execute_superinstruction(observer, instruction, branch_pc),
            None => self.step_instruction(program_counter, instruction),
        }
    }

    fn execute_superinstruction<Observer: OpcodeObserver>(
        &mut self,
        observer: &mut Observer,
        instruction: &Instruction,
        branch_pc: u32,
    ) -> Result<StepOutcome, VmTrap> {
        let frame = self
            .frames
            .last()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        let function_index = frame.function_index;
        let program_counter = frame.program_counter;
        let branch = lookup::fetch_instruction(self.program, function_index, branch_pc)?;
        observer.record(branch.opcode);
        self.step_compare_branch(CompareBranch {
            compare_pc: program_counter,
            compare: instruction,
            branch_pc,
            branch,
        })
    }

    fn current_function(&self) -> Result<&BytecodeFunction, VmTrap> {
        let frame = self
            .frames
            .last()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        lookup::function_at(self.program.module(), frame.function_index)
    }

    fn read_register(&self, register: Register) -> Result<RuntimeValue, VmTrap> {
        self.frames
            .last()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?
            .read(register)
    }

    fn write_destination(
        &mut self,
        destination: Option<Register>,
        value: RuntimeValue,
        span: Option<SourceSpan>,
    ) -> Result<(), VmTrap> {
        let register = destination.ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        self.frames
            .last_mut()
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?
            .write(register, value)
            .map_err(|_| VmTrap::new("invalidBytecode", span))
    }

    fn transfer_to_block(
        &mut self,
        transfer: BlockTransfer<'_>,
    ) -> Result<Option<ServiceReason>, VmTrap> {
        if transfer.target.parameters.len() != transfer.arguments.len() {
            return Err(VmTrap::new("invalidBytecode", transfer.span));
        }
        if lookup::is_empty_backedge(transfer.program_counter, transfer.target) {
            if self.remaining.probes == 0 {
                return Ok(Some(ServiceReason::Probe));
            }
            self.remaining.probes = self.remaining.probes.saturating_sub(1);
            self.consumed_probes = self.consumed_probes.saturating_add(1);
        }
        let frame = self
            .frames
            .last_mut()
            .ok_or_else(|| VmTrap::new("invalidBytecode", transfer.span))?;
        frame.copy_parallel(transfer.arguments, &transfer.target.parameters)?;
        frame.program_counter = transfer.target.start_pc;
        frame.pending_block_mass = transfer.target.mass;
        frame.needs_block_charge = true;
        Ok(None)
    }

    fn invoke(&mut self, invocation: Invocation<'_>) -> Result<(), VmTrap> {
        let target = lookup::function_at(self.program.module(), invocation.target_index)?;
        if target.parameters.len() != invocation.arguments.len() {
            return Err(VmTrap::new("invalidBytecode", invocation.span));
        }
        let values = invocation
            .arguments
            .iter()
            .map(|register| self.read_register(*register))
            .collect::<Result<Vec<_>, _>>()?;
        let mut callee = Frame::new(
            invocation.target_index,
            target,
            invocation.destination,
            invocation.return_point,
        )?;
        for (parameter, value) in target.parameters.iter().zip(values) {
            callee.write(*parameter, value)?;
        }
        self.frames.push(callee);
        Ok(())
    }

    fn return_from_function(
        &mut self,
        value: Option<RuntimeValue>,
        span: Option<SourceSpan>,
    ) -> Result<Option<RunExit>, VmTrap> {
        let callee = self
            .frames
            .pop()
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        let Some(caller) = self.frames.last_mut() else {
            return Ok(Some(RunExit::Completed(value)));
        };
        let point_id = callee
            .return_point
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        let caller_function = lookup::function_at(self.program.module(), caller.function_index)?;
        let continuation_matches = caller_function.return_points.iter().any(|point| {
            point.identifier == point_id && point.fast_continuation_pc == caller.program_counter
        });
        if !continuation_matches {
            return Err(VmTrap::new("invalidBytecode", span));
        }
        if let (Some(destination), Some(result)) = (callee.return_destination, value) {
            caller.write(destination, result)?;
        }
        Ok(None)
    }

    fn charge_block(&mut self) -> Result<Option<ServiceReason>, VmTrap> {
        let Some(frame) = self.frames.last() else {
            return Err(VmTrap::new("invalidBytecode", None));
        };
        if !frame.needs_block_charge {
            return Ok(None);
        }
        let mass = u64::from(frame.pending_block_mass);
        if mass > self.remaining.statements {
            return Ok(Some(ServiceReason::Statements));
        }
        self.remaining.statements = self.remaining.statements.saturating_sub(mass);
        self.consumed_statements = self.consumed_statements.saturating_add(mass);
        if let Some(frame) = self.frames.last_mut() {
            frame.needs_block_charge = false;
        }
        Ok(None)
    }

    fn finish(self, exit: RunExit) -> RunResult {
        RunResult {
            exit,
            output: self.output,
            consumed_statements: self.consumed_statements,
            consumed_probes: self.consumed_probes,
        }
    }
}
