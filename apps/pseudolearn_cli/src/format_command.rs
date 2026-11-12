#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{format_diagnostic_report, missing_input, unreadable_input};
use crate::options::{CliOptions, FormatAction};
use pseudolearn_api::service::{FormatOptions, Profile, format_source};
use pseudolearn_api::{AnalyzeRequest, detect_vocabulary_profile, execute_analyze};

const SYNTAX_CLASSES: [&str; 2] = ["lexical", "syntax"];

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
    let analysis_request = AnalyzeRequest {
        source: None,
        program: source_content.to_owned(),
        profile: vocabulary_name,
    };
    let analysis_outcome = execute_analyze(&analysis_request);
    let syntax_errors: Vec<_> = analysis_outcome
        .diagnostics
        .iter()
        .filter(|entry| entry.severity == "error" && SYNTAX_CLASSES.contains(&entry.class.as_str()))
        .collect();

    if !syntax_errors.is_empty() {
        for diagnostic_entry in syntax_errors {
            let rendered_line = format_diagnostic_report(
                &options.interface_language,
                target_path,
                Some(source_content),
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
    let formatting_options = FormatOptions {
        profile: active_profile,
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
