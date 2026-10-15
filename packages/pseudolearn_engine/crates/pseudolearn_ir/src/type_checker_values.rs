#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::TypeError;
use crate::types::IrType;

pub fn check_value_operations(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::ValueUndefined => match operands {
            [Operand::Type(value_type)] => Ok(Some(value_type.clone())),
            _ => Err(TypeError),
        },
        Operation::ValueRequire => match operands {
            [Operand::Value(value)] => get_type(*value).map(Some).ok_or(TypeError),
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}
