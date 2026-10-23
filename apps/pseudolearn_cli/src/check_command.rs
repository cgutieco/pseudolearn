#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{format_diagnostic_line, missing_input, unreadable_input};
use crate::options::CliOptions;
use pseudolearn_api::{
    AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, detect_vocabulary_profile, execute_analyze,
};
use serde_json::json;
use std::path::Path;

pub fn execute_check(options: &CliOptions, paths: &[String]) -> Result<i32, CliError> {
    if paths.is_empty() {
        return Err(CliError::Usage(
            missing_input(&options.interface_language).to_owned(),
        ));
    }

    let files_to_check = collect_files(paths, &options.interface_language)?;
    let mut json_files = Vec::new();
    let mut has_error = false;

    for file_path in &files_to_check {
        let (file_has_error, json_representation) = check_target_file(options, file_path)?;
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

fn check_target_file(
    options: &CliOptions,
    file_path: &str,
) -> Result<(bool, Option<serde_json::Value>), CliError> {
    let content = std::fs::read_to_string(file_path).map_err(|_| {
        CliError::Operational(unreadable_input(&options.interface_language, file_path))
    })?;
    let vocabulary = determine_vocabulary(options, &content);
    let strictness = options.strictness.as_deref().unwrap_or("strict");
    let request = AnalyzeRequest {
        source: None,
        program: content.clone(),
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
        Ok((has_error, Some(json_representation)))
    } else {
        render_diagnostics(file_path, &response, &options.interface_language);
        Ok((has_error, None))
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

fn collect_files(paths: &[String], locale: &str) -> Result<Vec<String>, CliError> {
    let mut collected = Vec::new();
    for target in paths {
        let path = Path::new(target);
        if path.is_file() {
            collected.push(target.clone());
        } else if path.is_dir() {
            let mut directory_files = Vec::new();
            discover_pseudo_files(path, target, &mut directory_files);
            directory_files.sort();
            collected.extend(directory_files);
        } else {
            return Err(CliError::Operational(unreadable_input(locale, target)));
        }
    }
    Ok(collected)
}

fn discover_pseudo_files(base_path: &Path, prefix: &str, output: &mut Vec<String>) {
    let Ok(entries) = std::fs::read_dir(base_path) else {
        return;
    };
    for entry_result in entries {
        let Ok(entry) = entry_result else {
            continue;
        };
        let Ok(file_type) = entry.file_type() else {
            continue;
        };
        let file_name = entry.file_name();
        let name_str = file_name.to_string_lossy();
        let child_prefix = format!("{prefix}/{name_str}");
        if file_type.is_dir() {
            discover_pseudo_files(&entry.path(), &child_prefix, output);
        } else if file_type.is_file() && name_str.ends_with(".pseudo") {
            output.push(child_prefix);
        }
    }
}
