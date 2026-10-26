#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lower_text::value_type_of;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::word_conversion::to_word;
use cranelift_codegen::ir::{InstBuilder, types};
use pseudolearn_ir::{Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[Operation::EffectCall];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let capability = match instruction.operands.first() {
        Some(Operand::Value(identifier)) => {
            let value_type = value_type_of(lowering, *identifier)?;
            let value = operand_value(lowering, instruction, 0)?;
            to_word(lowering, value, &value_type)?
        }
        _ => lowering.builder.ins().iconst(types::I64, 0),
    };
    let operation = lowering.builder.ins().iconst(types::I32, 0);
    let call = RuntimeCall {
        target: Entry::EffectCall,
        code_name: "internalFault",
        span: instruction.span,
        operands: &[capability, operation],
    };
    let result = call_runtime(lowering, &call)?;
    bind_result(lowering, instruction, result);
    Ok(())
}
