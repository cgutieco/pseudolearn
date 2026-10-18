#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Lowering, propagate_if_failed};
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::IrSpan;

pub(crate) struct RuntimeCall<'operands> {
    pub(crate) target: Entry,
    pub(crate) code_name: &'static str,
    pub(crate) span: Option<IrSpan>,
    pub(crate) operands: &'operands [Value],
}

pub(crate) fn call_runtime(
    lowering: &mut Lowering<'_, '_>,
    call: &RuntimeCall<'_>,
) -> Result<Value, CodegenError> {
    let site = lowering.faults.register(call.code_name, call.span)?;
    let site_value = lowering.builder.ins().iconst(types::I32, i64::from(site));
    let mut arguments = vec![lowering.context, site_value];
    arguments.extend_from_slice(call.operands);
    let target = lowering.environment.runtime.get(call.target)?;
    let instruction = lowering.builder.ins().call(target, &arguments);
    let status = lowering
        .builder
        .inst_results(instruction)
        .first()
        .copied()
        .ok_or(CodegenError::InvalidModule(
            "runtime entry returns no status",
        ))?;
    propagate_if_failed(lowering, status);
    let offset = lowering.environment.layout.result_word;
    Ok(lowering.builder.ins().load(
        types::I64,
        MemFlagsData::trusted(),
        lowering.context,
        offset,
    ))
}
