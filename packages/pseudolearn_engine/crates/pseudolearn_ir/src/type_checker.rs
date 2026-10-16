#![forbid(unsafe_code)]

use crate::identities::ValueId;
use crate::model::Module;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_calls::check_call_result;
use crate::type_checker_control::check_control_and_io;
use crate::type_checker_helpers::{
    TypeError, expect_one_typed, expect_predicate_and_two_typed, expect_two_typed,
};
use crate::type_checker_intrinsics::check_intrinsics;
use crate::type_checker_values::check_value_operations;
use crate::types::IrType;

pub fn check_instruction_types(
    operation: Operation,
    operands: &[Operand],
    get_type: impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    if let Some(result) = check_value_operations(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_constants(operation, operands)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_integers(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_reals_and_bools(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_intrinsics(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = crate::type_checker_collections::check(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_texts(operation, operands, &get_type)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_memory(operation, operands, &get_type, module)? {
        return Ok(Some(result));
    }
    if let Some(result) = check_call_result(operation, operands, module)? {
        return Ok(Some(result));
    }
    check_control_and_io(operation, operands, &get_type)
}

fn check_constants(
    operation: Operation,
    operands: &[Operand],
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::ConstI64 => match operands {
            [Operand::LiteralI64(_)] => Ok(Some(IrType::I64)),
            _ => Err(TypeError),
        },
        Operation::ConstF64 => match operands {
            [Operand::LiteralF64(_)] => Ok(Some(IrType::F64)),
            _ => Err(TypeError),
        },
        Operation::ConstBool => match operands {
            [Operand::LiteralBool(_)] => Ok(Some(IrType::Bool)),
            _ => Err(TypeError),
        },
        Operation::ConstChar => match operands {
            [Operand::LiteralChar(_)] => Ok(Some(IrType::Char)),
            _ => Err(TypeError),
        },
        Operation::ConstStr => match operands {
            [Operand::LiteralStr(_)] => Ok(Some(IrType::Str)),
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn check_integers(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::IntAdd
        | Operation::IntSub
        | Operation::IntMul
        | Operation::IntDiv
        | Operation::IntMod
        | Operation::IntPow => {
            expect_two_typed(operands, &IrType::I64, get_type)?;
            Ok(Some(IrType::I64))
        }
        Operation::IntNeg => {
            expect_one_typed(operands, &IrType::I64, get_type)?;
            Ok(Some(IrType::I64))
        }
        Operation::IntCmp => {
            expect_predicate_and_two_typed(operands, &IrType::I64, get_type)?;
            Ok(Some(IrType::Bool))
        }
        Operation::IntToReal => {
            expect_one_typed(operands, &IrType::I64, get_type)?;
            Ok(Some(IrType::F64))
        }
        _ => Ok(None),
    }
}

fn check_reals_and_bools(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::RealAdd
        | Operation::RealSub
        | Operation::RealMul
        | Operation::RealDiv
        | Operation::RealPow => {
            expect_two_typed(operands, &IrType::F64, get_type)?;
            Ok(Some(IrType::F64))
        }
        Operation::RealNeg => {
            expect_one_typed(operands, &IrType::F64, get_type)?;
            Ok(Some(IrType::F64))
        }
        Operation::RealCmp => {
            expect_predicate_and_two_typed(operands, &IrType::F64, get_type)?;
            Ok(Some(IrType::Bool))
        }
        Operation::RealTrunc | Operation::RealRound => {
            expect_one_typed(operands, &IrType::F64, get_type)?;
            Ok(Some(IrType::I64))
        }
        Operation::BoolNot => {
            expect_one_typed(operands, &IrType::Bool, get_type)?;
            Ok(Some(IrType::Bool))
        }
        Operation::BoolCmp => {
            expect_predicate_and_two_typed(operands, &IrType::Bool, get_type)?;
            Ok(Some(IrType::Bool))
        }
        _ => Ok(None),
    }
}

fn check_texts(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::TextConcat => {
            for operand in operands {
                let Operand::Value(value) = operand else {
                    return Err(TypeError);
                };
                if !matches!(get_type(*value), Some(IrType::Str | IrType::Char)) {
                    return Err(TypeError);
                }
            }
            if operands.len() != 2 {
                return Err(TypeError);
            }
            Ok(Some(IrType::Str))
        }
        Operation::TextCmp => {
            expect_predicate_and_two_typed(operands, &IrType::Str, get_type)?;
            Ok(Some(IrType::Bool))
        }
        Operation::TextLength => {
            expect_one_typed(operands, &IrType::Str, get_type)?;
            Ok(Some(IrType::I64))
        }
        Operation::CharCmp => {
            expect_predicate_and_two_typed(operands, &IrType::Char, get_type)?;
            Ok(Some(IrType::Bool))
        }
        _ => Ok(None),
    }
}

fn check_memory(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::CellLocal => match operands {
            [Operand::Type(inner_type)] => Ok(Some(IrType::Cell(Box::new(inner_type.clone())))),
            _ => Err(TypeError),
        },
        Operation::CellLoad => match operands {
            [Operand::Value(value)] => match get_type(*value) {
                Some(IrType::Cell(inner)) => Ok(Some(*inner)),
                _ => Err(TypeError),
            },
            _ => Err(TypeError),
        },
        Operation::CellStore => match operands {
            [Operand::Value(target), Operand::Value(source)] => {
                let target_type = get_type(*target).ok_or(TypeError)?;
                let source_type = get_type(*source).ok_or(TypeError)?;
                match target_type {
                    IrType::Cell(inner)
                        if crate::assignability::assignable(module, &source_type, &inner) =>
                    {
                        Ok(Some(IrType::Unit))
                    }
                    _ => Err(TypeError),
                }
            }
            _ => Err(TypeError),
        },
        Operation::CellField => check_cell_field(operands, get_type, module),
        Operation::ObjectNew => match operands {
            [Operand::Identifier(class_name)] if module.find_class(class_name).is_some() => {
                Ok(Some(IrType::Object(class_name.clone())))
            }
            _ => Err(TypeError),
        },
        _ => Ok(None),
    }
}

fn check_cell_field(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [
            Operand::Value(object_value),
            Operand::Identifier(field_name),
        ] => {
            let object_type = get_type(*object_value).ok_or(TypeError)?;
            let class_name = match object_type {
                IrType::Object(name) => name,
                _ => return Err(TypeError),
            };
            inherited_field(module, &class_name, field_name)
        }
        _ => Err(TypeError),
    }
}

fn inherited_field(module: &Module, class: &str, name: &str) -> Result<Option<IrType>, TypeError> {
    let mut current = Some(class);
    for _ in 0..module.classes.len() {
        let class = current
            .and_then(|name| module.find_class(name))
            .ok_or(TypeError)?;
        if let Some(field) = class.fields.iter().find(|field| field.name == name) {
            return Ok(Some(IrType::Cell(Box::new(field.field_type.clone()))));
        }
        current = class.superclass.as_deref();
    }
    Err(TypeError)
}
