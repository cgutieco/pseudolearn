use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::collection_types::{
    CollectionCommand, CollectionType, collection_command, collection_type,
};
use pseudolearn_ir::{IrType, Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::CollectionNew,
    Operation::CollectionLength,
    Operation::CollectionVersion,
    Operation::CollectionCheck,
    Operation::CollectionLookup,
    Operation::CollectionLoad,
    Operation::CollectionStore,
    Operation::CollectionInsert,
    Operation::CollectionRemove,
    Operation::CollectionNext,
    Operation::CollectionKey,
    Operation::ArrayLength,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let command = collection_command(instruction.operation)
        .ok_or(CodegenError::InvalidModule("unknown collection command"))?;
    let descriptor = descriptor(lowering, instruction, command)?;
    let (mut packet, result_type) = header(lowering, instruction, command, descriptor)?;
    let arguments = arguments(lowering, instruction, command)?;
    let count = lowering.builder.ins().iconst(
        types::I64,
        i64::try_from(arguments.len())
            .map_err(|_| CodegenError::InvalidModule("too many collection arguments"))?,
    );
    packet.insert(0, count);
    packet.extend(arguments);
    let roots = push_roots(lowering, instruction)?;
    let buffer = crate::inline_memory::spill_words(lowering, &packet)?;
    let command = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(command.code()));
    let operands = [command, buffer];
    let call = RuntimeCall {
        target: Entry::Collection,
        code_name: "collectionLimitExceeded",
        span: instruction.span,
        operands: &operands,
    };
    let word = call_runtime(lowering, &call)?;
    pop_roots(lowering, roots);
    if let Some(kind) = result_type {
        let value = crate::word_conversion::from_word(lowering, word, &kind)?;
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

fn descriptor(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    command: CollectionCommand,
) -> Result<Option<(usize, CollectionType)>, CodegenError> {
    if command == CollectionCommand::ArrayLength {
        return Ok(None);
    }
    let name = receiver_name(lowering, instruction, command)?;
    let (index, class) = lowering
        .environment
        .module
        .classes
        .iter()
        .enumerate()
        .find(|(_, class)| class.name == name)
        .ok_or(CodegenError::InvalidModule(
            "collection declaration missing",
        ))?;
    Ok(Some((
        index,
        collection_type(class).ok_or(CodegenError::InvalidModule(
            "invalid collection declaration",
        ))?,
    )))
}

fn header(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    command: CollectionCommand,
    descriptor: Option<(usize, CollectionType)>,
) -> Result<(Vec<Value>, Option<IrType>), CodegenError> {
    let mut words = layout_words(descriptor)?;
    if command == CollectionCommand::Load {
        let Some(Operand::LiteralI64(leaf)) = instruction.operands.get(3) else {
            return Err(CodegenError::InvalidModule("collection leaf missing"));
        };
        if let Some(word) = words.last_mut() {
            *word = *leaf;
        }
    }
    let result = instruction
        .result
        .and_then(|value| lowering.types.get(&value))
        .cloned()
        .filter(|kind| *kind != IrType::Unit);
    Ok((
        words
            .into_iter()
            .map(|word| lowering.builder.ins().iconst(types::I64, word))
            .collect(),
        result,
    ))
}

fn key_code(kind: Option<&IrType>) -> i64 {
    use pseudolearn_aot_rt::DictionaryKeyKind;
    let key = match kind {
        Some(IrType::I64) => DictionaryKeyKind::Integer,
        Some(IrType::Char) => DictionaryKeyKind::Character,
        Some(IrType::Bool) => DictionaryKeyKind::Boolean,
        Some(IrType::Str) => DictionaryKeyKind::String,
        _ => return i64::from(u32::MAX),
    };
    i64::from(key.code())
}

fn arguments(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    command: CollectionCommand,
) -> Result<Vec<Value>, CodegenError> {
    let mut arguments = Vec::new();
    for (position, operand) in instruction.operands.iter().enumerate() {
        if matches!(operand, Operand::Type(_))
            || (command == CollectionCommand::Load && position == 3)
        {
            continue;
        }
        let Operand::Value(identifier) = operand else {
            return Err(CodegenError::InvalidModule(
                "collection operand is not a value",
            ));
        };
        let kind = lowering
            .types
            .get(identifier)
            .cloned()
            .ok_or(CodegenError::InvalidModule("collection operand type"))?;
        let value = operand_value(lowering, instruction, position)?;
        arguments.push(crate::word_conversion::to_word(lowering, value, &kind)?);
    }
    Ok(arguments)
}

fn layout_words(descriptor: Option<(usize, CollectionType)>) -> Result<Vec<i64>, CodegenError> {
    let mut words = vec![0_i64, 0, 0, i64::from(u32::MAX), 0];
    if let Some((index, descriptor)) = descriptor {
        let references = descriptor
            .leaves
            .iter()
            .filter(|kind| kind.value_class() == pseudolearn_ir::ValueClass::Reference)
            .count();
        words = vec![
            i64::try_from(descriptor.leaves.len().saturating_sub(references))
                .map_err(|_| CodegenError::InvalidModule("collection width"))?,
            i64::try_from(references)
                .map_err(|_| CodegenError::InvalidModule("collection width"))?,
            i64::try_from(index).map_err(|_| CodegenError::InvalidModule("collection identity"))?,
            if descriptor.key_is_enum {
                i64::from(pseudolearn_aot_rt::DictionaryKeyKind::Enumeration.code())
            } else {
                key_code(descriptor.key.as_ref())
            },
            0,
        ];
    }
    Ok(words)
}

fn receiver_name(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    command: CollectionCommand,
) -> Result<String, CodegenError> {
    let kind = if command == CollectionCommand::New {
        match instruction.operands.first() {
            Some(Operand::Type(kind)) => Some(kind),
            _ => None,
        }
    } else {
        match instruction
            .operands
            .get(usize::from(command == CollectionCommand::Load))
        {
            Some(Operand::Value(value)) => lowering.types.get(value),
            _ => None,
        }
    };
    let Some(IrType::Object(name)) = kind else {
        return Err(CodegenError::InvalidModule("collection type missing"));
    };
    Ok(name.clone())
}
