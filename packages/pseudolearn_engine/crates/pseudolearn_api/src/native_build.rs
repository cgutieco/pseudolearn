use crate::ApiDiagnostic;
use crate::execution_model::ExecutionLimits;
use pseudolearn_aot_rt::{AotLimits, BooleanWords, ExecutableSettings};
use pseudolearn_codegen::{TargetConfig, compile_module_to_executable_object};

#[derive(Clone, Debug)]
pub struct NativeBuildRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
    pub seed: i64,
    pub forced_collection: bool,
    pub limits: ExecutionLimits,
    pub source_name: String,
    pub source: Option<crate::ApiSourceIdentity>,
    pub locale: String,
    pub error_template: String,
    pub warning_template: String,
    pub information_template: String,
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
    let (module, warnings) = crate::ir_execution::compile_source_with_identity(
        &request.program,
        &request.profile,
        &request.strictness,
        request.source,
    )
    .map_err(NativeBuildFailure::Rejected)?;
    let compiled = compile_module_to_executable_object(
        &module,
        &TargetConfig::host(),
        &settings_of(request, &module),
    )
    .map_err(|error| NativeBuildFailure::Backend(error.to_string()))?;
    Ok(NativeObject {
        bytes: compiled.bytes,
        warnings,
    })
}

pub(crate) fn settings_of(
    request: &NativeBuildRequest,
    module: &pseudolearn_ir::Module,
) -> ExecutableSettings {
    let defaults = AotLimits::default();
    let (truth, falsity) = pseudolearn_vm::boolean_words(&request.profile);
    ExecutableSettings {
        source_name: request.source_name.clone(),
        locale: request.locale.clone(),
        seed: request.seed,
        forced_collection: request.forced_collection,
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
        site_boolean_words: site_boolean_words(module),
        error_template: request.error_template.clone(),
        warning_template: request.warning_template.clone(),
        information_template: request.information_template.clone(),
        exhausted_template: request.exhausted_template.clone(),
    }
}

fn site_boolean_words(module: &pseudolearn_ir::Module) -> Vec<BooleanWords> {
    if module.profiles.is_empty() {
        return Vec::new();
    }
    module
        .vocabularies()
        .into_iter()
        .map(|vocabulary| {
            let (truth, falsity) = pseudolearn_vm::boolean_words(vocabulary);
            BooleanWords {
                truth: truth.to_owned(),
                falsity: falsity.to_owned(),
            }
        })
        .collect()
}
