#![forbid(unsafe_code)]

use crate::ValueId;
use crate::assignability::assignable;
use crate::model::Module;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker_helpers::TypeError;
use crate::types::IrType;

pub(crate) fn check_memory_instruction(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::CellLocal => check_cell_local(operands),
        Operation::CellLoad | Operation::CellLoadRaw => check_cell_load(operands, get_type),
        Operation::CellStore => check_cell_store(operands, get_type, module),
        Operation::CellField => check_cell_field(operands, get_type, module),
        Operation::ObjectLoad => check_object_load(operands, get_type, module),
        Operation::ObjectStore => check_object_store(operands, get_type, module),
        Operation::ObjectNew => check_object_new(operands, module),
        _ => Ok(None),
    }
}

fn check_cell_local(operands: &[Operand]) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Type(inner_type)] => Ok(Some(IrType::Cell(Box::new(inner_type.clone())))),
        _ => Err(TypeError),
    }
}

fn check_cell_load(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(value)] => match get_type(*value) {
            Some(IrType::Cell(inner)) => Ok(Some(*inner)),
            _ => Err(TypeError),
        },
        _ => Err(TypeError),
    }
}

fn check_cell_store(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let [Operand::Value(target), Operand::Value(source)] = operands else {
        return Err(TypeError);
    };
    let target_type = get_type(*target).ok_or(TypeError)?;
    let source_type = get_type(*source).ok_or(TypeError)?;
    match target_type {
        IrType::Cell(inner) if assignable(module, &source_type, &inner) => Ok(Some(IrType::Unit)),
        _ => Err(TypeError),
    }
}

fn check_cell_field(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let [
        Operand::Value(object_value),
        Operand::Identifier(field_name),
    ] = operands
    else {
        return Err(TypeError);
    };
    let Some(IrType::Object(class_name)) = get_type(*object_value) else {
        return Err(TypeError);
    };
    inherited_field_type(module, &class_name, field_name)
        .map(|field_type| field_type.map(|field_type| IrType::Cell(Box::new(field_type))))
}

fn check_object_load(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let [
        Operand::Value(object_value),
        Operand::Identifier(field_name),
    ] = operands
    else {
        return Err(TypeError);
    };
    let Some(IrType::Object(class_name)) = get_type(*object_value) else {
        return Err(TypeError);
    };
    inherited_field_type(module, &class_name, field_name)
}

fn check_object_store(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let [
        Operand::Value(object_value),
        Operand::Identifier(field_name),
        Operand::Value(source),
    ] = operands
    else {
        return Err(TypeError);
    };
    let Some(IrType::Object(class_name)) = get_type(*object_value) else {
        return Err(TypeError);
    };
    let field_type = inherited_field_type(module, &class_name, field_name)?.ok_or(TypeError)?;
    let source_type = get_type(*source).ok_or(TypeError)?;
    if assignable(module, &source_type, &field_type) {
        Ok(Some(IrType::Unit))
    } else {
        Err(TypeError)
    }
}

fn check_object_new(operands: &[Operand], module: &Module) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Identifier(class_name)] if module.find_class(class_name).is_some() => {
            Ok(Some(IrType::Object(class_name.clone())))
        }
        _ => Err(TypeError),
    }
}

fn inherited_field_type(
    module: &Module,
    class_name: &str,
    field_name: &str,
) -> Result<Option<IrType>, TypeError> {
    let mut current = Some(class_name);
    for _ in 0..module.classes.len() {
        let declaration = current
            .and_then(|name| module.find_class(name))
            .ok_or(TypeError)?;
        if let Some(field) = declaration
            .fields
            .iter()
            .find(|field| field.name == field_name)
        {
            return Ok(Some(field.field_type.clone()));
        }
        current = declaration.superclass.as_deref();
    }
    Err(TypeError)
}
