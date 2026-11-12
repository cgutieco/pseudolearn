use crate::{
    BytecodeError, BytecodeFunction, BytecodeOperand, Constant, Instruction, Register,
    RegisterClass, VerificationRule,
};
use pseudolearn_ir::{Module, Operand, Operation, ValueId};

const TYPE_ERROR: BytecodeError = BytecodeError::Verification(VerificationRule::ValueClass);

pub(crate) fn verify(
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<bool, BytecodeError> {
    if !instruction.opcode.as_name().starts_with("task.") {
        return Ok(false);
    }
    let operation = Operation::from_name(instruction.opcode.as_name()).ok_or(TYPE_ERROR)?;
    let operands = instruction
        .operands
        .iter()
        .map(|operand| convert(function, operand))
        .collect::<Result<Vec<_>, _>>()?;
    let expected = pseudolearn_ir::type_checker::check_instruction_types(
        operation,
        &operands,
        |value| {
            let class = if value.0 & 65_536 == 0 {
                RegisterClass::Scalar
            } else {
                RegisterClass::Reference
            };
            let index = u16::try_from(value.0 & 65_535).ok()?;
            function.register_type(Register { class, index }).cloned()
        },
        &Module::new(String::new(), String::new()),
    )
    .map_err(|_| TYPE_ERROR)?;
    let actual = instruction
        .destination
        .and_then(|register| function.register_type(register));
    let valid = match expected {
        Some(crate::ValueType::Unit) | None => instruction.destination.is_none(),
        Some(expected) => actual == Some(&expected),
    };
    if valid { Ok(true) } else { Err(TYPE_ERROR) }
}

fn convert(
    function: &BytecodeFunction,
    operand: &BytecodeOperand,
) -> Result<Operand, BytecodeError> {
    match operand {
        BytecodeOperand::Register(register) => Ok(Operand::Value(identity(*register))),
        BytecodeOperand::Type(kind) => Ok(Operand::Type(kind.clone())),
        BytecodeOperand::Identifier(name) => Ok(Operand::Identifier(name.clone())),
        BytecodeOperand::Constant(index) => match function.constants.get(usize::from(*index)) {
            Some(Constant::I64(value)) => Ok(Operand::LiteralI64(*value)),
            _ => Err(TYPE_ERROR),
        },
        BytecodeOperand::BlockTarget { target, arguments } => Ok(Operand::BlockTarget {
            target_block: *target,
            arguments: arguments.iter().copied().map(identity).collect(),
        }),
        BytecodeOperand::FunctionTarget { arguments, .. } => Ok(Operand::FunctionTarget {
            function_name: String::new(),
            arguments: arguments.iter().copied().map(identity).collect(),
        }),
        _ => Err(TYPE_ERROR),
    }
}

fn identity(register: Register) -> ValueId {
    ValueId(
        u32::from(register.index)
            | if register.class == RegisterClass::Reference {
                65_536
            } else {
                0
            },
    )
}
