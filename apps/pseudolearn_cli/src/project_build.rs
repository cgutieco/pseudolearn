use crate::error::CliError;
use crate::messages;
use crate::options::CliOptions;
use crate::project_report::{Stream, render};
use crate::project_session::prepare;
use pseudolearn_api::{NativeBuildFailure, NativeBuildRequest, build_native_project_object};
use std::path::Path;

pub fn execute_build(options: &CliOptions) -> Result<i32, CliError> {
    let locale = &options.interface_language;
    let target =
        crate::native_build_target::requested_target(options.native_target.as_deref(), locale)?;
    let prepared = prepare(options, true)?;
    let output = options.output.clone().unwrap_or_else(|| {
        default_output(
            options.project.entry.as_deref().unwrap_or("a"),
            crate::native_build_target::executable_suffix(target),
        )
    });
    let request = build_request(options);
    let names: Vec<(u32, String)> = prepared
        .snapshot
        .sources
        .iter()
        .map(|source| (source.source_id, source.display.clone()))
        .collect();
    let object = match build_native_project_object(&prepared.arguments, &request, &names) {
        Ok(object) => object,
        Err(NativeBuildFailure::ProjectRejected(failure)) => {
            render(options, &prepared.snapshot, (&failure, Stream::Error));
            return Ok(1);
        }
        Err(_) => return Err(linker_failure(locale)),
    };
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

fn default_output(entry: &str, suffix: &str) -> String {
    let stem = entry.rsplit('/').next().unwrap_or("a");
    format!("{stem}{suffix}")
}

fn build_request(options: &CliOptions) -> NativeBuildRequest {
    let locale = &options.interface_language;
    NativeBuildRequest {
        source: None,
        program: String::new(),
        profile: options
            .vocabulary
            .clone()
            .unwrap_or_else(|| "es".to_owned()),
        forced_collection: false,
        limits: options.execution.limits(),
        source_name: "project".to_owned(),
        locale: locale.clone(),
        error_template: messages::template("diagnosticError", locale).to_owned(),
        warning_template: messages::template("diagnosticWarning", locale).to_owned(),
        information_template: messages::template("diagnosticInfo", locale).to_owned(),
        exhausted_template: messages::template("inputExhausted", locale).to_owned(),
        target: options.native_target.clone(),
    }
}
