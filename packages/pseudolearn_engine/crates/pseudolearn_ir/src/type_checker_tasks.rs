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
    if let Some(result) = crate::type_checker_channels::check(operation, operands, get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = task_result_instruction(operation, operands, get_type)? {
        return Ok(Some(result));
    }
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
        [Operand::Value(task), Operand::Type(result)] if get_type(*task) == Some(IrType::I64) => {
            Ok(Some(if *result == IrType::Unit {
                IrType::I64
            } else {
                result.clone()
            }))
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

fn task_result_instruction(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match (operation, operands) {
        (Operation::TaskOutcome, [Operand::Identifier(status), values @ ..]) if matches!(status.as_str(), "success" | "error") && values.iter().all(|operand| matches!(operand, Operand::Value(value) if get_type(*value).is_some_and(|kind| kind != IrType::Unit))) => Ok(Some(IrType::Unit)),
        (Operation::TaskScopeResult, [Operand::Value(scope), Operand::Type(IrType::Object(_))]) if get_type(*scope) == Some(IrType::I64) => Ok(Some(IrType::I64)),
        (Operation::TaskCancelPoint, [Operand::BlockTarget { arguments, .. }]) if arguments.is_empty() => Ok(Some(IrType::Unit)),
        (Operation::TaskScopeBoundary, [Operand::Value(scope), Operand::BlockTarget { arguments, .. }]) if arguments.is_empty() && get_type(*scope) == Some(IrType::I64) => Ok(Some(IrType::Unit)),
        (Operation::TaskOutcome | Operation::TaskScopeResult | Operation::TaskCancelPoint | Operation::TaskScopeBoundary, _) => Err(TypeError),
        _ => Ok(None),
    }
}
