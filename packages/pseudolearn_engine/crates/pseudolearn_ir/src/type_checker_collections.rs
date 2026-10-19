use crate::type_checker_helpers::TypeError;
use crate::{IrType, Module, Operand, Operation, ValueId};

pub(crate) fn check(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    match operation {
        Operation::ArrayNew => new_array(operands, get_type),
        Operation::ArrayLoad | Operation::CellElement => array_read(operation, operands, get_type),
        Operation::ArrayStore => array_store(operands, get_type, module),
        Operation::TextCharAt => text_position(operands, get_type),
        Operation::TextToInteger => convert_text(operands, get_type, IrType::I64),
        Operation::TextToReal => convert_text(operands, get_type, IrType::F64),
        Operation::HostRandom if operands.is_empty() => Ok(Some(IrType::F64)),
        Operation::HostRandom => Err(TypeError),
        Operation::TextFormat => format_text(operands, get_type),
        Operation::ObjectCopy => match operands {
            [Operand::Value(value)] => match get_type(*value) {
                Some(kind @ IrType::Object(_)) => Ok(Some(kind)),
                _ => Err(TypeError),
            },
            _ => Err(TypeError),
        },
        Operation::RefCmp => compare_references(operands, get_type),
        _ => Ok(None),
    }
}

fn new_array(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let Some(Operand::Type(element)) = operands.first() else {
        return Err(TypeError);
    };
    let dimensions = operands.get(1..).ok_or(TypeError)?;
    validate_indices(dimensions, get_type)?;
    if dimensions.is_empty() {
        return Err(TypeError);
    }
    let element = match element {
        IrType::Array { element, .. } => element.as_ref().clone(),
        _ => element.clone(),
    };
    Ok(Some(IrType::Array {
        element: Box::new(element),
        dimension_rank: u32::try_from(dimensions.len()).map_err(|_| TypeError)?,
    }))
}

fn array_read(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let Some(Operand::Value(array)) = operands.first() else {
        return Err(TypeError);
    };
    let Some(IrType::Array {
        element,
        dimension_rank,
    }) = get_type(*array)
    else {
        return Err(TypeError);
    };
    let indices = operands.get(1..).ok_or(TypeError)?;
    if usize::try_from(dimension_rank).map_err(|_| TypeError)? != indices.len() {
        return Err(TypeError);
    }
    validate_indices(indices, get_type)?;
    Ok(Some(if operation == Operation::CellElement {
        IrType::Cell(element)
    } else {
        *element
    }))
}

fn array_store(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let Some(Operand::Value(value)) = operands.last() else {
        return Err(TypeError);
    };
    let sources = operands
        .get(..operands.len().saturating_sub(1))
        .ok_or(TypeError)?;
    let element = array_read(Operation::ArrayLoad, sources, get_type)?.ok_or(TypeError)?;
    let value_type = get_type(*value).ok_or(TypeError)?;
    if !crate::assignability::assignable(module, &value_type, &element) {
        return Err(TypeError);
    }
    Ok(Some(IrType::Unit))
}

fn validate_indices(
    indices: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    for operand in indices {
        let Operand::Value(value) = operand else {
            return Err(TypeError);
        };
        if get_type(*value) != Some(IrType::I64) {
            return Err(TypeError);
        }
    }
    Ok(())
}

fn convert_text(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    result: IrType,
) -> Result<Option<IrType>, TypeError> {
    crate::type_checker_helpers::expect_one_typed(operands, &IrType::Str, get_type)?;
    Ok(Some(result))
}

fn text_position(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(text), Operand::Value(position)]
            if get_type(*text) == Some(IrType::Str) && get_type(*position) == Some(IrType::I64) =>
        {
            Ok(Some(IrType::Char))
        }
        _ => Err(TypeError),
    }
}

fn format_text(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(value)]
            if get_type(*value).is_some_and(|kind| {
                kind.value_class() == crate::ValueClass::Scalar || kind == IrType::Str
            }) =>
        {
            Ok(Some(IrType::Str))
        }
        _ => Err(TypeError),
    }
}

fn compare_references(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ] if matches!(predicate.as_str(), "eq" | "ne")
            && get_type(*left)
                .is_some_and(|kind| kind.value_class() == crate::ValueClass::Reference)
            && get_type(*right)
                .is_some_and(|kind| kind.value_class() == crate::ValueClass::Reference) =>
        {
            Ok(Some(IrType::Bool))
        }
        _ => Err(TypeError),
    }
}
