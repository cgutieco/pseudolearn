#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::Lowering;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::IrType;

pub(crate) fn to_word(
    lowering: &mut Lowering<'_, '_>,
    value: Value,
    value_type: &IrType,
) -> Result<Value, CodegenError> {
    Ok(match value_type {
        IrType::I64 => value,
        IrType::F64 => lowering
            .builder
            .ins()
            .bitcast(types::I64, MemFlagsData::new(), value),
        IrType::Unit => return Err(CodegenError::InvalidModule("unit value has no word")),
        _ => lowering.builder.ins().uextend(types::I64, value),
    })
}

pub(crate) fn from_word(
    lowering: &mut Lowering<'_, '_>,
    word: Value,
    value_type: &IrType,
) -> Result<Value, CodegenError> {
    Ok(match value_type {
        IrType::I64 => word,
        IrType::F64 => lowering
            .builder
            .ins()
            .bitcast(types::F64, MemFlagsData::new(), word),
        IrType::Bool => lowering.builder.ins().ireduce(types::I8, word),
        IrType::Unit => return Err(CodegenError::InvalidModule("unit value has no word")),
        _ => lowering.builder.ins().ireduce(types::I32, word),
    })
}
