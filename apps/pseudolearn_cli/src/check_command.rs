#![forbid(unsafe_code)]

use crate::confined_sources;
use crate::error::CliError;
use crate::messages::{format_diagnostic_line, missing_input};
use crate::options::CliOptions;
use pseudolearn_api::{
    AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, detect_vocabulary_profile, execute_analyze,
};
use serde_json::json;

pub fn execute_check(options: &CliOptions, paths: &[String]) -> Result<i32, CliError> {
    if paths.is_empty() {
        return Err(CliError::Usage(
            missing_input(&options.interface_language).to_owned(),
        ));
    }

    let sources = confined_sources::collect(paths, &options.interface_language)?;
    let mut json_files = Vec::new();
    let mut has_error = false;

    for source in &sources {
        let (file_has_error, json_representation) =
            check_source(options, &source.path, &source.text);
        if file_has_error {
            has_error = true;
        }
        if let Some(record) = json_representation {
            json_files.push(record);
        }
    }

    if options.json_output {
        let root = json!({ "files": json_files });
        println!("{root}");
    }

    if has_error { Ok(1) } else { Ok(0) }
}

fn check_source(
    options: &CliOptions,
    file_path: &str,
    content: &str,
) -> (bool, Option<serde_json::Value>) {
    let vocabulary = determine_vocabulary(options, content);
    let strictness = options.strictness.as_deref().unwrap_or("strict");
    let request = AnalyzeRequest {
        source: None,
        program: content.to_owned(),
        profile: vocabulary,
        strictness: strictness.to_owned(),
    };
    let response = execute_analyze(&request);
    let has_error = response
        .diagnostics
        .iter()
        .any(|entry| entry.severity == "error");

    if options.json_output {
        let json_representation = build_json_file(file_path, &response.diagnostics);
        (has_error, Some(json_representation))
    } else {
        render_diagnostics(file_path, &response, &options.interface_language);
        (has_error, None)
    }
}

fn determine_vocabulary(options: &CliOptions, content: &str) -> String {
    if let Some(explicit) = &options.vocabulary {
        return explicit.clone();
    }
    detect_vocabulary_profile(content)
        .unwrap_or("es")
        .to_owned()
}

fn render_diagnostics(file_path: &str, response: &AnalyzeResponse, interface_language: &str) {
    for diagnostic in &response.diagnostics {
        let (line, column) = (diagnostic.span.start.line, diagnostic.span.start.column);
        let formatted =
            format_diagnostic_line(interface_language, file_path, (line, column), diagnostic);
        print!("{formatted}");
    }
}

fn build_json_file(file_path: &str, diagnostics: &[ApiDiagnostic]) -> serde_json::Value {
    let converted: Vec<serde_json::Value> = diagnostics
        .iter()
        .map(|diagnostic| {
            let (start_line, start_col) =
                (diagnostic.span.start.line, diagnostic.span.start.column);
            let (end_line, end_col) = (diagnostic.span.end.line, diagnostic.span.end.column);
            json!({
                "code": diagnostic.code,
                "class": diagnostic.class,
                "severity": diagnostic.severity,
                "span": {
                    "start": { "line": start_line, "column": start_col },
                    "end": { "line": end_line, "column": end_col }
                },
                "related": diagnostic.related,
                "arguments": diagnostic.arguments
            })
        })
        .collect();
    json!({
        "path": file_path,
        "diagnostics": converted
    })
}
