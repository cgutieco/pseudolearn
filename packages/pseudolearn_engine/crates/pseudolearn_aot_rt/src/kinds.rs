use crate::trap::Trap;
use pseudolearn_runtime::ValueKind;

pub const KIND_INTEGER: u32 = 0;
pub const KIND_REAL: u32 = 1;
pub const KIND_BOOLEAN: u32 = 2;
pub const KIND_CHARACTER: u32 = 3;
pub const KIND_REFERENCE: u32 = 4;
pub const NEWLINE_FLAG: u32 = 0x100;
pub const RANK_SHIFT: u32 = 8;
pub const CHARACTER_OPERAND_FLAG: u64 = 1 << 32;

pub(crate) fn kind_from_code(code: u32) -> Result<ValueKind, Trap> {
    match code {
        KIND_INTEGER => Ok(ValueKind::Integer),
        KIND_REAL => Ok(ValueKind::Real),
        KIND_BOOLEAN => Ok(ValueKind::Boolean),
        KIND_CHARACTER => Ok(ValueKind::Character),
        KIND_REFERENCE => Ok(ValueKind::Reference),
        _ => Err(Trap::named("internalFault")),
    }
}

pub(crate) fn kind_code(descriptor: u32) -> u32 {
    descriptor & 0xff
}
