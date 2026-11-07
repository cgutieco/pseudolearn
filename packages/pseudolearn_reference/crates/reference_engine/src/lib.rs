#![forbid(unsafe_code)]

mod execution;
mod offsets;
mod tokens;

use reference_model::{CodeEngine, ExecutionReport, ExecutionRequest, Profile, RawToken};

#[derive(Clone, Copy, Debug, Default)]
pub struct ApiEngine;

impl CodeEngine for ApiEngine {
    fn tokenize(&self, code: &str, profile: Profile) -> Vec<RawToken> {
        tokens::tokenize(code, profile)
    }

    fn translate(&self, code: &str, target: Profile) -> Result<String, String> {
        let destination = match target {
            Profile::Spanish => pseudolearn_api::service::Profile::Spanish,
            Profile::English => pseudolearn_api::service::Profile::English,
        };
        pseudolearn_api::service::translate_source(code, destination)
            .map_err(|error| format!("{error:?}"))
    }

    fn execute(&self, request: &ExecutionRequest) -> ExecutionReport {
        execution::execute(request)
    }

    fn intermediate(&self, code: &str, profile: Profile) -> Result<String, String> {
        pseudolearn_api::compile_source_to_ir(code, profile.code()).map_err(|diagnostics| {
            diagnostics
                .iter()
                .map(|diagnostic| diagnostic.code.clone())
                .collect::<Vec<_>>()
                .join(", ")
        })
    }

    fn fingerprint(&self) -> String {
        format!(
            "{}+{}",
            pseudolearn_api::ENGINE_VERSION,
            pseudolearn_api::PROTOCOL_VERSION
        )
    }
}
