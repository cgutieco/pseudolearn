#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{format_diagnostic_line, missing_input, unreadable_input};
use crate::options::{CliOptions, FormatAction};
use pseudolearn_api::service::{Profile, TranslationError, translate_source};
use pseudolearn_api::{
    AnalyzeRequest, ApiDiagnostic, ApiPosition, ApiSpan, detect_vocabulary_profile, execute_analyze,
};
use std::collections::BTreeMap;

pub fn execute_translate(options: &CliOptions) -> Result<i32, CliError> {
    let target_path = options
        .positional_arguments
        .first()
        .ok_or_else(|| CliError::Usage(missing_input(&options.interface_language).to_owned()))?;

    let destination_name = options
        .target_profile
        .as_deref()
        .ok_or_else(|| CliError::Usage(missing_target_option(&options.interface_language)))?;

    let source_content = std::fs::read_to_string(target_path)
        .map_err(|_| CliError::Usage(unreadable_input(&options.interface_language, target_path)))?;

    let target_profile = if destination_name == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let strictness_flag = options.strictness.as_deref().unwrap_or("strict") == "strict";

    match translate_source(&source_content, target_profile, strictness_flag) {
        Ok(translated_content) => {
            write_translation_output(options, target_path, &translated_content)?;
            Ok(0)
        }
        Err(TranslationError::Collision { identifier, .. }) => {
            emit_collision_diagnostic(options, target_path, &source_content, &identifier);
            Ok(1)
        }
        Err(TranslationError::ParseFailure(_)) => {
            emit_parse_diagnostics(options, target_path, &source_content);
            Ok(1)
        }
    }
}

fn emit_collision_diagnostic(
    options: &CliOptions,
    target_path: &str,
    source_content: &str,
    identifier: &str,
) {
    let (line, column) = find_identifier_coordinates(source_content, identifier);
    let mut arguments = BTreeMap::new();
    arguments.insert(
        String::from("lexeme"),
        serde_json::Value::String(identifier.to_owned()),
    );
    arguments.insert(
        String::from("token"),
        serde_json::Value::String(identifier.to_owned()),
    );
    let diagnostic = ApiDiagnostic {
        code: String::from("reservedLexemeUsedAsName"),
        class: String::from("syntax"),
        severity: String::from("error"),
        message: String::new(),
        span: ApiSpan {
            start: ApiPosition { line, column },
            end: ApiPosition { line, column },
        },
        arguments,
        related: Vec::new(),
    };
    let rendered_line = format_diagnostic_line(
        &options.interface_language,
        target_path,
        (line, column),
        &diagnostic,
    );
    eprint!("{rendered_line}");
}

fn find_identifier_coordinates(source_content: &str, identifier: &str) -> (u32, u32) {
    for (line_index, line) in source_content.lines().enumerate() {
        if let Some(col) = line.find(identifier) {
            let line_number = u32::try_from(line_index.saturating_add(1)).unwrap_or(1);
            let column_number = u32::try_from(col.saturating_add(1)).unwrap_or(1);
            return (line_number, column_number);
        }
    }
    (1, 1)
}

fn write_translation_output(
    options: &CliOptions,
    target_path: &str,
    translated_content: &str,
) -> Result<(), CliError> {
    if let Some(destination_path) = &options.output {
        std::fs::write(destination_path, translated_content).map_err(|_| {
            CliError::Operational(unreadable_input(
                &options.interface_language,
                destination_path,
            ))
        })?;
    } else if options.format_action == FormatAction::WriteInPlace {
        std::fs::write(target_path, translated_content).map_err(|_| {
            CliError::Operational(unreadable_input(&options.interface_language, target_path))
        })?;
    } else {
        print!("{translated_content}");
    }
    Ok(())
}

fn emit_parse_diagnostics(options: &CliOptions, target_path: &str, source_content: &str) {
    let vocabulary_name = options.vocabulary.clone().unwrap_or_else(|| {
        detect_vocabulary_profile(source_content)
            .unwrap_or("es")
            .to_owned()
    });
    let analysis_request = AnalyzeRequest {
        program: source_content.to_owned(),
        profile: vocabulary_name,
        strictness: String::from("strict"),
    };
    let analysis_outcome = execute_analyze(&analysis_request);
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
}

fn missing_target_option(locale: &str) -> String {
    if locale == "en" {
        String::from("pseudo: missing required option --to (--hacia)\n")
    } else {
        String::from("pseudo: falta la opción requerida --hacia (--to)\n")
    }
}
