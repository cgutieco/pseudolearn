use crate::type_checker_helpers::TypeError;
use crate::{IrType, Operand, Operation, ValueId};

pub(crate) fn check(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match (operation, operands) {
        (
            Operation::TaskChannel,
            [
                Operand::Identifier(command),
                Operand::Type(result),
                rest @ ..,
            ],
        ) => channel(command, result, rest, get_type),
        (Operation::TaskValueLoad, [Operand::Type(result), Operand::LiteralI64(index)])
            if *index >= 0 && *result != IrType::Unit =>
        {
            Ok(Some(result.clone()))
        }
        (Operation::TaskChannel | Operation::TaskValueLoad, _) => Err(TypeError),
        _ => Ok(None),
    }
}

fn channel(
    command: &str,
    result: &IrType,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let kinds = operands
        .iter()
        .map(|operand| match operand {
            Operand::Value(value) => get_type(*value),
            _ => None,
        })
        .collect::<Option<Vec<_>>>()
        .ok_or(TypeError)?;
    let valid = match command {
        "new" => kinds == [IrType::I64, IrType::I64] && *result == IrType::I64,
        "send" => kinds.first() == Some(&IrType::I64) && *result == IrType::Bool,
        "receive" | "close" => kinds == [IrType::I64] && *result == IrType::I64,
        "select" => {
            kinds.len() >= 2
                && kinds.iter().all(|kind| *kind == IrType::I64)
                && *result == IrType::I64
        }
        "selected_present" => kinds.is_empty() && *result == IrType::I64,
        _ => false,
    };
    if valid {
        Ok(Some(result.clone()))
    } else {
        Err(TypeError)
    }
}
