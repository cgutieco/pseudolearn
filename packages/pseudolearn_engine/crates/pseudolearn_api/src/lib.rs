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
    AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, ApiHelpCard, ApiHelpCoordinateUnit,
    ApiHelpDetail, ApiHelpEntry, ApiHelpExample, ApiHelpIdentity, ApiHelpPart,
    ApiHelpQueryPosition, ApiHelpQueryRequest, ApiHelpQueryResponse, ApiHelpResolution,
    ApiHelpSymbol, ApiPosition, ApiSourceIdentity, ApiSpan, ApiToken, ApiUnit, IrOutcome,
    IrRequest, IrResponse,
};
pub use probes::probe;
pub use pseudolearn_project::{logical_path_key, normalize_logical_path};
pub use versioning::{
    ENGINE_VERSION, PROTOCOL_VERSION, SUBJECT_NAME, supported_capabilities, supported_profiles,
    supported_strictness,
};
pub use wire::{deserialize_from_str, serialize_to_string};

pub use diagnostic_conversion::render_diagnostic;

mod collection_state;
mod diagnostic_template;
mod editor_vocabulary;
mod execution;
mod execution_model;
mod execution_state;
mod execution_wire;
mod fault_injection;
mod lock_digest;
mod lock_operations;
mod lock_wire;
mod manifest_operations;
mod manifest_wire;
mod probes;
mod project_authority;
mod project_compile;
mod project_diagnostics;
mod project_operations;
mod project_packages;
mod project_profiles;
mod project_resource;
mod project_start;
mod recording_digest;
mod recording_options;
mod reference_vocabulary;
mod stepping;
pub use execution::{PreparedProgram, execute_prepared, execute_program, prepare_program};
pub use execution_model::{ExecuteRequest, ExecuteResponse, ExecutionLimits};
pub use fake_host::FakeHostProvider;

mod debug_model;
mod edit_session_operations;
mod edit_session_wire;
mod event_source;
mod execution_capture;
mod execution_prepare;
mod execution_resource;
mod execution_sources;
pub mod fake_host;
mod locale_operations;
mod lsp_operations;
mod negotiation;
mod program_view;
mod program_view_annotations;
mod program_view_effects;
mod program_view_kind;
mod program_view_members;
mod program_view_nominal;
mod program_view_operations;
mod program_view_relations;
mod program_view_tasks;
mod program_view_tokens;
mod program_view_tree;
mod program_view_values;
mod resources;
mod service_completion;
mod service_help;
mod service_help_card;
mod service_operations;
mod source_identity;
mod state_object_pages;
mod state_pages;
mod token_conversion;
mod typed_values;
pub use program_view_operations::analysis_program_view;
pub use resources::ApiSession;

mod event_binary;
mod event_codec;
mod event_task_codec;

#[cfg(feature = "native")]
mod native_build;
#[cfg(feature = "native")]
mod native_tasks;
#[cfg(feature = "native")]
pub use native_build::{NativeBuildFailure, NativeBuildRequest, NativeObject, build_native_object};

#[cfg(feature = "native")]
mod native_project_build;
#[cfg(feature = "native")]
pub use native_project_build::build_native_project_object;

#[cfg(feature = "native")]
mod native_benchmark;
#[cfg(feature = "native")]
pub use native_benchmark::{
    BenchmarkObject, PreparedNativeBenchmark, build_benchmark_object, emit_benchmark_object,
    inspect_benchmark_object, prepare_native_benchmark,
};

#[cfg(feature = "native")]
mod native_effects;
#[cfg(feature = "native")]
pub use native_effects::native_effect_input;
#[cfg(feature = "native")]
mod native_execution;
#[cfg(feature = "native")]
pub use native_execution::{
    NativeRunReport, conformance_build_request, native_execute_response,
    protocol_rejected_native_response, rejected_native_response,
};

mod recording;
mod state_changes;
pub mod tape_wire;

#[cfg(test)]
mod recording_digest_tests;

mod program_view_variants;

mod hosted_execution;
