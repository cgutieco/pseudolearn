use crate::error::CodegenError;
use crate::lower_calls::{
    call_arguments, call_target, callee_reference, function_index, require_arguments_defined,
    require_frame_available,
};
use crate::lowering::{
    Instruction, Lowering, bind_result, guard_trap, operand_value, propagate_if_failed,
};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = call_target(instruction)?;
    let prototype = function_index(lowering, target.function_name)?;
    let callee = callee_reference(lowering, prototype)?;
    let signature = lowering
        .builder
        .func
        .dfg
        .ext_funcs
        .get(callee)
        .ok_or(CodegenError::InvalidModule("missing function signature"))?
        .signature;
    let code = operand_value(lowering, instruction, 0)?;
    let pointer = pointer(lowering, instruction, (code, prototype))?;
    require_frame_available(lowering, instruction)?;
    require_arguments_defined(lowering, instruction, target.arguments)?;
    let arguments = call_arguments(lowering, target.arguments);
    let frame = crate::shadow_stack::push_roots(lowering, instruction)?;
    let call = lowering
        .builder
        .ins()
        .call_indirect(signature, pointer, &arguments);
    let result = lowering.builder.inst_results(call).first().copied();
    let status = lowering.builder.ins().load(
        types::I32,
        MemFlagsData::trusted(),
        lowering.context,
        lowering.environment.layout.fault_status,
    );
    propagate_if_failed(lowering, status);
    crate::shadow_stack::pop_roots(lowering, frame);
    if let Some(value) = result {
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

fn pointer(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (code, prototype): (Value, usize),
) -> Result<Value, CodegenError> {
    let row = row(lowering, instruction, code)?;
    check_signature(lowering, instruction, (row, prototype))?;
    let pointer_type = lowering.environment.frontend.pointer_type();
    Ok(lowering
        .builder
        .ins()
        .load(pointer_type, MemFlagsData::trusted(), row, 0))
}

fn row(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    code: Value,
) -> Result<Value, CodegenError> {
    let count = i64::try_from(lowering.environment.module.functions.len())
        .map_err(|_| CodegenError::InvalidModule("function table length"))?;
    let invalid = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::UnsignedGreaterThanOrEqual, code, count);
    guard_trap(
        lowering,
        invalid,
        "invalidFunctionReference",
        instruction.span,
    )?;
    let pointer_type = lowering.environment.frontend.pointer_type();
    let table = lowering
        .environment
        .function_table
        .ok_or(CodegenError::InvalidModule("missing function table"))?;
    let base = lowering.builder.ins().symbol_value(pointer_type, table);
    let index = if pointer_type == types::I32 {
        lowering.builder.ins().ireduce(pointer_type, code)
    } else {
        code
    };
    let stride = crate::function_table::stride(pointer_type)?;
    let offset = lowering.builder.ins().imul_imm_s(index, stride);
    let row = lowering.builder.ins().iadd(base, offset);
    Ok(row)
}

fn check_signature(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (row, prototype): (Value, usize),
) -> Result<(), CodegenError> {
    let tag_offset =
        crate::function_table::tag_offset(lowering.environment.frontend.pointer_type())?;
    let actual = lowering
        .builder
        .ins()
        .load(types::I32, MemFlagsData::trusted(), row, tag_offset);
    let expected = lowering
        .environment
        .signature_tags
        .get(prototype)
        .copied()
        .ok_or(CodegenError::InvalidModule("missing signature tag"))?;
    let mismatch = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::NotEqual, actual, i64::from(expected));
    guard_trap(
        lowering,
        mismatch,
        "invalidFunctionReference",
        instruction.span,
    )?;
    Ok(())
}
