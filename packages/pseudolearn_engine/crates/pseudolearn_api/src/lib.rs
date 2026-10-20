#![forbid(unsafe_code)]

pub mod analyze;
mod argument_conversion;
mod diagnostic_conversion;
pub mod errors;
pub mod ir_execution;
pub mod model;
pub mod service;
pub mod versioning;
pub mod wire;

pub use analyze::{detect_vocabulary_profile, execute_analyze, line_and_column};
pub use errors::ApiError;
pub use ir_execution::{compile_source_to_ir, compile_source_to_module, execute_ir};
pub use model::{
    AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, ApiPosition, ApiSpan, ApiUnit, IrOutcome,
    IrRequest, IrResponse,
};
pub use probes::probe;
pub use versioning::{
    ENGINE_VERSION, PROTOCOL_VERSION, SUBJECT_NAME, supported_capabilities, supported_profiles,
    supported_strictness,
};
pub use wire::{deserialize_from_str, serialize_to_string};

pub use diagnostic_conversion::render_diagnostic;

mod diagnostic_template;
mod editor_vocabulary;
mod execution;
mod execution_model;
mod execution_state;
mod execution_wire;
mod fault_injection;
mod probes;
mod recording_options;
mod reference_vocabulary;
mod stepping;
pub use execution::{PreparedProgram, execute_prepared, execute_program, prepare_program};
pub use execution_model::{ExecuteRequest, ExecuteResponse, ExecutionLimits};

mod event_source;
mod execution_capture;
mod execution_resource;
mod locale_operations;
mod program_view;
mod program_view_annotations;
mod program_view_kind;
mod program_view_members;
mod program_view_operations;
mod program_view_relations;
mod program_view_tokens;
mod program_view_tree;
mod resources;
mod service_completion;
mod state_pages;
mod typed_values;
pub use program_view_operations::analysis_program_view;
pub use resources::ApiSession;

mod event_binary;
mod event_codec;

#[cfg(feature = "native")]
mod native_build;
#[cfg(feature = "native")]
pub use native_build::{NativeBuildFailure, NativeBuildRequest, NativeObject, build_native_object};

#[cfg(feature = "native")]
mod native_benchmark;
#[cfg(feature = "native")]
pub use native_benchmark::{
    BenchmarkObject, PreparedNativeBenchmark, build_benchmark_object, emit_benchmark_object,
    inspect_benchmark_object, prepare_native_benchmark,
};

#[cfg(feature = "native")]
mod native_execution;
#[cfg(feature = "native")]
pub use native_execution::{
    NativeRunReport, conformance_build_request, native_execute_response, rejected_native_response,
};

mod recording;
mod state_changes;
