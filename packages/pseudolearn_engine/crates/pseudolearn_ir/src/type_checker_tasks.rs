#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::TypeError;
use crate::types::IrType;

pub(crate) fn check(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::TaskScopeOpen => scope_open(operands),
        Operation::TaskSpawn => spawn(operands, get_type),
        Operation::TaskAwait => await_task(operands, get_type),
        Operation::TaskScopeJoin => scope_join(operands, get_type),
        Operation::TaskYieldCheck => yield_check(operands),
        _ => Ok(None),
    }
}

fn scope_open(operands: &[Operand]) -> Result<Option<IrType>, TypeError> {
    if operands.is_empty() {
        Ok(Some(IrType::I64))
    } else {
        Err(TypeError)
    }
}

fn spawn(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(scope), Operand::FunctionTarget { .. }]
            if get_type(*scope) == Some(IrType::I64) =>
        {
            Ok(Some(IrType::I64))
        }
        _ => Err(TypeError),
    }
}

fn await_task(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(task), Operand::Type(result)]
            if get_type(*task) == Some(IrType::I64) && *result != IrType::Unit =>
        {
            Ok(Some(result.clone()))
        }
        _ => Err(TypeError),
    }
}

fn scope_join(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(scope)] if get_type(*scope) == Some(IrType::I64) => Ok(Some(IrType::Unit)),
        _ => Err(TypeError),
    }
}

fn yield_check(operands: &[Operand]) -> Result<Option<IrType>, TypeError> {
    if operands.is_empty() {
        Ok(None)
    } else {
        Err(TypeError)
    }
}
