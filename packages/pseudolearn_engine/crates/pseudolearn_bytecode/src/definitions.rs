use crate::{BytecodeError, DefinitionState, Register};
use pseudolearn_ir::{Function, Operand, Operation, ValueId};
use std::collections::BTreeMap;

pub(crate) fn operands(
    function: &Function,
    operands: &[Operand],
    registers: &BTreeMap<ValueId, Register>,
) -> Result<BTreeMap<Register, DefinitionState>, BytecodeError> {
    let mut states = BTreeMap::new();
    for operand in operands {
        let values = match operand {
            Operand::Value(value) => std::slice::from_ref(value),
            Operand::FunctionTarget { arguments, .. } | Operand::BlockTarget { arguments, .. } => {
                arguments
            }
            _ => &[],
        };
        for value in values {
            if let Some(register) = registers.get(value) {
                states.insert(*register, state(function, *value)?);
            }
        }
    }
    Ok(states)
}

fn state(function: &Function, value: ValueId) -> Result<DefinitionState, BytecodeError> {
    if function
        .parameters
        .iter()
        .any(|(parameter, _)| *parameter == value)
        || function
            .blocks
            .iter()
            .flat_map(|block| &block.parameters)
            .any(|(parameter, _)| *parameter == value)
    {
        return Ok(DefinitionState::Dynamic);
    }
    for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
        if function.columns.result(*instruction) == Some(value) {
            return Ok(
                if function.columns.operation(*instruction) == Some(Operation::ValueUndefined) {
                    DefinitionState::Undefined
                } else {
                    DefinitionState::Defined
                },
            );
        }
    }
    Err(BytecodeError::MissingValue)
}
