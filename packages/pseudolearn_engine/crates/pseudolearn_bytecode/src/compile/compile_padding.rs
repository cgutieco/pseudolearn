#![forbid(unsafe_code)]

use crate::Opcode;
use crate::error::BytecodeError;
use crate::model::{CodeVariant, Instruction};

pub(super) fn pad_variant(variant: &mut CodeVariant) -> Result<(), BytecodeError> {
    let used = variant.instructions.len();
    variant.used_length = u32::try_from(used).map_err(|_| BytecodeError::InvalidModule)?;
    let padded = used
        .max(1)
        .checked_next_power_of_two()
        .filter(|length| u32::try_from(*length).is_ok())
        .ok_or(BytecodeError::InvalidModule)?;
    variant
        .instructions
        .resize(padded, unreachable_instruction());
    Ok(())
}

fn unreachable_instruction() -> Instruction {
    Instruction {
        opcode: Opcode::Unreachable,
        destination: None,
        operands: Vec::new(),
        span: None,
        return_point: None,
    }
}
