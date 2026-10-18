#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering};
use crate::{
    lower_arithmetic, lower_arrays, lower_calls, lower_cells, lower_control, lower_io, lower_math,
    lower_objects, lower_real, lower_scalars, lower_text, lower_virtual,
};
use pseudolearn_ir::Operation;

type Lower = fn(&mut Lowering<'_, '_>, &Instruction<'_>) -> Result<(), CodegenError>;

const FAMILIES: &[(&[Operation], Lower)] = &[
    (lower_scalars::OPERATIONS, lower_scalars::lower),
    (lower_arithmetic::OPERATIONS, lower_arithmetic::lower),
    (lower_real::OPERATIONS, lower_real::lower),
    (lower_control::OPERATIONS, lower_control::lower),
    (lower_math::OPERATIONS, lower_math::lower),
    (lower_text::OPERATIONS, lower_text::lower),
    (lower_arrays::OPERATIONS, lower_arrays::lower),
    (lower_objects::OPERATIONS, lower_objects::lower),
    (lower_cells::OPERATIONS, lower_cells::lower),
    (lower_io::OPERATIONS, lower_io::lower),
];

#[cfg(test)]
pub(crate) fn is_supported(operation: Operation) -> bool {
    matches!(operation, Operation::Call | Operation::CallVirtual)
        || FAMILIES
            .iter()
            .any(|(operations, _)| operations.contains(&operation))
}

pub(crate) fn lower_instruction(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operation = instruction.operation;
    match operation {
        Operation::Call => lower_calls::lower_call(lowering, instruction),
        Operation::CallVirtual => lower_virtual::lower_virtual_call(lowering, instruction),
        _ => match FAMILIES
            .iter()
            .find(|(operations, _)| operations.contains(&operation))
        {
            Some((_, lower)) => lower(lowering, instruction),
            None => Err(CodegenError::Unsupported(operation.as_str())),
        },
    }
}

#[cfg(test)]
#[path = "instruction_dispatch_tests.rs"]
mod tests;
