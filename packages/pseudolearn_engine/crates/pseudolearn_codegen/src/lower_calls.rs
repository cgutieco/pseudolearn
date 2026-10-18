#![forbid(unsafe_code)]

use crate::class_table::same_function;
use crate::definition::{Definition, definition_of};
use crate::error::CodegenError;
use crate::lowering::{
    Instruction, Lowering, bind_result, guard_trap, propagate_if_failed, trap_and_continue,
};
use crate::shadow_stack::{pop_roots, push_roots};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{FuncRef, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::{Operand, ValueId};

pub(crate) struct CallTarget<'operands> {
    pub(crate) function_name: &'operands str,
    pub(crate) arguments: &'operands [ValueId],
}

pub(crate) fn call_target<'operands>(
    instruction: &Instruction<'operands>,
) -> Result<CallTarget<'operands>, CodegenError> {
    match instruction.operands.last() {
        Some(Operand::FunctionTarget {
            function_name,
            arguments,
        }) => Ok(CallTarget {
            function_name,
            arguments,
        }),
        _ => Err(CodegenError::InvalidModule("call without function target")),
    }
}

pub(crate) fn lower_call(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = call_target(instruction)?;
    let index = function_index(lowering, target.function_name)?;
    let callee = callee_reference(lowering, index)?;
    let frame = push_roots(lowering, instruction)?;
    let produced = invoke(lowering, instruction, (callee, target.arguments))?;
    pop_roots(lowering, frame);
    if let Some(value) = produced {
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

pub(crate) fn invoke(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (callee, arguments): (FuncRef, &[ValueId]),
) -> Result<Option<Value>, CodegenError> {
    require_frame_available(lowering, instruction)?;
    require_arguments_defined(lowering, instruction, arguments)?;
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
    Ok(lowering.builder.inst_results(call).first().copied())
}

pub(crate) fn function_index(
    lowering: &Lowering<'_, '_>,
    function_name: &str,
) -> Result<usize, CodegenError> {
    lowering
        .environment
        .module
        .functions
        .iter()
        .position(|function| same_function(&function.name, function_name))
        .ok_or(CodegenError::InvalidModule("call to unknown function"))
}

pub(crate) fn callee_reference(
    lowering: &Lowering<'_, '_>,
    index: usize,
) -> Result<FuncRef, CodegenError> {
    lowering
        .environment
        .callees
        .get(index)
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

fn require_arguments_defined(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    arguments: &[ValueId],
) -> Result<(), CodegenError> {
    for argument in arguments {
        match definition_of(lowering, *argument) {
            Definition::Defined => {}
            Definition::Undefined => {
                trap_and_continue(lowering, "uninitializedVariableRead", instruction.span)?;
            }
            Definition::Flag(flag) => {
                let missing = lowering.builder.ins().icmp_imm_s(IntCC::Equal, flag, 0);
                guard_trap(
                    lowering,
                    missing,
                    "uninitializedVariableRead",
                    instruction.span,
                )?;
            }
        }
    }
    Ok(())
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
