use crate::error::CliError;
use crate::messages;
use crate::options::CliOptions;
use crate::run_command::render_diagnostics;
use pseudolearn_api::{
    NativeBuildFailure, NativeBuildRequest, build_native_object, detect_vocabulary_profile,
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
    let target =
        crate::native_build_target::requested_target(options.native_target.as_deref(), locale)?;
    let output = options.output.clone().unwrap_or_else(|| {
        default_output(path, crate::native_build_target::executable_suffix(target))
    });
    let request = build_request(options, path, source);
    let object = match build_native_object(&request) {
        Ok(object) => object,
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            render_diagnostics(options, path, &diagnostics);
            return Ok(1);
        }
        Err(NativeBuildFailure::Backend(_) | NativeBuildFailure::ProjectRejected(_)) => {
            return Err(linker_failure(locale));
        }
    };
    render_diagnostics(options, path, &object.warnings);
    crate::native_linker::link_for_target(target, &object.bytes, Path::new(&output))
        .map_err(|failure| crate::native_build_target::link_failure(locale, &failure))?;
    print!(
        "{}",
        messages::render("buildSucceeded", locale, &[("path", &output)])
    );
    Ok(0)
}

fn linker_failure(locale: &str) -> CliError {
    CliError::Operational(messages::render("linkerFailed", locale, &[]))
}

fn default_output(input: &str, suffix: &str) -> String {
    let path = Path::new(input);
    let stem = path
        .file_stem()
        .and_then(|stem| stem.to_str())
        .unwrap_or("a");
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
        source: None,
        program: source,
        profile,
        forced_collection: false,
        limits: options.execution.limits(),
        source_name: path.to_owned(),
        locale: locale.clone(),
        error_template: messages::template("diagnosticError", locale).to_owned(),
        warning_template: messages::template("diagnosticWarning", locale).to_owned(),
        information_template: messages::template("diagnosticInfo", locale).to_owned(),
        exhausted_template: messages::template("inputExhausted", locale).to_owned(),
        target: options.native_target.clone(),
    }
}
