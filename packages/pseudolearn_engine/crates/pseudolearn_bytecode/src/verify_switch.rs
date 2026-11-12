use crate::error::{BytecodeError, VerificationRule};
use crate::{BytecodeFunction, BytecodeOperand, Constant, Instruction, ValueType};

pub(crate) fn check(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let error = BytecodeError::Verification(VerificationRule::ValueClass);
    let [
        BytecodeOperand::Register(selector),
        BytecodeOperand::BlockTarget { .. },
        cases @ ..,
    ] = instruction.operands.as_slice()
    else {
        return Err(error);
    };
    if function.register_type(*selector) != Some(&ValueType::I64) || !cases.len().is_multiple_of(2)
    {
        return Err(error);
    }
    let mut previous = None;
    for pair in cases.as_chunks::<2>().0 {
        let [
            BytecodeOperand::Constant(index),
            BytecodeOperand::BlockTarget { .. },
        ] = pair
        else {
            return Err(error);
        };
        let Some(Constant::I64(ordinal)) = function.constants.get(usize::from(*index)) else {
            return Err(error);
        };
        if !(0..65_536).contains(ordinal) || previous.is_some_and(|previous| previous >= *ordinal) {
            return Err(error);
        }
        previous = Some(*ordinal);
    }
    Ok(())
}
