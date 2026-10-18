use crate::ApiDiagnostic;
use crate::execution_model::ExecutionLimits;
use crate::ir_execution::compile_source_with_warnings;
use pseudolearn_aot_rt::{AotLimits, BooleanWords, ExecutableSettings};
use pseudolearn_codegen::{TargetConfig, compile_module_to_executable_object};

#[derive(Clone, Debug)]
pub struct NativeBuildRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
    pub seed: i64,
    pub limits: ExecutionLimits,
    pub source_name: String,
    pub locale: String,
    pub error_template: String,
    pub exhausted_template: String,
}

#[derive(Debug)]
pub struct NativeObject {
    pub bytes: Vec<u8>,
    pub warnings: Vec<ApiDiagnostic>,
}

#[derive(Debug)]
pub enum NativeBuildFailure {
    Rejected(Vec<ApiDiagnostic>),
    Backend(String),
}

pub fn build_native_object(
    request: &NativeBuildRequest,
) -> Result<NativeObject, NativeBuildFailure> {
    match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| build(request))) {
        Ok(outcome) => outcome,
        Err(_) => Err(NativeBuildFailure::Backend(
            "internal fault while generating code".to_owned(),
        )),
    }
}

fn build(request: &NativeBuildRequest) -> Result<NativeObject, NativeBuildFailure> {
    let (module, warnings) =
        compile_source_with_warnings(&request.program, &request.profile, &request.strictness)
            .map_err(NativeBuildFailure::Rejected)?;
    let compiled =
        compile_module_to_executable_object(&module, &TargetConfig::host(), &settings_of(request))
            .map_err(|error| NativeBuildFailure::Backend(error.to_string()))?;
    Ok(NativeObject {
        bytes: compiled.bytes,
        warnings,
    })
}

fn settings_of(request: &NativeBuildRequest) -> ExecutableSettings {
    let defaults = AotLimits::default();
    let (truth, falsity) = pseudolearn_vm::boolean_words(&request.profile);
    ExecutableSettings {
        source_name: request.source_name.clone(),
        locale: request.locale.clone(),
        seed: request.seed,
        limits: AotLimits {
            frames: request
                .limits
                .depth
                .and_then(|depth| u32::try_from(depth).ok())
                .unwrap_or(defaults.frames),
            instruction_units: request.limits.statements,
            cells: request.limits.cells.unwrap_or(defaults.cells),
            root_capacity: defaults.root_capacity,
        },
        boolean_words: BooleanWords {
            truth: truth.to_owned(),
            falsity: falsity.to_owned(),
        },
        error_template: request.error_template.clone(),
        exhausted_template: request.exhausted_template.clone(),
    }
}
