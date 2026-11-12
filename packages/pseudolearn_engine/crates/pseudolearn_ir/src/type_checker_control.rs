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
        Operation::OutWrite => check_output(operands, get_type),
        Operation::InRead => match operands {
            [Operand::Type(target_type)] => Ok(Some(target_type.clone())),
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn check_output(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let values = if operands.last() == Some(&Operand::Newline) {
        operands
            .get(..operands.len().saturating_sub(1))
            .ok_or(TypeError)?
    } else {
        operands
    };
    if values.is_empty() {
        return Err(TypeError);
    }
    for operand in values {
        let Operand::Value(value) = operand else {
            return Err(TypeError);
        };
        let kind = get_type(*value).ok_or(TypeError)?;
        if kind.value_class() != ValueClass::Scalar && kind != IrType::Str {
            return Err(TypeError);
        }
    }
    Ok(Some(IrType::Unit))
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
        Operation::DecideDefault | Operation::DecideNone => {
            if operands.is_empty() {
                Ok(Some(()))
            } else {
                Err(TypeError)
            }
        }
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
        Operation::Switch => check_switch(operands, get_type),
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

fn check_switch(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let [
        Operand::Value(selector),
        Operand::BlockTarget { .. },
        cases @ ..,
    ] = operands
    else {
        return Err(TypeError);
    };
    if get_type(*selector) != Some(IrType::I64) || !cases.len().is_multiple_of(2) {
        return Err(TypeError);
    }
    let mut previous = None;
    for pair in cases.as_chunks::<2>().0 {
        let [Operand::LiteralI64(ordinal), Operand::BlockTarget { .. }] = pair else {
            return Err(TypeError);
        };
        if !(0..65_536).contains(ordinal) || previous.is_some_and(|previous| previous >= *ordinal) {
            return Err(TypeError);
        }
        previous = Some(*ordinal);
    }
    Ok(None)
}
