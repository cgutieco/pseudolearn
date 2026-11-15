#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::type_mapping::clif_type;
use cranelift_codegen::Context;
use cranelift_codegen::ir::{
    AbiParam, Function as ClifFunction, InstBuilder, MemFlagsData, Type, UserFuncName, Value, types,
};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext, Switch};
use cranelift_module::{FuncId, Linkage, Module as ClifModule};
use cranelift_object::ObjectModule;
use pseudolearn_ir::{IrType, Module, Operand, Operation};

pub const DISPATCH_SYMBOL: &str = "__pl_task_dispatch";

pub(crate) fn targets(module: &Module) -> Vec<usize> {
    let mut found = Vec::new();
    for function in &module.functions {
        for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
            if function.columns.operation(*instruction) != Some(Operation::TaskSpawn) {
                continue;
            }
            let target = function
                .columns
                .operands(*instruction)
                .iter()
                .find_map(|operand| match operand {
                    Operand::FunctionTarget { function_name, .. } => module
                        .functions
                        .iter()
                        .position(|candidate| candidate.name == *function_name),
                    _ => None,
                });
            if let Some(index) = target.filter(|index| !found.contains(index)) {
                found.push(index);
            }
        }
    }
    found
}

pub(crate) fn uses_task_runtime(module: &Module) -> bool {
    module.functions.iter().any(|function| {
        function
            .blocks
            .iter()
            .flat_map(|block| &block.instructions)
            .filter_map(|instruction| function.columns.operation(*instruction))
            .any(|operation| {
                operation != Operation::TaskYieldCheck
                    && crate::lower_tasks::OPERATIONS.contains(&operation)
            })
    })
}

pub(crate) fn dispatch_index(module: &Module, function_name: &str) -> Option<u32> {
    let index = module
        .functions
        .iter()
        .position(|candidate| candidate.name == function_name)?;
    targets(module)
        .iter()
        .position(|target| *target == index)
        .and_then(|position| u32::try_from(position).ok())
}

pub(crate) fn define_dispatcher(
    object: &mut ObjectModule,
    module: &Module,
    identifiers: &[FuncId],
) -> Result<Option<FuncId>, CodegenError> {
    if !uses_task_runtime(module) {
        return Ok(None);
    }
    let targets = targets(module);
    let pointer = object.isa().pointer_type();
    let mut signature = object.make_signature();
    signature.params.push(AbiParam::new(pointer));
    signature.params.push(AbiParam::new(types::I32));
    signature.params.push(AbiParam::new(pointer));
    let dispatcher = object
        .declare_function(DISPATCH_SYMBOL, Linkage::Local, &signature)
        .map_err(CodegenError::backend)?;
    let mut clif = ClifFunction::with_name_signature(UserFuncName::user(2, 0), signature);
    let mut callees = Vec::new();
    for target in &targets {
        let identifier = identifiers
            .get(*target)
            .ok_or(CodegenError::InvalidModule("undeclared task function"))?;
        let function = module
            .functions
            .get(*target)
            .ok_or(CodegenError::InvalidModule("unknown task function"))?;
        let reference = object.declare_func_in_func(*identifier, &mut clif);
        callees.push((reference, function.parameters.clone()));
    }
    build(&mut clif, &callees, object.isa().frontend_config())?;
    let mut context = Context::for_function(clif);
    object
        .define_function(dispatcher, &mut context)
        .map_err(CodegenError::backend)?;
    Ok(Some(dispatcher))
}

type Callee = (
    cranelift_codegen::ir::FuncRef,
    Vec<(pseudolearn_ir::ValueId, IrType)>,
);

fn build(
    clif: &mut ClifFunction,
    callees: &[Callee],
    frontend: cranelift_codegen::isa::TargetFrontendConfig,
) -> Result<(), CodegenError> {
    let mut builder_context = FunctionBuilderContext::new();
    let mut builder = FunctionBuilder::new(clif, &mut builder_context);
    let entry = builder.create_block();
    builder.append_block_params_for_function_params(entry);
    builder.switch_to_block(entry);
    let parameters = builder.block_params(entry).to_vec();
    let [context, selector, arguments] = parameters.as_slice() else {
        return Err(CodegenError::InvalidModule("dispatcher parameters"));
    };
    let done = builder.create_block();
    let mut switch = Switch::new();
    let mut cases = Vec::new();
    for (position, _) in callees.iter().enumerate() {
        let block = builder.create_block();
        switch.set_entry(u128::try_from(position).unwrap_or(0), block);
        cases.push(block);
    }
    switch.emit(&mut builder, *selector, done);
    for (block, callee) in cases.into_iter().zip(callees) {
        builder.switch_to_block(block);
        call_target(&mut builder, (*context, *arguments), callee);
        builder.ins().jump(done, &[]);
    }
    builder.switch_to_block(done);
    builder.ins().return_(&[]);
    builder.seal_all_blocks();
    builder.finalize(frontend);
    Ok(())
}

fn call_target(
    builder: &mut FunctionBuilder<'_>,
    (context, arguments): (Value, Value),
    callee: &Callee,
) {
    let (reference, parameters) = callee;
    let mut values = vec![context];
    let mut slot = 0_i32;
    for (_, parameter) in parameters {
        if let Some(kind) = clif_type(parameter) {
            values.push(load_argument(builder, (arguments, slot), kind));
            slot = slot.saturating_add(8);
        }
    }
    builder.ins().call(*reference, &values);
}

fn load_argument(
    builder: &mut FunctionBuilder<'_>,
    (base, offset): (Value, i32),
    kind: Type,
) -> Value {
    let word = builder
        .ins()
        .load(types::I64, MemFlagsData::trusted(), base, offset);
    match kind {
        types::I64 => word,
        types::F64 => builder.ins().bitcast(types::F64, MemFlagsData::new(), word),
        narrow => builder.ins().ireduce(narrow, word),
    }
}
