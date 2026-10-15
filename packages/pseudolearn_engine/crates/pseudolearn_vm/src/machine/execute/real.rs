#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode};
use pseudolearn_library::{LibraryError, square_root};
use pseudolearn_runtime::{real_add, real_divide, real_multiply, real_subtract};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_real(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::RealAdd => self.real_binary(instruction, real_add),
            Opcode::RealSub => self.real_binary(instruction, real_subtract),
            Opcode::RealMul => self.real_binary(instruction, real_multiply),
            Opcode::RealDiv => self.real_binary(instruction, real_divide),
            Opcode::RealNeg => {
                let value = self.read_real(instruction, 0)?;
                self.write_real(instruction, f64::from_bits(value.to_bits() ^ (1_u64 << 63)))
            }
            Opcode::RealCmp => self.real_compare(instruction),
            Opcode::RealTrunc => self.convert_real_to_integer(instruction, false),
            Opcode::RealRound => self.convert_real_to_integer(instruction, true),
            Opcode::MathSqrt => self.square_root(instruction),
            Opcode::MathAbs => {
                let value = self.read_real(instruction, 0)?;
                self.write_real(instruction, pseudolearn_library::absolute(value))
            }
            _ => Err(VmTrap::new("unsupportedOperation", instruction.span)),
        }
    }

    fn real_binary(
        &mut self,
        instruction: &Instruction,
        operation: fn(f64, f64) -> Result<f64, pseudolearn_runtime::ArithmeticError>,
    ) -> Result<StepOutcome, VmTrap> {
        let left = self.read_real(instruction, 0)?;
        let right = self.read_real(instruction, 1)?;
        let result =
            operation(left, right).map_err(|error| self.error_trap(error, instruction.span))?;
        self.write_real(instruction, result)
    }

    fn real_compare(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let predicate = match instruction.operands.first() {
            Some(BytecodeOperand::Predicate(value)) => value.as_str(),
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        let left = self.read_real(instruction, 1)?;
        let right = self.read_real(instruction, 2)?;
        let result = compare_real(predicate, left, right)?;
        self.write_scalar(instruction, u64::from(result))
    }

    fn convert_real_to_integer(
        &mut self,
        instruction: &Instruction,
        rounded: bool,
    ) -> Result<StepOutcome, VmTrap> {
        let value = self.read_real(instruction, 0)?;
        let result = if rounded {
            pseudolearn_library::round_real(value)
        } else {
            pseudolearn_library::truncate_real(value)
        }
        .map_err(|error| self.error_trap(error, instruction.span))?;
        self.write_integer(instruction, result)
    }

    fn square_root(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let value = self.read_real(instruction, 0)?;
        let result = square_root(value).map_err(|error| match error {
            LibraryError::Arithmetic(arithmetic) => self.error_trap(arithmetic, instruction.span),
            LibraryError::NegativeSquareRoot => VmTrap::new("negativeSquareRoot", instruction.span),
            LibraryError::NonFiniteInput => VmTrap::new("nonFiniteRealResult", instruction.span),
        })?;
        self.write_real(instruction, result)
    }
}

fn compare_real(predicate: &str, left: f64, right: f64) -> Result<bool, VmTrap> {
    match predicate {
        "eq" => Ok(left == right),
        "ne" => Ok(left != right),
        "lt" => Ok(left < right),
        "le" => Ok(left <= right),
        "gt" => Ok(left > right),
        "ge" => Ok(left >= right),
        _ => Err(VmTrap::new("invalidBytecode", None)),
    }
}
