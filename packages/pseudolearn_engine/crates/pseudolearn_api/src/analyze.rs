use crate::model::{AnalyzeRequest, AnalyzeResponse, ApiDiagnostic, ApiSpan};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticSeverity, render, sort_diagnostics};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::analyze_semantics;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;
use std::collections::BTreeMap;

pub fn execute_analyze(request: &AnalyzeRequest) -> AnalyzeResponse {
    let execution_result = std::panic::catch_unwind(|| perform_analysis(request));
    match execution_result {
        Ok(response) => response,
        Err(_) => fallback_internal_fault(),
    }
}

fn perform_analysis(request: &AnalyzeRequest) -> AnalyzeResponse {
    let profile = if request.profile.trim().to_lowercase() == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let is_strict = request.strictness.trim().to_lowercase() != "flexible";
    let source_text = SourceText::new(request.program.clone());
    let (syntax_tree, mut diagnostics) = parse_source(&source_text, profile);
    let (_, mut semantic_diagnostics) = analyze_semantics(&syntax_tree, &source_text, is_strict);
    diagnostics.append(&mut semantic_diagnostics);
    sort_diagnostics(&mut diagnostics);

    let locale = if profile == Profile::English {
        "en"
    } else {
        "es"
    };
    let api_diagnostics = convert_diagnostics(&diagnostics, locale);
    AnalyzeResponse::new(true, api_diagnostics)
}

fn convert_diagnostics(diagnostics: &[Diagnostic], locale: &str) -> Vec<ApiDiagnostic> {
    diagnostics
        .iter()
        .map(|diagnostic| {
            let severity_string = match diagnostic.severity {
                DiagnosticSeverity::Warning => "warning".to_owned(),
                DiagnosticSeverity::Information => "info".to_owned(),
                DiagnosticSeverity::Error => "error".to_owned(),
            };
            let span = ApiSpan {
                start: diagnostic.span.start,
                ending: diagnostic.span.ending,
            };
            let related_spans = diagnostic
                .related
                .iter()
                .map(|related_span| ApiSpan {
                    start: related_span.start,
                    ending: related_span.ending,
                })
                .collect();
            ApiDiagnostic {
                code: diagnostic.code.as_str().to_owned(),
                class: diagnostic.class.as_str().to_owned(),
                severity: severity_string,
                message: render(diagnostic, locale),
                span,
                arguments: diagnostic.arguments.clone(),
                related: related_spans,
            }
        })
        .collect()
}

fn fallback_internal_fault() -> AnalyzeResponse {
    let internal_fault = ApiDiagnostic {
        code: "internalFault".to_owned(),
        class: "internal".to_owned(),
        severity: "error".to_owned(),
        message: "Internal engine fault".to_owned(),
        span: ApiSpan {
            start: 0,
            ending: 0,
        },
        arguments: BTreeMap::new(),
        related: Vec::new(),
    };
    AnalyzeResponse::new(false, vec![internal_fault])
}

pub fn detect_vocabulary_profile(source: &str) -> Option<&'static str> {
    let clean = source.trim_start_matches('\u{FEFF}');
    let mut remainder = clean;
    loop {
        remainder = remainder.trim_start();
        if remainder.starts_with("//") {
            if let Some(next_line_index) = remainder.find('\n') {
                remainder = remainder.get(next_line_index..).unwrap_or("");
                continue;
            }
            return None;
        }
        if remainder.starts_with("/*") {
            if let Some(close_index) = remainder.find("*/") {
                remainder = remainder.get(close_index.saturating_add(2)..).unwrap_or("");
                continue;
            }
            return None;
        }
        break;
    }
    let first_word: String = remainder
        .chars()
        .take_while(|character| character.is_alphabetic() || *character == '_')
        .collect();
    if first_word.is_empty() {
        return None;
    }
    pseudolearn_lexicon::detect_opener(&first_word).map(|profile| profile.as_str())
}

pub fn line_and_column(source: &str, byte_offset: u32) -> (u32, u32) {
    let source_text = SourceText::new(source.to_owned());
    source_text.line_and_column(byte_offset)
}
