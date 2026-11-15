#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::Context;
use cranelift_codegen::ir::{AbiParam, Function as ClifFunction, InstBuilder, UserFuncName, types};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use cranelift_module::{DataDescription, DataId, FuncId, Linkage, Module as ClifModule};
use cranelift_object::ObjectModule;
use target_lexicon::BinaryFormat;

pub const WINDOWS_ENTRY_SYMBOL: &str = "mainCRTStartup";
pub const RUNTIME_EXIT_SYMBOL: &str = "pseudolearn_aot_exit";
pub const TLS_DIRECTORY_SYMBOL: &str = "_tls_used";

struct SectionMarker {
    symbol: &'static str,
    section: &'static str,
}

const TLS_START: SectionMarker = SectionMarker {
    symbol: "_tls_start",
    section: ".tls",
};
const TLS_END: SectionMarker = SectionMarker {
    symbol: "_tls_end",
    section: ".tls$ZZZ",
};
const CALLBACKS_START: SectionMarker = SectionMarker {
    symbol: "__xl_a",
    section: ".CRT$XLA",
};
const CALLBACKS_END: SectionMarker = SectionMarker {
    symbol: "__xl_z",
    section: ".CRT$XLZ",
};
const TLS_INDEX_SYMBOL: &str = "_tls_index";
const FLOAT_MARKER_SYMBOL: &str = "_fltused";
const FLOAT_MARKER_VALUE: u32 = 0x9875;
const TYPE_INFO_TABLE_SYMBOL: &str = "??_7type_info@@6B@";
const TLS_DIRECTORY_SECTION: &str = ".rdata$T";
const POINTER_BYTES: usize = 8;
const TLS_DIRECTORY_BYTES: usize = 40;

pub(crate) fn define_for_windows(
    object: &mut ObjectModule,
    main: FuncId,
) -> Result<(), CodegenError> {
    if object.isa().triple().binary_format != BinaryFormat::Coff {
        return Ok(());
    }
    define_process_entry(object, main)?;
    define_tls_directory(object)?;
    define_word(object, FLOAT_MARKER_SYMBOL, FLOAT_MARKER_VALUE)?;
    define_exception_type_table(object)
}

fn define_exception_type_table(object: &mut ObjectModule) -> Result<(), CodegenError> {
    let table = object
        .declare_data(TYPE_INFO_TABLE_SYMBOL, Linkage::Export, false, false)
        .map_err(CodegenError::backend)?;
    let mut description = DataDescription::new();
    description.define(vec![0; POINTER_BYTES].into_boxed_slice());
    object
        .define_data(table, &description)
        .map_err(CodegenError::backend)
}

fn define_process_entry(object: &mut ObjectModule, main: FuncId) -> Result<(), CodegenError> {
    let pointer = object.isa().pointer_type();
    let mut exit_signature = object.make_signature();
    exit_signature.params.push(AbiParam::new(types::I32));
    let exit = object
        .declare_function(RUNTIME_EXIT_SYMBOL, Linkage::Import, &exit_signature)
        .map_err(CodegenError::backend)?;
    let mut signature = object.make_signature();
    signature.returns.push(AbiParam::new(types::I32));
    let entry = object
        .declare_function(WINDOWS_ENTRY_SYMBOL, Linkage::Export, &signature)
        .map_err(CodegenError::backend)?;
    let mut clif = ClifFunction::with_name_signature(UserFuncName::user(1, 1), signature);
    let main_reference = object.declare_func_in_func(main, &mut clif);
    let exit_reference = object.declare_func_in_func(exit, &mut clif);
    let mut builder_context = FunctionBuilderContext::new();
    let mut builder = FunctionBuilder::new(&mut clif, &mut builder_context);
    let block = builder.create_block();
    builder.switch_to_block(block);
    let count = builder.ins().iconst(types::I32, 0);
    let vector = builder.ins().iconst(pointer, 0);
    let call = builder.ins().call(main_reference, &[count, vector]);
    let status = builder
        .inst_results(call)
        .first()
        .copied()
        .ok_or(CodegenError::InvalidModule("main without result"))?;
    builder.ins().call(exit_reference, &[status]);
    builder.ins().return_(&[status]);
    builder.seal_all_blocks();
    builder.finalize(object.isa().frontend_config());
    let mut context = Context::for_function(clif);
    object
        .define_function(entry, &mut context)
        .map_err(CodegenError::backend)
}

fn define_tls_directory(object: &mut ObjectModule) -> Result<(), CodegenError> {
    let index = define_word(object, TLS_INDEX_SYMBOL, 0)?;
    let start = define_marker(object, &TLS_START)?;
    let end = define_marker(object, &TLS_END)?;
    let callbacks = define_marker(object, &CALLBACKS_START)?;
    define_marker(object, &CALLBACKS_END)?;
    let directory = object
        .declare_data(TLS_DIRECTORY_SYMBOL, Linkage::Export, false, false)
        .map_err(CodegenError::backend)?;
    let mut description = DataDescription::new();
    description.define(vec![0; TLS_DIRECTORY_BYTES].into_boxed_slice());
    description.set_custom_section(TLS_DIRECTORY_SECTION);
    for (slot, (target, addend)) in [(start, 0), (end, 0), (index, 0), (callbacks, 8)]
        .into_iter()
        .enumerate()
    {
        let reference = object.declare_data_in_data(target, &mut description);
        let offset = slot
            .checked_mul(POINTER_BYTES)
            .and_then(|bytes| u32::try_from(bytes).ok())
            .ok_or(CodegenError::InvalidModule("TLS directory offset"))?;
        description.write_data_addr(offset, reference, addend);
    }
    object
        .define_data(directory, &description)
        .map_err(CodegenError::backend)
}

fn define_marker(
    object: &mut ObjectModule,
    marker: &SectionMarker,
) -> Result<DataId, CodegenError> {
    let marker_symbol = object
        .declare_data(marker.symbol, Linkage::Local, true, false)
        .map_err(CodegenError::backend)?;
    let mut description = DataDescription::new();
    description.define(vec![0; POINTER_BYTES].into_boxed_slice());
    description.set_custom_section(marker.section);
    object
        .define_data(marker_symbol, &description)
        .map_err(CodegenError::backend)?;
    Ok(marker_symbol)
}

fn define_word(
    object: &mut ObjectModule,
    symbol: &str,
    value: u32,
) -> Result<DataId, CodegenError> {
    let word = object
        .declare_data(symbol, Linkage::Export, true, false)
        .map_err(CodegenError::backend)?;
    let mut description = DataDescription::new();
    description.define(value.to_le_bytes().to_vec().into_boxed_slice());
    object
        .define_data(word, &description)
        .map_err(CodegenError::backend)?;
    Ok(word)
}
