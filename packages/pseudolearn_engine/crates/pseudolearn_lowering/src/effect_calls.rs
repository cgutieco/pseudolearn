#![forbid(unsafe_code)]

use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};

pub fn emit_effect_call(
    (capability, operation_name, result_type, source_node): (ValueId, &str, pseudolearn_ir::IrType, u32),
    arguments: Vec<ValueId>,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    let mut operands = vec![
        Operand::Value(capability),
        Operand::Identifier(operation_name.to_owned()),
        Operand::Type(result_type),
        Operand::Identifier(format!("n{source_node}")),
    ];
    for argument in arguments {
        operands.push(Operand::Value(argument));
    }
    state.builder.emit_with_target(
        Operation::EffectCall,
        operands,
        (Some(result), span),
    );
    result
}
