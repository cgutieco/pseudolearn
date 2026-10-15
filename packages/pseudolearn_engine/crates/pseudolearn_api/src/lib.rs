pub mod analyze;
mod diagnostic_conversion;
pub mod errors;
pub mod model;
pub mod versioning;
pub mod wire;

pub use analyze::{detect_vocabulary_profile, execute_analyze, line_and_column};
pub use errors::ApiError;
pub use model::{AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, ApiPosition, ApiSpan, ApiUnit};
pub use versioning::{
    ENGINE_VERSION, PROTOCOL_VERSION, SUBJECT_NAME, supported_capabilities, supported_profiles,
    supported_strictness,
};
pub use wire::{deserialize_from_str, serialize_to_string};

pub use diagnostic_conversion::render_diagnostic;
