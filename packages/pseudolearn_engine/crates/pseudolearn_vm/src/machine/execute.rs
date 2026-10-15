#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeOperand, Constant, Instruction, RegisterClass, SourceSpan, VerifiedBytecode,
};
use pseudolearn_runtime::ArithmeticError;

use crate::machine::{CompareBranch, Machine, NoOpcodeObserver, OpcodeProfile, StepOutcome};
use crate::{DispatchKind, Fuel, RunExit, RunResult, RuntimeValue, VmTrap, dispatch_kind};

mod boolean;
mod character;
mod control;
mod integer;
mod output;
mod real;
mod value_state;

pub fn run(program: &VerifiedBytecode, fuel: Fuel) -> RunResult {
    let mut observer = NoOpcodeObserver;
    match Machine::start(program, fuel) {
        Ok(machine) => machine.execute(&mut observer),
        Err(trap) => RunResult {
            exit: RunExit::Trap(trap),
            output: String::new(),
            consumed_statements: 0,
            consumed_probes: 0,
        },
    }
}

pub fn run_profiled(program: &VerifiedBytecode, fuel: Fuel) -> (RunResult, OpcodeProfile) {
    let mut profile = OpcodeProfile::default();
    let result = match Machine::start(program, fuel) {
        Ok(machine) => machine.execute(&mut profile),
        Err(trap) => RunResult {
            exit: RunExit::Trap(trap),
            output: String::new(),
            consumed_statements: 0,
            consumed_probes: 0,
        },
    };
    (result, profile)
}

