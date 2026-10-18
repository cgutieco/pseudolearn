#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, guard_trap, propagate_if_failed};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{FuncRef, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::{Operand, ValueId};

pub(crate) fn lower_call(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::FunctionTarget {
        function_name,
        arguments,
    }) = instruction.operands.first()
    else {
        return Err(CodegenError::InvalidModule("call without function target"));
    };
    let callee = callee_reference(lowering, function_name)?;
    require_frame_available(lowering, instruction)?;
    let call_arguments = call_arguments(lowering, arguments);
    let call = lowering.builder.ins().call(callee, &call_arguments);
    let offset = lowering.environment.layout.fault_status;
    let status = lowering.builder.ins().load(
        types::I32,
        MemFlagsData::trusted(),
        lowering.context,
        offset,
    );
    propagate_if_failed(lowering, status);
    let produced = lowering.builder.inst_results(call).first().copied();
    if let Some(value) = produced {
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

fn callee_reference(
    lowering: &Lowering<'_, '_>,
    function_name: &str,
) -> Result<FuncRef, CodegenError> {
    let clean = function_name.trim_start_matches('@');
    lowering
        .environment
        .module
        .functions
        .iter()
        .position(|function| function.name.trim_start_matches('@') == clean)
        .and_then(|index| lowering.environment.callees.get(index))
        .copied()
        .ok_or(CodegenError::InvalidModule("call to unknown function"))
}

fn require_frame_available(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let layout = lowering.environment.layout;
    let context = lowering.context;
    let depth = lowering.builder.ins().load(
        types::I32,
        MemFlagsData::trusted(),
        context,
        layout.frame_depth,
    );
    let limit = lowering.builder.ins().load(
        types::I32,
        MemFlagsData::trusted(),
        context,
        layout.frame_limit,
    );
    let exhausted = lowering
        .builder
        .ins()
        .icmp(IntCC::UnsignedGreaterThanOrEqual, depth, limit);
    guard_trap(
        lowering,
        exhausted,
        "recursionDepthExceeded",
        instruction.span,
    )
}

fn call_arguments(lowering: &Lowering<'_, '_>, arguments: &[ValueId]) -> Vec<Value> {
    let mut values = vec![lowering.context];
    values.extend(
        arguments
            .iter()
            .filter_map(|identifier| lowering.values.get(identifier).copied()),
    );
    values
}
