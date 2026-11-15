use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use pseudolearn_ir::{Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[Operation::ValueReinterpret];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let [Operand::Type(target), Operand::Value(identifier)] = instruction.operands else {
        return Err(CodegenError::InvalidModule("invalid reinterpretation"));
    };
    let source = lowering
        .types
        .get(identifier)
        .cloned()
        .ok_or(CodegenError::InvalidModule("missing reinterpretation type"))?;
    let value = operand_value(lowering, instruction, 1)?;
    let word = crate::word_conversion::to_word(lowering, value, &source)?;
    let value = crate::word_conversion::from_word(lowering, word, target)?;
    bind_result(lowering, instruction, value);
    Ok(())
}
