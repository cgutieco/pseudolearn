#![forbid(unsafe_code)]

use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};

pub fn emit_effect_call(
    (capability, operation_name): (ValueId, &str),
    arguments: Vec<ValueId>,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let result = state.builder.next_value();
    let mut operands = vec![
        Operand::Value(capability),
        Operand::Identifier(operation_name.to_owned()),
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
