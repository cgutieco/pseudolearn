use crate::error::CliError;
use crate::messages;
use crate::native_linker::link_executable;
use crate::options::CliOptions;
use crate::run_command::render_diagnostics;
use pseudolearn_api::{
    ExecutionLimits, NativeBuildFailure, NativeBuildRequest, build_native_object,
    detect_vocabulary_profile,
};
use std::path::Path;

const SOURCE_EXTENSION: &str = "pseudo";

pub fn execute_build(options: &CliOptions) -> Result<i32, CliError> {
    let locale = &options.interface_language;
    let path = options
        .positional_arguments
        .first()
        .ok_or_else(|| CliError::Usage(messages::missing_input(locale).to_owned()))?;
    let source = std::fs::read_to_string(path)
        .map_err(|_| CliError::Operational(messages::unreadable_input(locale, path)))?;
    let output = options
        .output
        .clone()
        .unwrap_or_else(|| default_output(path));
    let request = build_request(options, path, source);
    let object = match build_native_object(&request) {
        Ok(object) => object,
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            render_diagnostics(options, path, &diagnostics);
            return Ok(1);
        }
        Err(NativeBuildFailure::Backend(_)) => return Err(linker_failure(locale)),
    };
    render_diagnostics(options, path, &object.warnings);
    link_executable(&object.bytes, Path::new(&output)).map_err(|_| linker_failure(locale))?;
    print!(
        "{}",
        messages::render("buildSucceeded", locale, &[("path", &output)])
    );
    Ok(0)
}

fn linker_failure(locale: &str) -> CliError {
    CliError::Operational(messages::render("linkerFailed", locale, &[]))
}

fn default_output(input: &str) -> String {
    let path = Path::new(input);
    let stem = path
        .file_stem()
        .and_then(|stem| stem.to_str())
        .unwrap_or("a");
    let suffix = std::env::consts::EXE_SUFFIX;
    let candidate = format!("{stem}{suffix}");
    let has_source_extension =
        path.extension().and_then(|extension| extension.to_str()) == Some(SOURCE_EXTENSION);
    if has_source_extension || candidate != input {
        candidate
    } else {
        format!("{stem}.out")
    }
}

fn build_request(options: &CliOptions, path: &str, source: String) -> NativeBuildRequest {
    let locale = &options.interface_language;
    let profile = options.vocabulary.clone().unwrap_or_else(|| {
        detect_vocabulary_profile(&source)
            .unwrap_or("es")
            .to_owned()
    });
    NativeBuildRequest {
        program: source,
        profile,
        strictness: options.strictness.clone().unwrap_or("strict".to_owned()),
        seed: options.execution.seed.unwrap_or(42),
        limits: ExecutionLimits {
            depth: options.execution.depth,
            statements: options.execution.statements,
            cells: options.execution.cells,
            micro_steps: None,
        },
        source_name: path.to_owned(),
        locale: locale.clone(),
        error_template: messages::template("diagnosticError", locale).to_owned(),
        exhausted_template: messages::template("inputExhausted", locale).to_owned(),
    }
}
