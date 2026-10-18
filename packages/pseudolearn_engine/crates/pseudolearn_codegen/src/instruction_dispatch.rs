#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering};
use crate::{lower_arithmetic, lower_calls, lower_control, lower_real, lower_scalars};
use pseudolearn_ir::Operation;

pub(crate) fn lower_instruction(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operation = instruction.operation;
    if lower_scalars::OPERATIONS.contains(&operation) {
        return lower_scalars::lower(lowering, instruction);
    }
    if lower_arithmetic::OPERATIONS.contains(&operation) {
        return lower_arithmetic::lower(lowering, instruction);
    }
    if lower_real::OPERATIONS.contains(&operation) {
        return lower_real::lower(lowering, instruction);
    }
    if lower_control::OPERATIONS.contains(&operation) {
        return lower_control::lower(lowering, instruction);
    }
    if operation == Operation::Call {
        return lower_calls::lower_call(lowering, instruction);
    }
    Err(CodegenError::Unsupported(operation.as_str()))
}
