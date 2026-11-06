#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::Lowering;
use crate::type_mapping::{clif_type, zero_value};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use cranelift_frontend::Switch;
use pseudolearn_aot_rt::STATUS_UNWIND;
use pseudolearn_ir::{Block, BlockId, InstructionId, IrType, Operand, Operation};
use std::collections::HashMap;

pub(crate) struct Unwinding {
    pub(crate) depth: Option<Value>,
    pub(crate) landings: Vec<BlockId>,
    pub(crate) indices: HashMap<InstructionId, u32>,
}

pub(crate) fn landing_index(
    lowering: &Lowering<'_, '_>,
    instruction: InstructionId,
) -> Option<u32> {
    lowering
        .unwinding
        .as_ref()
        .and_then(|unwinding| unwinding.indices.get(&instruction).copied())
}

pub(crate) fn prepare(lowering: &mut Lowering<'_, '_>) {
    let function = lowering.function;
    let mut landings = Vec::new();
    let mut indices = HashMap::new();
    for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
        let operation = function.columns.operation(*instruction);
        if !matches!(
            operation,
            Some(Operation::TaskCancelPoint | Operation::TaskScopeBoundary)
        ) {
            continue;
        }
        let target =
            function
                .columns
                .operands(*instruction)
                .iter()
                .find_map(|operand| match operand {
                    Operand::BlockTarget { target_block, .. } => Some(*target_block),
                    _ => None,
                });
        if let (Some(target), Ok(index)) = (target, u32::try_from(landings.len())) {
            indices.insert(*instruction, index);
            landings.push(target);
        }
    }
    if landings.is_empty() {
        return;
    }
    lowering.unwinding = Some(Unwinding {
        depth: None,
        landings,
        indices,
    });
    declare_variables(lowering);
    lowering.scope = crate::dominated_facts::Scope::isolated();
}

fn declare_variables(lowering: &mut Lowering<'_, '_>) {
    let mut variables = HashMap::new();
    let mut typed: Vec<_> = lowering
        .types
        .iter()
        .map(|(id, kind)| (*id, kind.clone()))
        .collect();
    typed.sort_by_key(|(id, _)| *id);
    for (identifier, kind) in typed {
        if let Some(clif) = clif_type(&kind) {
            let variable = lowering.builder.declare_var(clif);
            let zero = zero_value(&mut lowering.builder, clif);
            lowering.builder.def_var(variable, zero);
            variables.insert(identifier, variable);
        }
    }
    for block in &lowering.function.blocks {
        for (identifier, kind) in &block.parameters {
            if *kind == IrType::I64 {
                let variable = lowering.builder.declare_var(types::I8);
                let zero = lowering.builder.ins().iconst(types::I8, 0);
                lowering.builder.def_var(variable, zero);
                lowering.flag_variables.insert(*identifier, variable);
            }
        }
    }
    lowering.variables = Some(variables);
}

pub(crate) fn define_block_parameters(lowering: &mut Lowering<'_, '_>, block: &Block) {
    if lowering.variables.is_none() {
        return;
    }
    for (identifier, kind) in &block.parameters {
        if let Some(value) = lowering.values.get(identifier).copied() {
            crate::lowering::bind_value(lowering, *identifier, value);
        }
        let flag = lowering.definitions.get(identifier).copied();
        if let (IrType::I64, Some(crate::definition::Definition::Flag(flag))) = (kind, flag)
            && let Some(variable) = lowering.flag_variables.get(identifier).copied()
        {
            lowering.builder.def_var(variable, flag);
        }
    }
}

pub(crate) fn check_cleanup_return(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    let Some(depth) = lowering
        .unwinding
        .as_ref()
        .and_then(|unwinding| unwinding.depth)
    else {
        return Ok(());
    };
    let call = crate::runtime_calls::RuntimeCall {
        target: Entry::TaskReturn,
        code_name: "internalFault",
        span: None,
        operands: &[depth],
    };
    crate::runtime_calls::call_runtime(lowering, &call).map(|_| ())
}

pub(crate) fn emit_landing_check(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    let Some(unwinding) = lowering.unwinding.as_ref() else {
        return Ok(());
    };
    let depth = unwinding
        .depth
        .ok_or(CodegenError::InvalidModule("unwinding frame without depth"))?;
    let landings = unwinding.landings.clone();
    let layout = lowering.environment.layout;
    let context = lowering.context;
    let flags = MemFlagsData::trusted();
    let status = lowering
        .builder
        .ins()
        .load(types::I32, flags, context, layout.fault_status);
    let unwinding_status =
        lowering
            .builder
            .ins()
            .icmp_imm_s(IntCC::Equal, status, i64::from(STATUS_UNWIND));
    let check = lowering.builder.create_block();
    let exit = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(unwinding_status, check, &[], exit, &[]);
    lowering.builder.switch_to_block(check);
    let target = lowering
        .builder
        .ins()
        .load(types::I32, flags, context, layout.unwind_depth);
    let same = lowering.builder.ins().icmp(IntCC::Equal, target, depth);
    let land = lowering.builder.create_block();
    lowering.builder.ins().brif(same, land, &[], exit, &[]);
    lowering.builder.switch_to_block(land);
    land_and_dispatch(lowering, &landings, exit)?;
    lowering.builder.switch_to_block(exit);
    Ok(())
}

fn land_and_dispatch(
    lowering: &mut Lowering<'_, '_>,
    landings: &[BlockId],
    exit: cranelift_codegen::ir::Block,
) -> Result<(), CodegenError> {
    let site = lowering
        .faults
        .register("internalFault", None, String::new())?;
    let site_value = lowering.builder.ins().iconst(types::I32, i64::from(site));
    let target = lowering.environment.runtime.get(Entry::TaskLand)?;
    let call = lowering
        .builder
        .ins()
        .call(target, &[lowering.context, site_value]);
    let status = *lowering
        .builder
        .inst_results(call)
        .first()
        .ok_or(CodegenError::InvalidModule("landing without status"))?;
    let landed = lowering.builder.create_block();
    lowering.builder.ins().brif(status, exit, &[], landed, &[]);
    lowering.builder.switch_to_block(landed);
    let word = lowering.builder.ins().load(
        types::I64,
        MemFlagsData::trusted(),
        lowering.context,
        lowering.environment.layout.result_word,
    );
    let index = lowering.builder.ins().ireduce(types::I32, word);
    let mut switch = Switch::new();
    for (position, block) in landings.iter().enumerate() {
        let destination = *lowering
            .blocks
            .get(block)
            .ok_or(CodegenError::InvalidModule("unknown landing block"))?;
        switch.set_entry(u128::try_from(position).unwrap_or(0), destination);
    }
    switch.emit(&mut lowering.builder, index, exit);
    Ok(())
}
