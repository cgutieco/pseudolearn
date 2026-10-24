use crate::native_build::settings_of;
use crate::project_compile::{Outcome, compile};
use crate::{ExecutionLimits, NativeBuildFailure, NativeBuildRequest, NativeObject};
use pseudolearn_aot_rt::ExecutableSettings;
use pseudolearn_codegen::{TargetConfig, compile_module_to_executable_object};
use serde_json::Value;

pub fn build_native_project_object(
    arguments: &Value,
    request: &NativeBuildRequest,
    source_names: &[(u32, String)],
) -> Result<NativeObject, NativeBuildFailure> {
    let attempt = || build(arguments, (request, source_names));
    match std::panic::catch_unwind(std::panic::AssertUnwindSafe(attempt)) {
        Ok(outcome) => outcome,
        Err(_) => Err(NativeBuildFailure::Backend(
            "internal fault while generating code".to_owned(),
        )),
    }
}

fn build(
    arguments: &Value,
    (request, source_names): (&NativeBuildRequest, &[(u32, String)]),
) -> Result<NativeObject, NativeBuildFailure> {
    let compiled = match compile(arguments) {
        Ok(Outcome::Compiled(compiled)) => compiled,
        Ok(Outcome::Failed(failure)) => return Err(NativeBuildFailure::ProjectRejected(failure)),
        Err(error) => return Err(NativeBuildFailure::Backend(format!("{error:?}"))),
    };
    let mut effective = request.clone();
    effective.limits = merged(&request.limits, &compiled.limits);
    let object = compile_module_to_executable_object(
        &compiled.module,
        &TargetConfig::host(),
        &ExecutableSettings {
            source_names: source_names.to_vec(),
            ..settings_of(&effective, &compiled.module)
        },
    )
    .map_err(|error| NativeBuildFailure::Backend(error.to_string()))?;
    Ok(NativeObject {
        bytes: object.bytes,
        warnings: compiled.warnings,
    })
}

fn merged(requested: &ExecutionLimits, manifest: &ExecutionLimits) -> ExecutionLimits {
    ExecutionLimits {
        depth: requested.depth.or(manifest.depth),
        statements: requested.statements.or(manifest.statements),
        cells: requested.cells.or(manifest.cells),
        micro_steps: requested.micro_steps.or(manifest.micro_steps),
    }
}
