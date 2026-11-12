#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::inline_memory::spill_words;
use crate::lower_text::value_type_of;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::word_conversion::to_word;
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::{Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[Operation::SnapshotCopy];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::LiteralI64(count)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("snapshot copy count"));
    };
    let count =
        u32::try_from(*count).map_err(|_| CodegenError::InvalidModule("snapshot copy count"))?;
    let expected = usize::try_from(count)
        .ok()
        .and_then(|count| count.checked_mul(2))
        .and_then(|words| words.checked_add(1));
    if expected != Some(instruction.operands.len()) {
        return Err(CodegenError::InvalidModule("snapshot copy arity"));
    }
    let words = (1..instruction.operands.len())
        .map(|position| operand_word(lowering, instruction, position))
        .collect::<Result<Vec<Value>, _>>()?;
    let buffer = spill_words(lowering, &words)?;
    let count_value = lowering.builder.ins().iconst(types::I32, i64::from(count));
    let call = RuntimeCall {
        target: Entry::SnapshotCopy,
        code_name: "internalFault",
        span: instruction.span,
        operands: &[count_value, buffer],
    };
    let result = call_runtime(lowering, &call)?;
    bind_result(lowering, instruction, result);
    Ok(())
}

fn operand_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    position: usize,
) -> Result<Value, CodegenError> {
    let Some(Operand::Value(identifier)) = instruction.operands.get(position) else {
        return Err(CodegenError::InvalidModule(
            "snapshot operand is not a value",
        ));
    };
    let value_type = value_type_of(lowering, *identifier)?;
    let value = operand_value(lowering, instruction, position)?;
    to_word(lowering, value, &value_type)
}
