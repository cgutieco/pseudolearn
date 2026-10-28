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
    (
        crate::lower_collections::OPERATIONS,
        crate::lower_collections::lower,
    ),
    (
        crate::lower_variant_values::OPERATIONS,
        crate::lower_variant_values::lower,
    ),
    (crate::lower_switch::OPERATIONS, crate::lower_switch::lower),
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
    (
        crate::lower_effects::OPERATIONS,
        crate::lower_effects::lower,
    ),
    (
        crate::lower_snapshot::OPERATIONS,
        crate::lower_snapshot::lower,
    ),
];

pub(crate) const UNSUPPORTED_OPERATIONS: &[Operation] = &[
    Operation::TaskScopeOpen,
    Operation::TaskSpawn,
    Operation::TaskAwait,
    Operation::TaskScopeJoin,
    Operation::CallSuspendible,
    Operation::EffectAwait,
    Operation::TaskChannel,
    Operation::TaskValueLoad,
    Operation::TaskOutcome,
    Operation::TaskScopeResult,
    Operation::TaskCancelPoint,
    Operation::TaskScopeBoundary,
];

#[cfg(test)]
pub(crate) fn is_accounted_for(operation: Operation) -> bool {
    matches!(
        operation,
        Operation::Call | Operation::CallVirtual | Operation::CallIndirect
    ) || FAMILIES
        .iter()
        .any(|(operations, _)| operations.contains(&operation))
        || UNSUPPORTED_OPERATIONS.contains(&operation)
}

pub(crate) fn lower_instruction(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let operation = instruction.operation;
    match operation {
        Operation::CallIndirect => crate::lower_indirect::lower(lowering, instruction),
        Operation::Call => lower_calls::lower_call(lowering, instruction),
        Operation::CallVirtual => lower_virtual::lower_virtual_call(lowering, instruction),
        _ => match FAMILIES
            .iter()
            .find(|(operations, _)| operations.contains(&operation))
        {
            Some((_, lower)) => lower(lowering, instruction),
            None if UNSUPPORTED_OPERATIONS.contains(&operation) => {
                Err(CodegenError::Unsupported(operation.as_str()))
            }
            None => Err(CodegenError::InvalidModule("operation without lowering")),
        },
    }
}

#[cfg(test)]
#[path = "instruction_dispatch_tests.rs"]
mod tests;
