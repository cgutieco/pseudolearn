use crate::error::{BytecodeError, VerificationRule};
use crate::{BytecodeFunction, BytecodeModule, BytecodeOperand, Constant, Instruction};
use pseudolearn_ir::{
    ClassDeclaration, FieldDeclaration, IrType, Module, Operand, Operation, ValueId,
};
const ERROR: BytecodeError = BytecodeError::Verification(VerificationRule::ValueClass);

pub(crate) fn verify(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    instruction: &Instruction,
) -> Result<bool, BytecodeError> {
    let operation = Operation::from_name(instruction.opcode.as_name()).ok_or(ERROR)?;
    if pseudolearn_ir::collection_types::collection_command(operation).is_none() {
        return Ok(false);
    }
    let model = module_model(module);
    let mut kinds = Vec::new();
    let mut operands = Vec::new();
    for (position, operand) in instruction.operands.iter().enumerate() {
        let index = ValueId(u32::try_from(kinds.len()).map_err(|_| ERROR)?);
        let literal = operation == Operation::CollectionLoad && position == 3;
        operands.push(convert(function, operand, (index, literal), &mut kinds).ok_or(ERROR)?);
    }
    let result = pseudolearn_ir::type_checker::check_instruction_types(
        operation,
        &operands,
        |value| {
            usize::try_from(value.0)
                .ok()
                .and_then(|index| kinds.get(index).cloned())
        },
        &model,
    )
    .map_err(|_| ERROR)?;
    let actual = instruction
        .destination
        .and_then(|register| function.register_type(register))
        .cloned();
    let expected = result.filter(|kind| *kind != IrType::Unit);
    if actual != expected {
        return Err(ERROR);
    }
    Ok(true)
}

fn convert(
    function: &BytecodeFunction,
    operand: &BytecodeOperand,
    target: (ValueId, bool),
    kinds: &mut Vec<IrType>,
) -> Option<Operand> {
    let (index, literal) = target;
    match operand {
        BytecodeOperand::Type(kind) => Some(Operand::Type(kind.clone())),
        BytecodeOperand::Register(register) => {
            kinds.push(function.register_type(*register)?.clone());
            Some(Operand::Value(index))
        }
        BytecodeOperand::Constant(constant) => {
            let value = function.constants.get(usize::from(*constant))?;
            if literal {
                return match value {
                    Constant::I64(value) => Some(Operand::LiteralI64(*value)),
                    _ => None,
                };
            }
            kinds.push(match value {
                Constant::I64(_) => IrType::I64,
                Constant::F64(_) => IrType::F64,
                Constant::Bool(_) => IrType::Bool,
                Constant::Char(_) => IrType::Char,
                Constant::Str(_) => IrType::Str,
            });
            Some(Operand::Value(index))
        }
        _ => None,
    }
}

fn module_model(module: &BytecodeModule) -> Module {
    let classes = module
        .classes
        .iter()
        .map(|class| ClassDeclaration {
            name: class.name.clone(),
            superclass: class.superclass.clone(),
            methods: Vec::new(),
            dense_integers: class.dense_integers,
            fields: class
                .fields
                .iter()
                .map(|(name, field_type)| FieldDeclaration {
                    name: name.clone(),
                    field_type: field_type.clone(),
                })
                .collect(),
        })
        .collect();
    let mut model = Module::new(String::new(), module.vocabulary.clone());
    model.classes = classes;
    model
}
