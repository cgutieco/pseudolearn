#![forbid(unsafe_code)]

mod abi_signatures;
mod array_fast_path;
mod block_accounting;
mod block_order;
mod block_parameters;
mod borrowed_roots;
mod cell_frames;
mod class_table;
mod constant_folding;
mod constant_overflow;
mod context_layout;
mod defined_producers;
mod definition;
mod dominated_facts;
mod dominators;
mod entry_point;
mod error;
mod fault_lexeme;
mod fault_table;
mod function_compiler;
mod inline_memory;
mod instruction_dispatch;
mod lexical_roots;
#[cfg(test)]
mod lexical_roots_tests;
mod literals;
mod liveness;
mod lower_arithmetic;
mod lower_arrays;
mod lower_calls;
mod lower_cells;
mod lower_collections;
mod lower_control;
mod lower_effects;
mod lower_io;
mod lower_math;
mod lower_objects;
mod lower_real;
mod lower_scalars;
mod lower_text;
mod lower_virtual;
mod lowering;
mod memory_regions;
mod object_allocation;
mod object_emitter;
mod object_fast_path;
mod runtime_calls;
mod shadow_stack;
mod target;
mod type_mapping;
mod value_types;
mod word_conversion;

pub use abi_signatures::{
    FAULT_SYMBOL, INTEGER_POWER_SYMBOL, MATH_UNARY_SYMBOL, REAL_POWER_SYMBOL,
};
pub use entry_point::{MAIN_SYMBOL, METADATA_SYMBOL, RUNTIME_MAIN_SYMBOL};
pub use error::CodegenError;
pub use object_emitter::{CompiledObject, FunctionSymbol, function_symbol};
pub use target::{ParameterRoots, TargetConfig};

pub fn compile_module_to_object(
    module: &pseudolearn_ir::Module,
    target: &TargetConfig,
) -> Result<CompiledObject, CodegenError> {
    pseudolearn_ir::verify_module(module).map_err(CodegenError::InvalidModule)?;
    object_emitter::emit_module(module, target, object_emitter::EmissionMode::Library)
}

pub fn compile_module_to_executable_object(
    module: &pseudolearn_ir::Module,
    target: &TargetConfig,
    settings: &pseudolearn_aot_rt::ExecutableSettings,
) -> Result<CompiledObject, CodegenError> {
    pseudolearn_ir::verify_module(module).map_err(CodegenError::InvalidModule)?;
    object_emitter::emit_module(
        module,
        target,
        object_emitter::EmissionMode::Executable(settings),
    )
}

pub fn compile_module_to_benchmark_object(
    module: &pseudolearn_ir::Module,
    target: &TargetConfig,
    settings: &pseudolearn_aot_rt::ExecutableSettings,
) -> Result<CompiledObject, CodegenError> {
    pseudolearn_ir::verify_module(module).map_err(CodegenError::InvalidModule)?;
    object_emitter::emit_module(
        module,
        target,
        object_emitter::EmissionMode::Benchmark(settings),
    )
}

mod lower_variant_values;

mod lower_switch;

mod function_table;
mod lower_indirect;

mod lower_raw_object;
