#![forbid(unsafe_code)]

use crate::model::Module;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::TypeError;
use crate::types::IrType;

pub fn check_call_result(
    operation: Operation,
    operands: &[Operand],
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    if !matches!(operation, Operation::Call | Operation::CallVirtual) {
        return Ok(None);
    }
    let Some(Operand::FunctionTarget { function_name, .. }) = operands.last() else {
        return Err(TypeError);
    };
    Ok(module
        .find_function(function_name)
        .map(|function| function.return_type.clone()))
}
