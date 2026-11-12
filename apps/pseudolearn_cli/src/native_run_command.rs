use crate::{error::CliError, messages, native_cache::ExecutableCache, options::CliOptions};
use pseudolearn_api::ExecuteRequest;
use serde_json::{Value, json};
use std::io::{Read, Write};

#[cfg(test)]
#[path = "native_run_command_tests.rs"]
mod native_run_command_tests;

pub(crate) fn execute_native(
    options: &CliOptions,
    path: &str,
    mut request: ExecuteRequest,
) -> Result<i32, CliError> {
    if options.execution.trace {
        return Err(CliError::Usage(messages::invalid_option_value(
            &options.interface_language,
            "--native",
            "--trace",
        )));
    }
    request.inputs = read_input_lines()?;
    let mut cache = ExecutableCache::create().map_err(operational)?;
    let directory = match &options.execution.working_directory {
        Some(directory) => std::path::PathBuf::from(directory),
        None => std::env::current_dir().map_err(operational)?,
    };
    let launch = crate::native_run::NativeLaunch {
        seed: request.seed,
        program_arguments: options.execution.program_arguments.clone(),
        program_directory: Some(directory),
    };
    let (response, requested_exit) =
        crate::aot_adapter::execute_natively_with_exit(&request, &mut cache, &launch);
    let document = serde_json::to_value(&response).map_err(operational)?;
    present(options, path, &response.output, &document)?;
    if let Some(target) = &options.execution.record_tape {
        crate::tape_files::persist(target, &document)?;
    }
    Ok(process_exit_code(&document, requested_exit))
}

pub(crate) fn process_exit_code(document: &Value, requested_exit: u8) -> i32 {
    let completed = document
        .pointer("/termination/kind")
        .and_then(Value::as_str)
        == Some("completed");
    if completed {
        i32::from(requested_exit)
    } else {
        1
    }
}

fn present(
    options: &CliOptions,
    path: &str,
    output: &str,
    document: &Value,
) -> Result<(), CliError> {
    if options.json_output {
        println!("{document}");
        return Ok(());
    }
    print!("{output}");
    std::io::stdout().flush().map_err(operational)?;
    let diagnostics: Vec<pseudolearn_api::ApiDiagnostic> =
        serde_json::from_value(document.get("diagnostics").cloned().unwrap_or(json!([])))
            .map_err(operational)?;
    crate::run_command::render_diagnostics(options, path, &diagnostics);
    Ok(())
}

fn read_input_lines() -> Result<Vec<String>, CliError> {
    let mut text = String::new();
    std::io::stdin()
        .read_to_string(&mut text)
        .map_err(operational)?;
    Ok(text.lines().map(str::to_owned).collect())
}

fn operational(error: impl std::fmt::Display) -> CliError {
    CliError::Operational(error.to_string())
}
