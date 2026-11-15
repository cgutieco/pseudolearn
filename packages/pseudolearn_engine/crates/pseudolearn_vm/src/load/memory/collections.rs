use super::{MemoryOp, TypedSource, value_kind};
use crate::VmTrap;
use crate::load::instructions::DecodeContext;
use crate::load::invalid_bytecode;
use pseudolearn_bytecode::collection_metadata::{collection_command, collection_fields};
use pseudolearn_bytecode::{BytecodeOperand, Constant, Instruction, ValueType};
use pseudolearn_runtime::{CollectionCommand, DictionaryKeyKind, ValueKind, VectorLayout};

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct CollectionOperation {
    pub command: CollectionCommand,
    pub layout: VectorLayout,
    pub key: Option<DictionaryKeyKind>,
    pub leaf: u32,
    pub sources: Vec<TypedSource>,
    pub destination: Option<pseudolearn_bytecode::Register>,
}

pub(super) fn decode(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<MemoryOp, VmTrap> {
    let command = collection_command(instruction.opcode).ok_or_else(invalid_bytecode)?;
    let (layout, key) = operation_layout(context, instruction, command)?;
    let mut sources = Vec::new();
    let mut leaf = 0;
    for (position, operand) in instruction.operands.iter().enumerate() {
        if matches!(operand, BytecodeOperand::Type(_)) {
            continue;
        }
        if command == CollectionCommand::Load && position == 3 {
            let BytecodeOperand::Constant(index) = operand else {
                return Err(invalid_bytecode());
            };
            let Some(Constant::I64(value)) = context.function.constants.get(usize::from(*index))
            else {
                return Err(invalid_bytecode());
            };
            leaf = u32::try_from(*value).map_err(|_| invalid_bytecode())?;
        } else {
            sources.push(super::typed(context, Some(operand))?);
        }
    }
    Ok(MemoryOp::Collection(CollectionOperation {
        command,
        layout,
        key,
        leaf,
        sources,
        destination: instruction.destination,
    }))
}

fn descriptor(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
    command: CollectionCommand,
) -> Result<(VectorLayout, Option<DictionaryKeyKind>), VmTrap> {
    let name = receiver_name(context, instruction, command)?;
    let (index, class) = context
        .module
        .classes
        .iter()
        .enumerate()
        .find(|(_, class)| class.name == name)
        .ok_or_else(invalid_bytecode)?;
    let descriptor = collection_fields(
        &name,
        class
            .fields
            .iter()
            .map(|(name, kind)| (name.as_str(), kind)),
    )
    .ok_or_else(invalid_bytecode)?;
    let layout = layout(&descriptor, index)?;
    let key = descriptor.key.map(|key| match key {
        ValueType::Char => DictionaryKeyKind::Character,
        ValueType::Bool => DictionaryKeyKind::Boolean,
        ValueType::Str => DictionaryKeyKind::String,
        _ if descriptor.key_is_enum => DictionaryKeyKind::Enumeration,
        _ => DictionaryKeyKind::Integer,
    });
    Ok((layout, key))
}

fn layout(
    descriptor: &pseudolearn_bytecode::collection_metadata::CollectionType,
    index: usize,
) -> Result<VectorLayout, VmTrap> {
    let references = descriptor
        .leaves
        .iter()
        .filter(|kind| value_kind(kind) == ValueKind::Reference)
        .count();
    let scalar_words = u32::try_from(
        descriptor
            .leaves
            .len()
            .checked_sub(references)
            .ok_or_else(invalid_bytecode)?,
    )
    .map_err(|_| invalid_bytecode())?;
    let layout = VectorLayout {
        scalar_words,
        reference_words: u32::try_from(references).map_err(|_| invalid_bytecode())?,
        type_identity: u32::try_from(index).map_err(|_| invalid_bytecode())?,
    };
    Ok(layout)
}

fn operation_layout(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
    command: CollectionCommand,
) -> Result<(VectorLayout, Option<DictionaryKeyKind>), VmTrap> {
    let (layout, key) = if command == CollectionCommand::ArrayLength {
        (
            VectorLayout {
                scalar_words: 0,
                reference_words: 0,
                type_identity: 0,
            },
            None,
        )
    } else {
        descriptor(context, instruction, command)?
    };
    Ok((layout, key))
}

fn receiver_name(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
    command: CollectionCommand,
) -> Result<String, VmTrap> {
    let receiver = if command == CollectionCommand::New {
        instruction.operands.first()
    } else {
        instruction
            .operands
            .get(usize::from(command == CollectionCommand::Load))
    };
    let kind = match receiver {
        Some(BytecodeOperand::Type(kind)) => Some(kind),
        Some(BytecodeOperand::Register(register)) => context.function.register_type(*register),
        _ => None,
    };
    let Some(ValueType::Object(name)) = kind else {
        return Err(invalid_bytecode());
    };
    Ok(name.clone())
}
