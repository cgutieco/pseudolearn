#![forbid(unsafe_code)]

use crate::abi_signatures::{Entry, RuntimeRefs};
use crate::block_accounting::StatementCharging;
use crate::class_table::ClassTable;
use crate::context_layout::ContextLayout;
use crate::definition::Definition;
use crate::error::CodegenError;
use crate::fault_table::FaultTable;
use crate::type_mapping::{clif_type, zero_value};
use cranelift_codegen::ir::{Block, FuncRef, GlobalValue, InstBuilder, Value, types};
use cranelift_codegen::isa::TargetFrontendConfig;
use cranelift_frontend::{FunctionBuilder, Variable};
use pseudolearn_ir::{
    BlockId, Function, InstructionId, IrSpan, IrType, Module, Operand, Operation, ValueId,
};
use std::collections::HashMap;

pub(crate) struct FunctionEnvironment<'program> {
    pub(crate) function_table: Option<GlobalValue>,
    pub(crate) signature_tags: &'program [u32],
    pub(crate) module: &'program Module,
    pub(crate) layout: ContextLayout,
    pub(crate) runtime: RuntimeRefs,
    pub(crate) callees: Vec<FuncRef>,
    pub(crate) frontend: TargetFrontendConfig,
    pub(crate) literals: HashMap<String, GlobalValue>,
    pub(crate) classes: &'program ClassTable,
    pub(crate) charging: StatementCharging,
    pub(crate) parameter_roots: crate::target::ParameterRoots,
    pub(crate) task_runtime: bool,
}

pub(crate) struct Instruction<'program> {
    pub(crate) identifier: InstructionId,
    pub(crate) operation: Operation,
    pub(crate) operands: &'program [Operand],
    pub(crate) result: Option<ValueId>,
    pub(crate) span: Option<IrSpan>,
}

pub(crate) struct Lowering<'func, 'program> {
    pub(crate) builder: FunctionBuilder<'func>,
    pub(crate) environment: &'program FunctionEnvironment<'program>,
    pub(crate) function: &'program Function,
    pub(crate) faults: &'program mut FaultTable,
    pub(crate) context: Value,
    pub(crate) cell_frame: Option<Value>,
    pub(crate) fault_lexemes: crate::fault_lexeme::Lexemes,
    pub(crate) values: HashMap<ValueId, Value>,
    pub(crate) blocks: HashMap<BlockId, Block>,
    pub(crate) cold_blocks: Vec<(Block, u32, Option<Value>)>,
    pub(crate) propagate_block: Option<Block>,
    pub(crate) types: HashMap<ValueId, IrType>,
    pub(crate) defined_values: std::collections::HashSet<ValueId>,
    pub(crate) definitions: HashMap<ValueId, Definition>,
    pub(crate) live_roots: HashMap<InstructionId, Vec<ValueId>>,
    pub(crate) scope: crate::dominated_facts::Scope,
    pub(crate) variables: Option<HashMap<ValueId, Variable>>,
    pub(crate) flag_variables: HashMap<ValueId, Variable>,
    pub(crate) cell_frame_variable: Option<Variable>,
    pub(crate) unwinding: Option<crate::task_unwinding::Unwinding>,
}

pub(crate) fn operand_value(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    position: usize,
) -> Result<Value, CodegenError> {
    match instruction.operands.get(position) {
        Some(Operand::Value(identifier)) => value_of(lowering, *identifier)
            .ok_or(CodegenError::InvalidModule("operand value is not defined")),
        _ => Err(CodegenError::InvalidModule("operand is not a value")),
    }
}

pub(crate) fn value_of(lowering: &mut Lowering<'_, '_>, identifier: ValueId) -> Option<Value> {
    if !lowering.values.contains_key(&identifier) {
        return None;
    }
    match lowering
        .variables
        .as_ref()
        .and_then(|variables| variables.get(&identifier))
    {
        Some(variable) => Some(lowering.builder.use_var(*variable)),
        None => lowering.values.get(&identifier).copied(),
    }
}

pub(crate) fn bind_value(lowering: &mut Lowering<'_, '_>, identifier: ValueId, value: Value) {
    lowering.values.insert(identifier, value);
    if let Some(variable) = lowering
        .variables
        .as_ref()
        .and_then(|variables| variables.get(&identifier))
    {
        lowering.builder.def_var(*variable, value);
    }
}

pub(crate) fn bind_result(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    value: Value,
) {
    if let Some(identifier) = instruction.result {
        bind_value(lowering, identifier, value);
    }
}

