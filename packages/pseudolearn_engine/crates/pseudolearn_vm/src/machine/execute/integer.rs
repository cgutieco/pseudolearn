#![forbid(unsafe_code)]

use pseudolearn_bytecode::{Instruction, Opcode};
use pseudolearn_library::integer_to_real;
use pseudolearn_runtime::{
    int_add, int_divide, int_modulo, int_multiply, int_negate, int_power, int_subtract,
};

use crate::VmTrap;
use crate::machine::{Machine, StepOutcome};

impl Machine<'_> {
    pub(super) fn execute_integer(
        &mut self,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        match instruction.opcode {
            Opcode::IntAdd => self.integer_binary(instruction, int_add),
            Opcode::IntSub => self.integer_binary(instruction, int_subtract),
            Opcode::IntMul => self.integer_binary(instruction, int_multiply),
            Opcode::IntDiv => self.integer_binary(instruction, int_divide),
            Opcode::IntMod => self.integer_binary(instruction, int_modulo),
            Opcode::IntPow => self.integer_binary(instruction, int_power),
            Opcode::IntNeg => {
                let value = self.read_integer(instruction, 0)?;
                let result =
                    int_negate(value).map_err(|error| self.error_trap(error, instruction.span))?;
                self.write_integer(instruction, result)
            }
            Opcode::IntCmp => self.integer_compare(instruction),
            Opcode::IntToReal => {
                let value = self.read_integer(instruction, 0)?;
                self.write_real(instruction, integer_to_real(value))
            }
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }

    fn integer_binary(
        &mut self,
        instruction: &Instruction,
        operation: fn(i64, i64) -> Result<i64, pseudolearn_runtime::ArithmeticError>,
    ) -> Result<StepOutcome, VmTrap> {
        let left = self.read_integer(instruction, 0)?;
        let right = self.read_integer(instruction, 1)?;
        let result =
            operation(left, right).map_err(|error| self.error_trap(error, instruction.span))?;
        self.write_integer(instruction, result)
    }

    fn integer_compare(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let predicate = self.read_predicate(instruction, 0)?;
        let left = self.read_integer(instruction, 1)?;
        let right = self.read_integer(instruction, 2)?;
        let result = compare_integer(predicate, left, right)?;
        self.write_scalar(instruction, u64::from(result))
    }

    fn read_predicate<'instruction>(
        &self,
        instruction: &'instruction Instruction,
        operand_index: usize,
    ) -> Result<&'instruction str, VmTrap> {
        match instruction.operands.get(operand_index) {
            Some(pseudolearn_bytecode::BytecodeOperand::Predicate(value)) => Ok(value),
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }
}

pub(super) fn compare_integer(predicate: &str, left: i64, right: i64) -> Result<bool, VmTrap> {
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
