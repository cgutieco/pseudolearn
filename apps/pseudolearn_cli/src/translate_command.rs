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
        Err(TranslationError::Collision {
            identifier, span, ..
        }) => {
            let offset = usize::try_from(span.start).unwrap_or(0);
            let coordinates = line_and_column(&source_content, offset);
            emit_collision_diagnostic(options, target_path, coordinates, &identifier);
            Ok(1)
        }
        Err(TranslationError::ParseFailure(_)) => {
            emit_parse_diagnostics(options, target_path, &source_content);
            Ok(1)
        }
    }
}

fn collision_diagnostic(coordinates: (u32, u32), identifier: &str) -> ApiDiagnostic {
    let (line, column) = coordinates;
    let word = serde_json::Value::String(identifier.to_owned());
    let arguments = BTreeMap::from([
        (String::from("lexeme"), word.clone()),
        (String::from("token"), word),
    ]);
    let width = u32::try_from(identifier.chars().count()).unwrap_or(0);
    ApiDiagnostic {
        code: String::from("reservedLexemeUsedAsName"),
        class: String::from("syntax"),
        severity: String::from("error"),
        message: String::new(),
        span: ApiSpan {
            start: ApiPosition { line, column },
            end: ApiPosition {
                line,
                column: column.saturating_add(width),
            },
        },
        arguments,
        related: Vec::new(),
    }
}

fn emit_collision_diagnostic(
    options: &CliOptions,
    target_path: &str,
    coordinates: (u32, u32),
    identifier: &str,
) {
    let diagnostic = collision_diagnostic(coordinates, identifier);
    let rendered_line = format_diagnostic_line(
        &options.interface_language,
        target_path,
        coordinates,
        &diagnostic,
    );
    eprint!("{rendered_line}");
}

fn line_and_column(text: &str, offset: usize) -> (u32, u32) {
    let head = text.get(..offset.min(text.len())).unwrap_or("");
    let line = head.matches('\n').count().saturating_add(1);
    let line_start = head.rfind('\n').map_or(0, |index| index.saturating_add(1));
    let column = head
        .get(line_start..)
        .unwrap_or("")
        .chars()
        .count()
        .saturating_add(1);
    (
        u32::try_from(line).unwrap_or(1),
        u32::try_from(column).unwrap_or(1),
    )
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