impl Machine<'_> {
    pub(super) fn step_compare_branch(
        &mut self,
        step: CompareBranch<'_>,
    ) -> Result<StepOutcome, VmTrap> {
        self.advance_program_counter(step.compare.span)?;
        let _ = match step.compare.opcode {
            pseudolearn_bytecode::Opcode::IntCmp => self.execute_integer(step.compare)?,
            pseudolearn_bytecode::Opcode::RealCmp => self.execute_real(step.compare)?,
            _ => return Err(VmTrap::new("invalidBytecode", step.compare.span)),
        };
        let expected_branch_pc = step
            .compare_pc
            .checked_add(1)
            .ok_or_else(|| VmTrap::new("invalidBytecode", step.compare.span))?;
        if step.branch_pc != expected_branch_pc {
            return Err(VmTrap::new("invalidBytecode", step.compare.span));
        }
        self.advance_program_counter(step.branch.span)?;
        self.execute_control(step.branch_pc, step.branch)
    }

    pub(super) fn step_instruction(
        &mut self,
        program_counter: u32,
        instruction: &Instruction,
    ) -> Result<StepOutcome, VmTrap> {
        self.advance_program_counter(instruction.span)?;
        match dispatch_kind(instruction.opcode) {
            DispatchKind::Constant => self.execute_constant(instruction),
            DispatchKind::ValueState => self.execute_value_state(instruction),
            DispatchKind::Integer => self.execute_integer(instruction),
            DispatchKind::Real => self.execute_real(instruction),
            DispatchKind::Boolean => self.execute_boolean(instruction),
            DispatchKind::Character => self.execute_character(instruction),
            DispatchKind::Control => self.execute_control(program_counter, instruction),
            DispatchKind::Observation => Ok(StepOutcome::Continue),
            DispatchKind::Output => self.execute_output(instruction),
            DispatchKind::Other => Err(VmTrap::new("unsupportedOperation", instruction.span)),
        }
    }

    pub(crate) fn read_scalar(
        &self,
        instruction: &Instruction,
        operand_index: usize,
    ) -> Result<u64, VmTrap> {
        let operand = instruction
            .operands
            .get(operand_index)
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        match operand {
            BytecodeOperand::Register(register) if register.class == RegisterClass::Scalar => self
                .frames
                .last()
                .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?
                .read_scalar(register.index),
            BytecodeOperand::Constant(index) => self.constant_scalar(*index, instruction.span),
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }

    pub(crate) fn read_integer(
        &self,
        instruction: &Instruction,
        operand_index: usize,
    ) -> Result<i64, VmTrap> {
        let word = self.read_scalar(instruction, operand_index)?;
        Ok(i64::from_ne_bytes(word.to_ne_bytes()))
    }

    pub(crate) fn read_real(
        &self,
        instruction: &Instruction,
        operand_index: usize,
    ) -> Result<f64, VmTrap> {
        Ok(f64::from_bits(
            self.read_scalar(instruction, operand_index)?,
        ))
    }

    pub(crate) fn read_boolean(
        &self,
        instruction: &Instruction,
        operand_index: usize,
    ) -> Result<bool, VmTrap> {
        match self.read_scalar(instruction, operand_index)? {
            0 => Ok(false),
            1 => Ok(true),
            _ => Err(VmTrap::new("invalidBytecode", instruction.span)),
        }
    }

    pub(crate) fn write_scalar(
        &mut self,
        instruction: &Instruction,
        word: u64,
    ) -> Result<StepOutcome, VmTrap> {
        let register = instruction
            .destination
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        if register.class != RegisterClass::Scalar {
            return Err(VmTrap::new("invalidBytecode", instruction.span));
        }
        self.frames
            .last_mut()
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?
            .write_scalar(register.index, word)
            .map_err(|_| VmTrap::new("invalidBytecode", instruction.span))?;
        Ok(StepOutcome::Continue)
    }

    fn constant_scalar(&self, index: u16, span: Option<SourceSpan>) -> Result<u64, VmTrap> {
        let constant = self
            .current_function()?
            .constants
            .get(usize::from(index))
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        match constant {
            Constant::I64(value) => Ok(u64::from_ne_bytes(value.to_ne_bytes())),
            Constant::F64(value) => Ok(value.to_bits()),
            Constant::Bool(value) => Ok(u64::from(*value)),
            Constant::Char(value) => Ok(u64::from(u32::from(*value))),
            Constant::Str(_) => Err(VmTrap::new("unsupportedValue", span)),
        }
    }

    pub(crate) fn write_integer(
        &mut self,
        instruction: &Instruction,
        value: i64,
    ) -> Result<StepOutcome, VmTrap> {
        self.write_scalar(instruction, u64::from_ne_bytes(value.to_ne_bytes()))
    }

    pub(crate) fn write_real(
        &mut self,
        instruction: &Instruction,
        value: f64,
    ) -> Result<StepOutcome, VmTrap> {
        self.write_scalar(instruction, value.to_bits())
    }

    pub(crate) fn error_trap(&self, error: ArithmeticError, span: Option<SourceSpan>) -> VmTrap {
        let code = match error {
            ArithmeticError::DivisionByZero => "divisionByZero",
            ArithmeticError::IntegerOverflow => "integerOverflow",
            ArithmeticError::NegativeExponent => "negativeIntegerExponent",
            ArithmeticError::NonFiniteRealResult => "nonFiniteRealResult",
        };
        VmTrap::new(code, span)
    }

    fn execute_constant(&mut self, instruction: &Instruction) -> Result<StepOutcome, VmTrap> {
        let operand = instruction
            .operands
            .first()
            .ok_or_else(|| VmTrap::new("invalidBytecode", instruction.span))?;
        let value = match operand {
            BytecodeOperand::Constant(index) => self.constant_value(*index, instruction.span)?,
            _ => return Err(VmTrap::new("invalidBytecode", instruction.span)),
        };
        self.write_destination(instruction.destination, value, instruction.span)?;
        Ok(StepOutcome::Continue)
    }

    fn constant_value(&self, index: u16, span: Option<SourceSpan>) -> Result<RuntimeValue, VmTrap> {
        let constant = self
            .current_function()?
            .constants
            .get(usize::from(index))
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        match constant {
            Constant::I64(value) => Ok(RuntimeValue::Scalar(u64::from_ne_bytes(
                value.to_ne_bytes(),
            ))),
            Constant::F64(value) => Ok(RuntimeValue::Scalar(value.to_bits())),
            Constant::Bool(value) => Ok(RuntimeValue::Scalar(u64::from(*value))),
            Constant::Char(value) => Ok(RuntimeValue::Scalar(u64::from(u32::from(*value)))),
            Constant::Str(_) => Err(VmTrap::new("unsupportedValue", span)),
        }
    }

    fn advance_program_counter(&mut self, span: Option<SourceSpan>) -> Result<(), VmTrap> {
        let frame = self
            .frames
            .last_mut()
            .ok_or_else(|| VmTrap::new("invalidBytecode", span))?;
        frame.program_counter = frame
            .program_counter
            .checked_add(1)
            .ok_or_else(|| VmTrap::new("resourceLimit", span))?;
        Ok(())
    }
}
