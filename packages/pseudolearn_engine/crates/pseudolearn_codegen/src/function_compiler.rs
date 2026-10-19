#![forbid(unsafe_code)]

use crate::block_accounting::charge_block_mass;
use crate::block_order::reverse_postorder;
use crate::definition::Definition;
use crate::error::CodegenError;
use crate::fault_table::FaultTable;
use crate::instruction_dispatch::lower_instruction;
use crate::liveness::live_roots;
use crate::lowering::{FunctionEnvironment, Instruction, Lowering, finish_cold_blocks};
use crate::type_mapping::clif_type;
use cranelift_codegen::ir::{Function as ClifFunction, InstBuilder, MemFlagsData, types};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use pseudolearn_ir::{BlockId, Function, IrType};
use std::collections::HashMap;

pub(crate) fn compile_function<'program>(
    function: &'program Function,
    environment: &'program FunctionEnvironment<'program>,
    clif: &mut ClifFunction,
    faults: &'program mut FaultTable,
) -> Result<(), CodegenError> {
    let mut builder_context = FunctionBuilderContext::new();
    let builder = FunctionBuilder::new(clif, &mut builder_context);
    let mut lowering = start_function(builder, function, environment, faults)?;
    for identifier in reverse_postorder(function) {
        lower_block(&mut lowering, identifier)?;
    }
    finish_cold_blocks(&mut lowering)?;
    lowering.builder.seal_all_blocks();
    lowering.builder.finalize(environment.frontend);
    Ok(())
}

fn start_function<'func, 'program>(
    mut builder: FunctionBuilder<'func>,
    function: &'program Function,
    environment: &'program FunctionEnvironment<'program>,
    faults: &'program mut FaultTable,
) -> Result<Lowering<'func, 'program>, CodegenError> {
    let types = crate::value_types::infer(environment.module, function);
    let entry = builder.create_block();
    builder.append_block_params_for_function_params(entry);
    builder.switch_to_block(entry);
    let entry_values = builder.block_params(entry).to_vec();
    let context = *entry_values
        .first()
        .ok_or(CodegenError::InvalidModule("function without context"))?;
    let mut lowering = Lowering {
        builder,
        environment,
        function,
        faults,
        context,
        cell_frame: None,
        fault_lexemes: crate::fault_lexeme::collect(function, environment.module),
        values: HashMap::new(),
        blocks: HashMap::new(),
        cold_blocks: Vec::new(),
        propagate_block: None,
        types: types.clone(),
        defined_values: crate::defined_producers::collect(function),
        definitions: HashMap::new(),
        live_roots: live_roots(function, &types, environment.parameter_roots),
    };
    bind_parameters(&mut lowering, entry_values.get(1..).unwrap_or(&[]));
    declare_blocks(&mut lowering);
    enter_frame(&mut lowering);
    crate::cell_frames::enter(&mut lowering)?;
    let first = entry_block(&lowering)?;
    lowering.builder.ins().jump(first, &[]);
    Ok(lowering)
}

fn bind_parameters(lowering: &mut Lowering<'_, '_>, entry_values: &[cranelift_codegen::ir::Value]) {
    let mapped = lowering
        .function
        .parameters
        .iter()
        .filter(|(_, parameter_type)| clif_type(parameter_type).is_some());
    for ((identifier, _), value) in mapped.zip(entry_values) {
        lowering.values.insert(*identifier, *value);
    }
}

fn declare_blocks(lowering: &mut Lowering<'_, '_>) {
    for block in &lowering.function.blocks {
        let created = lowering.builder.create_block();
        for (identifier, parameter_type) in &block.parameters {
            if let Some(clif) = clif_type(parameter_type) {
                let value = lowering.builder.append_block_param(created, clif);
                lowering.values.insert(*identifier, value);
            }
        }
        for (identifier, parameter_type) in &block.parameters {
            if *parameter_type == IrType::I64 {
                let flag = lowering.builder.append_block_param(created, types::I8);
                lowering
                    .definitions
                    .insert(*identifier, Definition::Flag(flag));
            }
        }
        lowering.blocks.insert(block.identifier, created);
    }
}

fn enter_frame(lowering: &mut Lowering<'_, '_>) {
    let offset = lowering.environment.layout.frame_depth;
    let context = lowering.context;
    let depth = lowering
        .builder
        .ins()
        .load(types::I32, MemFlagsData::trusted(), context, offset);
    let acquired = lowering.builder.ins().iadd_imm_s(depth, 1);
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), acquired, context, offset);
}

fn lower_block(lowering: &mut Lowering<'_, '_>, identifier: BlockId) -> Result<(), CodegenError> {
    let function = lowering.function;
    let block = function
        .block(identifier)
        .ok_or(CodegenError::InvalidModule("unknown block"))?;
    let created = *lowering
        .blocks
        .get(&identifier)
        .ok_or(CodegenError::InvalidModule("undeclared block"))?;
    lowering.builder.switch_to_block(created);
    charge_block_mass(lowering, block)?;
    for instruction_id in &block.instructions {
        let columns = &function.columns;
        let operation = columns
            .operation(*instruction_id)
            .ok_or(CodegenError::InvalidModule("instruction without operation"))?;
        let instruction = Instruction {
            identifier: *instruction_id,
            operation,
            operands: columns.operands(*instruction_id),
            result: columns.result(*instruction_id),
            span: columns.span(*instruction_id),
        };
        lower_instruction(lowering, &instruction)?;
    }
    Ok(())
}

fn entry_block(lowering: &Lowering<'_, '_>) -> Result<cranelift_codegen::ir::Block, CodegenError> {
    lowering
        .function
        .blocks
        .first()
        .and_then(|block| lowering.blocks.get(&block.identifier).copied())
        .ok_or(CodegenError::InvalidModule("function without blocks"))
}
