#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result};
use cranelift_codegen::ir::{InstBuilder, types};
use pseudolearn_aot_rt::{
    CHANNEL_CLOSE, CHANNEL_NEW, CHANNEL_RECEIVE, CHANNEL_SELECT, CHANNEL_SELECTED_PRESENT,
    CHANNEL_SEND,
};
use pseudolearn_ir::{IrType, Operand, ValueId};

fn command_code(command: &str) -> Result<u32, CodegenError> {
    Ok(match command {
        "new" => CHANNEL_NEW,
        "send" => CHANNEL_SEND,
        "receive" => CHANNEL_RECEIVE,
        "close" => CHANNEL_CLOSE,
        "select" => CHANNEL_SELECT,
        "selected_present" => CHANNEL_SELECTED_PRESENT,
        _ => return Err(CodegenError::InvalidModule("unknown channel command")),
    })
}

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let [
        Operand::Identifier(command),
        Operand::Type(result),
        rest @ ..,
    ] = instruction.operands
    else {
        return Err(CodegenError::InvalidModule("channel operation shape"));
    };
    let code = command_code(command)?;
    let values: Vec<ValueId> = rest
        .iter()
        .filter_map(|operand| match operand {
            Operand::Value(value) => Some(*value),
            _ => None,
        })
        .collect();
    let buffer = crate::lower_tasks::packet(lowering, &values, &[])?;
    let command = lowering.builder.ins().iconst(types::I32, i64::from(code));
    let word = crate::lower_tasks::rooted(
        lowering,
        instruction,
        Entry::TaskChannel,
        &[command, buffer],
    )?;
    if *result != IrType::Unit {
        let value = crate::word_conversion::from_word(lowering, word, result)?;
        bind_result(lowering, instruction, value);
    }
    Ok(())
}
