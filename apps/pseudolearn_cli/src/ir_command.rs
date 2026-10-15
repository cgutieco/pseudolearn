#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{format_diagnostic_line, missing_input, unreadable_input};
use crate::options::CliOptions;
use pseudolearn_api::{compile_source_to_ir, detect_vocabulary_profile};

pub fn execute_ir(options: &CliOptions, paths: &[String]) -> Result<i32, CliError> {
    let Some(file_path) = paths.first() else {
        return Err(CliError::Usage(
            missing_input(&options.interface_language).to_owned(),
        ));
    };
    let content = std::fs::read_to_string(file_path).map_err(|_| {
        CliError::Operational(unreadable_input(&options.interface_language, file_path))
    })?;
    let vocabulary = determine_vocabulary(options, &content);
    let strictness = options.strictness.as_deref().unwrap_or("strict");

    match compile_source_to_ir(&content, &vocabulary, strictness) {
        Ok(canonical_ir) => {
            print!("{canonical_ir}");
            Ok(0)
        }
        Err(diagnostics) => {
            render_error_diagnostics(file_path, &diagnostics, &options.interface_language);
            Ok(1)
        }
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

fn render_error_diagnostics(
    file_path: &str,
    diagnostics: &[pseudolearn_api::ApiDiagnostic],
    interface_language: &str,
) {
    for diagnostic in diagnostics {
        let (line_number, column_number) =
            (diagnostic.span.start.line, diagnostic.span.start.column);
        let formatted = format_diagnostic_line(
            interface_language,
            file_path,
            (line_number, column_number),
            diagnostic,
        );
        eprint!("{formatted}");
    }
}
