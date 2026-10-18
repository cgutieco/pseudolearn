#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::Context;
use cranelift_codegen::ir::{
    AbiParam, FuncRef, Function as ClifFunction, GlobalValue, InstBuilder, Type, UserFuncName,
    types,
};
use cranelift_codegen::isa::TargetFrontendConfig;
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use cranelift_module::{DataDescription, FuncId, Linkage, Module as ClifModule};
use cranelift_object::ObjectModule;

pub const MAIN_SYMBOL: &str = "main";
pub const RUNTIME_MAIN_SYMBOL: &str = "pseudolearn_aot_main";
pub const METADATA_SYMBOL: &str = "__pl_metadata";

pub(crate) struct EntryPoint<'program> {
    pub(crate) function: FuncId,
    pub(crate) metadata: &'program [u8],
}

pub(crate) fn define_entry_point(
    object: &mut ObjectModule,
    entry: &EntryPoint<'_>,
) -> Result<(), CodegenError> {
    let pointer = object.isa().pointer_type();
    let runtime_main = declare_runtime_main(object, pointer)?;
    let metadata = declare_metadata(object, entry.metadata)?;
    let mut signature = object.make_signature();
    signature.params.push(AbiParam::new(types::I32));
    signature.params.push(AbiParam::new(pointer));
    signature.returns.push(AbiParam::new(types::I32));
    let main = object
        .declare_function(MAIN_SYMBOL, Linkage::Export, &signature)
        .map_err(CodegenError::backend)?;
    let mut clif = ClifFunction::with_name_signature(UserFuncName::user(1, 0), signature);
    let references = References {
        entry: object.declare_func_in_func(entry.function, &mut clif),
        runtime: object.declare_func_in_func(runtime_main, &mut clif),
        metadata: object.declare_data_in_func(metadata, &mut clif),
        count: i64::try_from(entry.metadata.len())
            .map_err(|_| CodegenError::InvalidModule("metadata too large"))?,
    };
    build_main(
        &mut clif,
        pointer,
        &references,
        object.isa().frontend_config(),
    )?;
    let mut context = Context::for_function(clif);
    object
        .define_function(main, &mut context)
        .map_err(CodegenError::backend)
}

struct References {
    entry: FuncRef,
    runtime: FuncRef,
    metadata: GlobalValue,
    count: i64,
}

fn build_main(
    clif: &mut ClifFunction,
    pointer: Type,
    references: &References,
    frontend: TargetFrontendConfig,
) -> Result<(), CodegenError> {
    let mut builder_context = FunctionBuilderContext::new();
    let mut builder = FunctionBuilder::new(clif, &mut builder_context);
    let block = builder.create_block();
    builder.append_block_params_for_function_params(block);
    builder.switch_to_block(block);
    let entry_address = builder.ins().func_addr(pointer, references.entry);
    let metadata_address = builder.ins().symbol_value(pointer, references.metadata);
    let count = builder.ins().iconst(pointer, references.count);
    let call = builder.ins().call(
        references.runtime,
        &[entry_address, metadata_address, count],
    );
    let status = builder
        .inst_results(call)
        .first()
        .copied()
        .ok_or(CodegenError::InvalidModule("runtime main without result"))?;
    builder.ins().return_(&[status]);
    builder.seal_all_blocks();
    builder.finalize(frontend);
    Ok(())
}

fn declare_runtime_main(object: &mut ObjectModule, pointer: Type) -> Result<FuncId, CodegenError> {
    let mut signature = object.make_signature();
    for _ in 0..3 {
        signature.params.push(AbiParam::new(pointer));
    }
    signature.returns.push(AbiParam::new(types::I32));
    object
        .declare_function(RUNTIME_MAIN_SYMBOL, Linkage::Import, &signature)
        .map_err(CodegenError::backend)
}

fn declare_metadata(
    object: &mut ObjectModule,
    bytes: &[u8],
) -> Result<cranelift_module::DataId, CodegenError> {
    let storage = object
        .declare_data(METADATA_SYMBOL, Linkage::Local, false, false)
        .map_err(CodegenError::backend)?;
    let mut description = DataDescription::new();
    description.define(bytes.to_vec().into_boxed_slice());
    object
        .define_data(storage, &description)
        .map_err(CodegenError::backend)?;
    Ok(storage)
}