pub(crate) fn cold_block(
    lowering: &mut Lowering<'_, '_>,
    code_name: &'static str,
    span: Option<IrSpan>,
) -> Result<Block, CodegenError> {
    let lexeme = crate::fault_lexeme::resolve(lowering, code_name, span);
    let site = lowering.faults.register(code_name, span, lexeme)?;
    let block = lowering.builder.create_block();
    lowering.builder.set_cold_block(block);
    lowering.cold_blocks.push((block, site, None));
    Ok(block)
}

pub(crate) fn guard_trap(
    lowering: &mut Lowering<'_, '_>,
    condition: Value,
    code_name: &'static str,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    let cold = cold_block(lowering, code_name, span)?;
    let next = lowering.builder.create_block();
    lowering.builder.ins().brif(condition, cold, &[], next, &[]);
    lowering.builder.switch_to_block(next);
    Ok(())
}

pub(crate) fn guard_character_trap(
    lowering: &mut Lowering<'_, '_>,
    condition: Value,
    word: Value,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    let cold = cold_block(lowering, "invalidCharacterCode", span)?;
    if let Some(trap) = lowering.cold_blocks.last_mut() {
        trap.2 = Some(word);
    }
    let next = lowering.builder.create_block();
    lowering.builder.ins().brif(condition, cold, &[], next, &[]);
    lowering.builder.switch_to_block(next);
    Ok(())
}

pub(crate) fn jump_to_trap(
    lowering: &mut Lowering<'_, '_>,
    code_name: &'static str,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    let cold = cold_block(lowering, code_name, span)?;
    lowering.builder.ins().jump(cold, &[]);
    Ok(())
}

pub(crate) fn propagate_if_failed(lowering: &mut Lowering<'_, '_>, status: Value) {
    let propagate = match lowering.propagate_block {
        Some(block) => block,
        None => {
            let block = lowering.builder.create_block();
            lowering.builder.set_cold_block(block);
            lowering.propagate_block = Some(block);
            block
        }
    };
    let next = lowering.builder.create_block();
    lowering
        .builder
        .ins()
        .brif(status, propagate, &[], next, &[]);
    lowering.builder.switch_to_block(next);
}

pub(crate) fn emit_return_zero(lowering: &mut Lowering<'_, '_>) {
    match clif_type(&lowering.function.return_type) {
        Some(value_type) => {
            let zero = zero_value(&mut lowering.builder, value_type);
            lowering.builder.ins().return_(&[zero]);
        }
        None => {
            lowering.builder.ins().return_(&[]);
        }
    }
}

pub(crate) fn finish_cold_blocks(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    let fault = lowering.environment.runtime.get(Entry::Fault)?;
    let shared = lowering.builder.create_block();
    lowering.builder.set_cold_block(shared);
    let shared_site = lowering.builder.append_block_param(shared, types::I32);
    for (block, site, word) in std::mem::take(&mut lowering.cold_blocks) {
        lowering.builder.switch_to_block(block);
        if let Some(word) = word {
            lowering.builder.ins().store(
                cranelift_codegen::ir::MemFlagsData::trusted(),
                word,
                lowering.context,
                lowering.environment.layout.result_word,
            );
        }
        let site_value = lowering.builder.ins().iconst(types::I32, i64::from(site));
        lowering.builder.ins().jump(shared, &[site_value.into()]);
    }
    lowering.builder.switch_to_block(shared);
    lowering
        .builder
        .ins()
        .call(fault, &[lowering.context, shared_site]);
    jump_to_propagation(lowering);
    if let Some(block) = lowering.propagate_block {
        lowering.builder.switch_to_block(block);
        crate::task_unwinding::emit_landing_check(lowering)?;
        emit_return_zero(lowering);
    }
    Ok(())
}

pub(crate) fn trap_and_continue(
    lowering: &mut Lowering<'_, '_>,
    code_name: &'static str,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    jump_to_trap(lowering, code_name, span)?;
    let unreachable = lowering.builder.create_block();
    lowering.builder.switch_to_block(unreachable);
    Ok(())
}

pub(crate) fn jump_to_propagation(lowering: &mut Lowering<'_, '_>) {
    let block = match lowering.propagate_block {
        Some(block) => block,
        None => {
            let block = lowering.builder.create_block();
            lowering.builder.set_cold_block(block);
            lowering.propagate_block = Some(block);
            block
        }
    };
    lowering.builder.ins().jump(block, &[]);
}
