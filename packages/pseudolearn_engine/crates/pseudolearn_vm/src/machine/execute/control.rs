#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

use crate::machine::{BlockTransfer, Invocation, Machine, StepOutcome};
use crate::{RunExit, VmTrap};

impl Machine<'_> {
    pub(super) fn execute_control(
        &mut self,
        program_counter: u32,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::Jump => self.jump(program_counter, instruction, 0),
            Opcode::Branch => self.branch(program_counter, instruction),
            Opcode::Call => self.call(instruction),
            Opcode::Return => self.return_from_call(instruction),
            Opcode::LoopCheckStep => self.check_loop_step(instruction),
            Opcode::TrapMissingReturn => Err(VmTrap::new("missingReturn", instruction.span)),
            Opcode::Unreachable => Err(VmTrap::new("unreachable", instruction.span)),
            _ => Err(VmTrap::new("unsupportedOperation", instruction.span)),
        }
    }

    fn jump(
        &mut self,
        program_counter: u32,
        instruction: &Instruction,
        target_position: usize,
    ) -> Result<StepOutcome, VmTrap> {
        let target_operand = instruction
            .operands
            .get(target_position)
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        let BytecodeOperand::BlockTarget { target, arguments } = target_operand else {
            return Err(VmTrap::new("invalidBytecode", instruction.span));
        };
        let block = self
            .current_function()?
            .fast
            .blocks
            .iter()
            .find(|block| block.identifier == *target)
            .cloned()
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        match self.transfer_to_block(BlockTransfer {
            program_counter,
            target: &block,
            arguments,
            span: instruction.span,
        })? {
            Some(reason) => Ok(StepOutcome::Exit(RunExit::Service(reason))),
            None => Ok(StepOutcome::Continue),
        }
    }

    fn branch(
        &mut self,
        program_counter: u32,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        let positive = self.read_boolean(instruction, 0)?;
        let target_position = if positive { 1 } else { 2 };
        self.jump(program_counter, instruction, target_position)
    }

    fn call(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let operand = instruction
            .operands
            .first()
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        let BytecodeOperand::FunctionTarget {
            function_index,
            arguments,
        } = operand
        else {
            return Err(VmTrap::new("invalidBytecode", instruction.span));
        };
        self.invoke(Invocation {
            target_index: *function_index,
            arguments,
            destination: instruction.destination,
            return_point: instruction.return_point,
            span: instruction.span,
        })?;
        Ok(StepOutcome::Continue)
    }

    fn return_from_call(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let result = match instruction.operands.first() {
            Some(BytecodeOperand::Register(register)) => Some(self.read_register(*register)?),
            None => None,
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        match self.return_from_function(result, instruction.span)? {
            Some(exit) => Ok(StepOutcome::Exit(exit)),
            None => Ok(StepOutcome::Continue),
        }
    }

    fn check_loop_step(&self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        if self.read_integer(instruction, 0)? == 0 {
            Err(VmTrap::new("zeroStepInCountedLoop", instruction.span))
        } else {
            Ok(StepOutcome::Continue)
        }
    }
}
