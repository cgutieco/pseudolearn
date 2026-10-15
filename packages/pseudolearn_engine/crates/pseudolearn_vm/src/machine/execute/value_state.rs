#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_value_state(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::ValueUndefined => self.mark_undefined(instruction),
            Opcode::ValueRequire => self.require_value(instruction),
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }

    fn mark_undefined(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let destination = instruction
            .destination
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        let frame = self
            .frames
            .last_mut()
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        frame
            .mark_undefined(destination)
            .map_err(|_| VmTrap::new("invalidBytecode", instruction.span))?;
        Ok(StepOutcome::Continue)
    }

    fn require_value(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let source = match instruction.operands.first() {
            Some(BytecodeOperand::Register(register)) => *register,
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        let (is_defined, value) = {
            let frame = self
                .frames
                .last()
                .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
            let is_defined = frame
                .is_defined(source)
                .map_err(|_| VmTrap::new("invalidBytecode", instruction.span))?;
            let value = frame
                .read(source)
                .map_err(|_| VmTrap::new("invalidBytecode", instruction.span))?;
            (is_defined, value)
        };
        if !is_defined {
            return Err(VmTrap::new("uninitializedVariableRead", instruction.span));
        }
        self.write_destination(instruction.destination, value, instruction.span)?;
        Ok(StepOutcome::Continue)
    }
}
