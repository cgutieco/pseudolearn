#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::{TypeError, expect_one_typed};
use crate::types::IrType;

pub fn check_intrinsics(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let (input, output) = match operation {
        Operation::MathSqrt
        | Operation::MathAbs
        | Operation::MathLn
        | Operation::MathExp
        | Operation::MathSin
        | Operation::MathCos
        | Operation::MathAtan => (IrType::F64, IrType::F64),
        Operation::CharCode => (IrType::Char, IrType::I64),
        Operation::CharFromCode => (IrType::I64, IrType::Char),
        _ => return Ok(None),
    };
    expect_one_typed(operands, &input, get_type)?;
    Ok(Some(output))
}
