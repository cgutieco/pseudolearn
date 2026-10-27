use crate::type_checker_helpers::TypeError;
use crate::{IrType, Operand, Operation, ValueId};
use pseudolearn_abi::{EffectOperation, EffectValueKind};

const FIRST_ARGUMENT: usize = 4;

pub(crate) fn check(
    operation: Operation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    if operation != Operation::EffectCall {
        return Ok(None);
    }
    let descriptor = check_header(operands)?;
    let receiver = value_type(operands.first(), get_type)?;
    if receiver.value_class() != crate::types::ValueClass::Reference {
        return Err(TypeError);
    }
    check_arguments(descriptor, operands, get_type)?;
    check_cells(descriptor, operands, get_type)?;
    Ok(Some(IrType::I64))
}

fn check_header(operands: &[Operand]) -> Result<&'static EffectOperation, TypeError> {
    let Some(Operand::Identifier(name)) = operands.get(1) else {
        return Err(TypeError);
    };
    let descriptor = pseudolearn_abi::effect_operation(name).ok_or(TypeError)?;
    let Some(Operand::Type(result_type)) = operands.get(2) else {
        return Err(TypeError);
    };
    let Some(Operand::Identifier(source)) = operands.get(3) else {
        return Err(TypeError);
    };
    let source_valid = source
        .strip_prefix('n')
        .and_then(|source| source.parse::<u32>().ok())
        .is_some();
    let output = if descriptor.fallible { 3 } else { 1 };
    let expected = descriptor
        .parameters
        .len()
        .saturating_add(output)
        .saturating_add(FIRST_ARGUMENT);
    if matches_kind(descriptor.result, result_type) && source_valid && operands.len() == expected {
        return Ok(descriptor);
    }
    Err(TypeError)
}

fn check_arguments(
    descriptor: &EffectOperation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    for (parameter, operand) in descriptor
        .parameters
        .iter()
        .zip(operands.iter().skip(FIRST_ARGUMENT))
    {
        if !matches_kind(*parameter, &value_type(Some(operand), get_type)?) {
            return Err(TypeError);
        }
    }
    Ok(())
}

fn check_cells(
    descriptor: &EffectOperation,
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<(), TypeError> {
    let start = descriptor.parameters.len().saturating_add(FIRST_ARGUMENT);
    for (index, operand) in operands.iter().skip(start).enumerate() {
        let IrType::Cell(kind) = value_type(Some(operand), get_type)? else {
            return Err(TypeError);
        };
        if !cell_matches(descriptor, index, &kind) {
            return Err(TypeError);
        }
    }
    Ok(())
}

fn cell_matches(descriptor: &EffectOperation, index: usize, kind: &IrType) -> bool {
    if !descriptor.fallible {
        return matches_kind(descriptor.result, kind);
    }
    *kind == if index == 2 { IrType::Str } else { IrType::I64 }
}

fn value_type(
    operand: Option<&Operand>,
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<IrType, TypeError> {
    match operand {
        Some(Operand::Value(value)) => get_type(*value).ok_or(TypeError),
        _ => Err(TypeError),
    }
}

fn matches_kind(kind: EffectValueKind, actual: &IrType) -> bool {
    match kind {
        EffectValueKind::Integer => *actual == IrType::I64,
        EffectValueKind::Boolean => *actual == IrType::Bool,
        EffectValueKind::Text => *actual == IrType::Str,
        EffectValueKind::TextList => {
            matches!(actual, IrType::Object(name) if name.starts_with("$vector"))
        }
        other => matches!(actual, IrType::Object(name) if *name == format!("$effect:{other:?}")),
    }
}
