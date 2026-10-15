#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::{TypeError, expect_one_typed};
use crate::types::{IrType, ValueClass};

pub fn check_control_and_io(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    if let Some(result) = check_io(operation, operands, get_type)? {
        return Ok(Some(result));
    }
    check_control(operation, operands, get_type)
}

fn check_io(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::OutWrite => match operands {
            [Operand::Value(value)] | [Operand::Value(value), Operand::Newline] => {
                let value_type = get_type(*value).ok_or(TypeError)?;
                if value_type.value_class() == ValueClass::Scalar || value_type == IrType::Str {
                    Ok(Some(IrType::Unit))
                } else {
                    Err(TypeError)
                }
            }
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn check_control(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    if check_statements(operation, operands, get_type)?.is_some() {
        return Ok(None);
    }
    check_branching(operation, operands, get_type)
}

fn check_statements(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<()>, TypeError> {
    match operation {
        Operation::StmtEnter | Operation::StmtExit => {
            if operands.is_empty() {
                Ok(Some(()))
            } else {
                Err(TypeError)
            }
        }
        Operation::DecideBool => {
            expect_one_typed(operands, &IrType::Bool, get_type)?;
            Ok(Some(()))
        }
        Operation::DecideCase => match operands {
            [Operand::Value(value)] => {
                let value_type = get_type(*value).ok_or(TypeError)?;
                if value_type.value_class() == ValueClass::Scalar {
                    Ok(Some(()))
                } else {
                    Err(TypeError)
                }
            }
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn check_branching(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::Jump => match operands {
            [Operand::BlockTarget { .. }] => Ok(None),
            _ => Err(TypeError),
        },
        Operation::Branch => check_branch_operands(operands, get_type),
        Operation::Return => match operands {
            [] | [Operand::Value(_)] => Ok(None),
            _ => Err(TypeError),
        },
        Operation::TrapMissingReturn | Operation::Unreachable => {
            if operands.is_empty() {
                Ok(None)
            } else {
                Err(TypeError)
            }
        }
        _ => Ok(None),
    }
}

fn check_branch_operands(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [
            Operand::Value(condition),
            Operand::BlockTarget { .. },
            Operand::BlockTarget { .. },
        ] => {
            if get_type(*condition) == Some(IrType::Bool) {
                Ok(None)
            } else {
                Err(TypeError)
            }
        }
        _ => Err(TypeError),
    }
}
