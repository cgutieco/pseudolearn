use crate::collection_types::{
    CollectionCommand, CollectionType, collection_command, collection_type,
};
use crate::type_checker_helpers::TypeError;
use crate::{IrType, Module, Operand, Operation, ValueId};

pub(crate) fn check(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
    module: &Module,
) -> Result<Option<IrType>, TypeError> {
    let Some(command) = collection_command(operation) else {
        return Ok(None);
    };
    if command == CollectionCommand::ArrayLength {
        return array_length(operands, get_type);
    }
    if command == CollectionCommand::New {
        return match operands {
            [Operand::Type(kind @ IrType::Object(name))]
                if module.find_class(name).and_then(collection_type).is_some() =>
            {
                Ok(Some(kind.clone()))
            }
            _ => Err(TypeError),
        };
    }
    let receiver = operands
        .get(usize::from(command == CollectionCommand::Load))
        .ok_or(TypeError)?;
    let IrType::Object(name) = operand_type(receiver, get_type)? else {
        return Err(TypeError);
    };
    let descriptor = module
        .find_class(&name)
        .and_then(collection_type)
        .ok_or(TypeError)?;
    signature(command, operands, &descriptor, (get_type, module)).map(Some)
}

fn signature(
    command: CollectionCommand,
    operands: &[Operand],
    descriptor: &CollectionType,
    context: (&impl Fn(ValueId) -> Option<IrType>, &Module),
) -> Result<IrType, TypeError> {
    let (get_type, module) = context;
    match command {
        CollectionCommand::Length | CollectionCommand::Version if operands.len() == 1 => {
            Ok(IrType::I64)
        }
        CollectionCommand::Check
            if operands.len() == 2
                && operand_type(operands.get(1).ok_or(TypeError)?, get_type)? == IrType::I64 =>
        {
            Ok(IrType::Unit)
        }
        CollectionCommand::Load => load(operands, descriptor, get_type),
        CollectionCommand::Lookup | CollectionCommand::Next | CollectionCommand::Key => {
            dictionary(command, operands, descriptor, get_type)
        }
        CollectionCommand::Remove if operands.len() == 2 => {
            require_key(operands.get(1).ok_or(TypeError)?, descriptor, get_type)?;
            Ok(IrType::Unit)
        }
        CollectionCommand::Store | CollectionCommand::Insert => {
            store(command, operands, descriptor, (get_type, module))
        }
        _ => Err(TypeError),
    }
}

fn load(
    operands: &[Operand],
    descriptor: &CollectionType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<IrType, TypeError> {
    let [Operand::Type(kind), _, position, Operand::LiteralI64(leaf)] = operands else {
        return Err(TypeError);
    };
    let leaf = usize::try_from(*leaf).map_err(|_| TypeError)?;
    if descriptor.leaves.get(leaf) != Some(kind) || operand_type(position, get_type)? != IrType::I64
    {
        return Err(TypeError);
    }
    Ok(kind.clone())
}

fn dictionary(
    command: CollectionCommand,
    operands: &[Operand],
    descriptor: &CollectionType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<IrType, TypeError> {
    let key = descriptor.key.as_ref().ok_or(TypeError)?;
    if operands.len() != 2 {
        return Err(TypeError);
    }
    let expected = if command == CollectionCommand::Lookup {
        key
    } else {
        &IrType::I64
    };
    if operand_type(operands.get(1).ok_or(TypeError)?, get_type)? != *expected {
        return Err(TypeError);
    }
    Ok(if command == CollectionCommand::Key {
        key.clone()
    } else {
        IrType::I64
    })
}

fn store(
    command: CollectionCommand,
    operands: &[Operand],
    descriptor: &CollectionType,
    context: (&impl Fn(ValueId) -> Option<IrType>, &Module),
) -> Result<IrType, TypeError> {
    let (get_type, module) = context;
    if command == CollectionCommand::Insert && descriptor.key.is_some() {
        return Err(TypeError);
    }
    if operands.len() != descriptor.leaves.len().checked_add(2).ok_or(TypeError)? {
        return Err(TypeError);
    }
    require_key(operands.get(1).ok_or(TypeError)?, descriptor, get_type)?;
    for (operand, kind) in operands.iter().skip(2).zip(&descriptor.leaves) {
        if !crate::assignability::assignable(module, &operand_type(operand, get_type)?, kind) {
            return Err(TypeError);
        }
    }
    Ok(IrType::Unit)
}

fn require_key(
    operand: &Operand,
    descriptor: &CollectionType,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    if operand_type(operand, get_type)? != *descriptor.key.as_ref().unwrap_or(&IrType::I64) {
        return Err(TypeError);
    }
    Ok(())
}

fn operand_type(
    operand: &Operand,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<IrType, TypeError> {
    let Operand::Value(value) = operand else {
        return Err(TypeError);
    };
    get_type(*value).ok_or(TypeError)
}

fn array_length(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    match operands {
        [Operand::Value(value)]
            if matches!(
                get_type(*value),
                Some(IrType::Array {
                    dimension_rank: 1,
                    ..
                })
            ) =>
        {
            Ok(Some(IrType::I64))
        }
        _ => Err(TypeError),
    }
}
