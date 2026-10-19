#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{format_diagnostic_line, missing_input, unreadable_input};
use crate::options::{CliOptions, FormatAction};
use pseudolearn_api::service::{FormatOptions, Profile, format_source};
use pseudolearn_api::{AnalyzeRequest, detect_vocabulary_profile, execute_analyze};

pub fn execute_format(options: &CliOptions) -> Result<i32, CliError> {
    if options.positional_arguments.is_empty() {
        return Err(CliError::Usage(
            missing_input(&options.interface_language).to_owned(),
        ));
    }

    let mut had_formatting_diff = false;

    for target_path in &options.positional_arguments {
        let source_content = std::fs::read_to_string(target_path).map_err(|_| {
            CliError::Usage(unreadable_input(&options.interface_language, target_path))
        })?;

        let syntax_code = check_syntax(options, target_path, &source_content);
        if syntax_code != 0 {
            return Ok(syntax_code);
        }

        let formatted_content = produce_formatted_source(options, &source_content);
        if apply_formatting_action(options, target_path, &source_content, &formatted_content)? {
            had_formatting_diff = true;
        }
    }

    if had_formatting_diff { Ok(1) } else { Ok(0) }
}

fn apply_formatting_action(
    options: &CliOptions,
    target_path: &str,
    source_content: &str,
    formatted_content: &str,
) -> Result<bool, CliError> {
    match options.format_action {
        FormatAction::CheckOnly => {
            if formatted_content != source_content {
                let notification =
                    format_required_message(&options.interface_language, target_path);
                eprint!("{notification}");
                return Ok(true);
            }
        }
        FormatAction::WriteInPlace => {
            std::fs::write(target_path, formatted_content).map_err(|_| {
                CliError::Operational(unreadable_input(&options.interface_language, target_path))
            })?;
            println!("{target_path}");
        }
        FormatAction::Print => {
            print!("{formatted_content}");
        }
    }
    Ok(false)
}

fn check_syntax(options: &CliOptions, target_path: &str, source_content: &str) -> i32 {
    let vocabulary_name = options
        .vocabulary
        .clone()
        .unwrap_or_else(|| determine_vocabulary(source_content));
    let strictness_mode = options.strictness.as_deref().unwrap_or("flexible");
    let analysis_request = AnalyzeRequest {
        program: source_content.to_owned(),
        profile: vocabulary_name,
        strictness: strictness_mode.to_owned(),
    };
    let analysis_outcome = execute_analyze(&analysis_request);
    let has_fatal_errors = analysis_outcome
        .diagnostics
        .iter()
        .any(|entry| entry.severity == "error");

    if has_fatal_errors {
        for diagnostic_entry in &analysis_outcome.diagnostics {
            let coordinate = (
                diagnostic_entry.span.start.line,
                diagnostic_entry.span.start.column,
            );
            let rendered_line = format_diagnostic_line(
                &options.interface_language,
                target_path,
                coordinate,
                diagnostic_entry,
            );
            eprint!("{rendered_line}");
        }
        return 1;
    }

    0
}

fn determine_vocabulary(source_content: &str) -> String {
    detect_vocabulary_profile(source_content)
        .unwrap_or("es")
        .to_owned()
}

fn produce_formatted_source(options: &CliOptions, source_content: &str) -> String {
    let vocabulary_name = options
        .vocabulary
        .clone()
        .unwrap_or_else(|| determine_vocabulary(source_content));
    let active_profile = if vocabulary_name == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let strictness_flag = options.strictness.as_deref().unwrap_or("strict") == "strict";
    let formatting_options = FormatOptions {
        profile: active_profile,
        strict: strictness_flag,
        indent_size: 2,
    };
    format_source(source_content, formatting_options)
}

fn format_required_message(locale: &str, target_path: &str) -> String {
    if locale == "en" {
        format!("pseudo: file requires formatting: {target_path}\n")
    } else {
        format!("pseudo: el archivo requiere formateo: {target_path}\n")
    }
}
