#![forbid(unsafe_code)]

use crate::Opcode;
use crate::error::{BytecodeError, VerificationRule};
use crate::model::CodeVariant;

const PADDING_ERROR: BytecodeError = BytecodeError::Verification(VerificationRule::Padding);

pub(crate) fn used_length(variant: &CodeVariant) -> Result<usize, BytecodeError> {
    usize::try_from(variant.used_length).map_err(|_| PADDING_ERROR)
}

pub(crate) fn verify_padding(variant: &CodeVariant) -> Result<(), BytecodeError> {
    let length = variant.instructions.len();
    let used = used_length(variant)?;
    if !length.is_power_of_two() || used > length || used == 0 {
        return Err(PADDING_ERROR);
    }
    let tail = variant.instructions.get(used..).ok_or(PADDING_ERROR)?;
    let only_unreachable = tail.iter().all(|instruction| {
        instruction.opcode == Opcode::Unreachable
            && instruction.destination.is_none()
            && instruction.operands.is_empty()
            && instruction.return_point.is_none()
    });
    if only_unreachable {
        Ok(())
    } else {
        Err(PADDING_ERROR)
    }
}
