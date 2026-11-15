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
        Operation::ValueReinterpret => reinterpret(operands, get_type),
        Operation::ValueRequire => match operands {
            [Operand::Value(value)] => get_type(*value).map(Some).ok_or(TypeError),
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn reinterpret(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let [Operand::Type(target), Operand::Value(value)] = operands else {
        return Err(TypeError);
    };
    let source = get_type(*value).ok_or(TypeError)?;
    let same_bank = source.value_class() == target.value_class() && *target != IrType::Unit;
    let carrier = source == IrType::I64
        || *target == IrType::I64
        || source == IrType::Str
        || *target == IrType::Str;
    let cell = matches!(source, IrType::Cell(_)) || matches!(target, IrType::Cell(_));
    if same_bank && carrier && !cell {
        Ok(Some(target.clone()))
    } else {
        Err(TypeError)
    }
}
