#![forbid(unsafe_code)]

pub mod analyze;
mod argument_conversion;
mod diagnostic_conversion;
pub mod errors;
pub mod ir_execution;
pub mod model;
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

mod execution;
mod execution_model;
mod execution_state;
mod execution_wire;
mod fault_injection;
mod probes;
mod recording_options;
mod stepping;
pub use execution::{PreparedProgram, execute_prepared, execute_program, prepare_program};
pub use execution_model::{ExecuteRequest, ExecuteResponse, ExecutionLimits};

mod execution_resource;
mod resources;
pub use resources::ApiSession;

mod event_codec;

mod native_build;
pub use native_build::{NativeBuildFailure, NativeBuildRequest, NativeObject, build_native_object};

mod recording;
mod state_changes;
