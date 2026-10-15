#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::operand::Operand;
use crate::types::IrType;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct TypeError;

pub fn expect_one_typed(
    operands: &[Operand],
    expected: &IrType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    match operands {
        [Operand::Value(value)] => {
            if get_type(*value).as_ref() == Some(expected) {
                Ok(())
            } else {
                Err(TypeError)
            }
        }
        _ => Err(TypeError),
    }
}

pub fn expect_two_typed(
    operands: &[Operand],
    expected: &IrType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    match operands {
        [Operand::Value(left), Operand::Value(right)] => {
            if get_type(*left).as_ref() == Some(expected)
                && get_type(*right).as_ref() == Some(expected)
            {
                Ok(())
            } else {
                Err(TypeError)
            }
        }
        _ => Err(TypeError),
    }
}

pub fn expect_predicate_and_two_typed(
    operands: &[Operand],
    expected: &IrType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    match operands {
        [
            Operand::Predicate(_),
            Operand::Value(left),
            Operand::Value(right),
        ] => {
            if get_type(*left).as_ref() == Some(expected)
                && get_type(*right).as_ref() == Some(expected)
            {
                Ok(())
            } else {
                Err(TypeError)
            }
        }
        _ => Err(TypeError),
    }
}
