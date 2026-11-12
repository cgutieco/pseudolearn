use crate::{
    BytecodeError, BytecodeFunction, BytecodeOperand, Constant, Instruction, ValueType,
    VerificationRule,
};

const INVALID: BytecodeError = BytecodeError::Verification(VerificationRule::ValueClass);

pub(crate) fn verify(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let Some(BytecodeOperand::Constant(index)) = instruction.operands.first() else {
        return Err(INVALID);
    };
    let Some(Constant::I64(count)) = function.constants.get(usize::from(*index)) else {
        return Err(INVALID);
    };
    let count = usize::try_from(*count).map_err(|_| INVALID)?;
    let operands = instruction.operands.get(1..).ok_or(INVALID)?;
    if count == 0
        || count.checked_mul(2) != Some(operands.len())
        || instruction.destination.is_some()
    {
        return Err(INVALID);
    }
    let (sources, destinations) = operands.split_at(count);
    for (source, destination) in sources.iter().zip(destinations) {
        let (BytecodeOperand::Register(source), BytecodeOperand::Register(destination)) =
            (source, destination)
        else {
            return Err(INVALID);
        };
        let source = function.register_type(*source).ok_or(INVALID)?;
        if source.value_class() != pseudolearn_ir::ValueClass::Reference
            || matches!(source, ValueType::Cell(_))
            || function.register_type(*destination)
                != Some(&ValueType::Cell(Box::new(source.clone())))
        {
            return Err(INVALID);
        }
    }
    Ok(())
}
