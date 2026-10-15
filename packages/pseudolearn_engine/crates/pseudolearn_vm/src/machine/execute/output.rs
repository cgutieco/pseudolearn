#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_output(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        if instruction.opcode != Opcode::OutWrite {
            return Err(VmTrap::new("invalidBytecode", instruction.span));
        }
        let value = self.read_integer(instruction, 0)?;
        self.output.push_str(&value.to_string());
        match instruction.operands.get(1) {
            Some(BytecodeOperand::Newline) => self.output.push('\n'),
            None => {}
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
        Ok(StepOutcome::Continue)
    }
}
