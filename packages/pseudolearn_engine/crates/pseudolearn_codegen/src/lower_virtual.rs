#![forbid(unsafe_code)]

use crate::class_table::method_name;
use crate::error::CodegenError;
use crate::inline_memory::heap_base;
use crate::lower_calls::{call_target, callee_reference, invoke};
use crate::lowering::{
    Instruction, Lowering, bind_result, guard_trap, jump_to_trap, operand_value,
};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::type_mapping::clif_type;
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{Block, BlockArg, InstBuilder, MemFlagsData, Value, types};
use cranelift_frontend::Switch;
use std::collections::HashMap;

const FIRST_CLASS_TAG: i64 = 3;

pub(crate) fn lower_virtual_call(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = call_target(instruction)?;
    let method = method_name(target.function_name)
        .ok_or(CodegenError::InvalidModule("virtual call without method"))?;
    let targets = lowering.environment.classes.targets(method);
    let receiver = operand_value(lowering, instruction, 0)?;
    let result_type = lowering
        .environment
        .module
        .find_function(target.function_name)
        .and_then(|callee| clif_type(&callee.return_type));
    let frame = push_roots(lowering, instruction)?;
    let absent = lowering.builder.ins().icmp_imm_s(IntCC::Equal, receiver, 0);
    guard_trap(
        lowering,
        absent,
        "uninitializedVariableRead",
        instruction.span,
    )?;
    let class = class_of(lowering, receiver);
    let merge = lowering.builder.create_block();
    if let Some(value_type) = result_type {
        lowering.builder.append_block_param(merge, value_type);
    }
    let blocks = dispatch(lowering, class, &targets, instruction)?;
    emit_targets(lowering, instruction, (&blocks, merge))?;
    lowering.builder.switch_to_block(merge);
    pop_roots(lowering, frame);
    if result_type.is_some()
        && let Some(value) = lowering.builder.block_params(merge).first().copied()
    {
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

fn emit_targets(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (blocks, merge): (&[(usize, Block)], Block),
) -> Result<(), CodegenError> {
    let target = call_target(instruction)?;
    for (function, block) in blocks {
        lowering.builder.switch_to_block(*block);
        let callee = callee_reference(lowering, *function)?;
        let produced = invoke(lowering, instruction, (callee, target.arguments))?;
        let arguments: Vec<BlockArg> = produced.into_iter().map(BlockArg::Value).collect();
        lowering.builder.ins().jump(merge, &arguments);
    }
    Ok(())
}

fn class_of(lowering: &mut Lowering<'_, '_>, receiver: Value) -> Value {
    let (_, base) = heap_base(lowering, receiver);
    let header = lowering
        .builder
        .ins()
        .load(types::I64, MemFlagsData::trusted(), base, 0);
    let tag = lowering.builder.ins().ireduce(types::I32, header);
    lowering.builder.ins().iadd_imm_s(tag, -FIRST_CLASS_TAG)
}

fn dispatch(
    lowering: &mut Lowering<'_, '_>,
    class: Value,
    targets: &[(usize, usize)],
    instruction: &Instruction<'_>,
) -> Result<Vec<(usize, Block)>, CodegenError> {
    let mut switch = Switch::new();
    let mut by_function: HashMap<usize, Block> = HashMap::new();
    let mut order = Vec::new();
    for (class_index, function) in targets {
        let block = match by_function.get(function) {
            Some(block) => *block,
            None => {
                let created = lowering.builder.create_block();
                by_function.insert(*function, created);
                order.push((*function, created));
                created
            }
        };
        let entry = u128::try_from(*class_index)
            .map_err(|_| CodegenError::InvalidModule("class index out of range"))?;
        switch.set_entry(entry, block);
    }
    let otherwise = lowering.builder.create_block();
    switch.emit(&mut lowering.builder, class, otherwise);
    lowering.builder.switch_to_block(otherwise);
    jump_to_trap(lowering, "internalFault", instruction.span)?;
    Ok(order)
}
