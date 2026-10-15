#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_character(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::CharCmp => self.compare_characters(instruction),
            Opcode::CharCode => {
                let word = self.read_scalar(instruction, 0)?;
                let scalar = u32::try_from(word)
                    .map_err(|_| VmTrap::new("invalidBytecode", instruction.span))?;
                self.write_integer(instruction, i64::from(scalar))
            }
            Opcode::CharFromCode => self.character_from_code(instruction),
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }

    fn compare_characters(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let predicate = match instruction.operands.first() {
            Some(BytecodeOperand::Predicate(value)) => value.as_str(),
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        let left = self.read_scalar(instruction, 1)?;
        let right = self.read_scalar(instruction, 2)?;
        let result = match predicate {
            "eq" => left == right,
            "ne" => left != right,
            "lt" => left < right,
            "le" => left <= right,
            "gt" => left > right,
            "ge" => left >= right,
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        self.write_scalar(instruction, u64::from(result))
    }

    fn character_from_code(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let code = self.read_integer(instruction, 0)?;
        let scalar = u32::try_from(code)
            .map_err(|_| VmTrap::new("invalidCharacterCode", instruction.span))?;
        let character = char::from_u32(scalar)
            .ok_or_else(|| VmTrap::new("invalidCharacterCode", instruction.span))?;
        self.write_scalar(instruction, u64::from(u32::from(character)))
    }
}
