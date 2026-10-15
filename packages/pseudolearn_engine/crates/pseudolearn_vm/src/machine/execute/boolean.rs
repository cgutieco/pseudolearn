#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_boolean(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::BoolNot => {
                let value = self.read_boolean(instruction, 0)?;
                self.write_scalar(instruction, u64::from(!value))
            }
            Opcode::BoolCmp => {
                let predicate = match instruction.operands.first() {
                    Some(BytecodeOperand::Predicate(value)) => value,
                    _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
                };
                let left = self.read_boolean(instruction, 1)?;
                let right = self.read_boolean(instruction, 2)?;
                let result = match predicate.as_str() {
                    "eq" => left == right,
                    "ne" => left != right,
                    _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
                };
                self.write_scalar(instruction, u64::from(result))
            }
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }
}
