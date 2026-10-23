use crate::model::{AnalyzeRequest, AnalyzeResponse};
use pseudolearn_diagnostics::{DiagnosticCode, sort_diagnostics};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;

pub fn execute_analyze(request: &AnalyzeRequest) -> AnalyzeResponse {
    std::panic::catch_unwind(|| perform_analysis(request))
        .unwrap_or_else(|_| crate::diagnostic_conversion::internal_fault())
}

fn perform_analysis(request: &AnalyzeRequest) -> AnalyzeResponse {
    let profile = Profile::from_name(&request.profile).unwrap_or(Profile::Spanish);
    let strict = request.strictness != "flexible";
    let source = crate::source_identity::source_text(request.program.clone(), request.source);
    let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let (tree, mut diagnostics) = parse_source_with_terminator(&source, profile, terminator);
    if !tree.has_errors {
        let (_, mut semantic) =
            analyze_with_options(&tree, &source, SemanticOptions { profile, strict });
        diagnostics.append(&mut semantic);
    }
    sort_diagnostics(&mut diagnostics);
    let converted = diagnostics
        .iter()
        .map(|diagnostic| {
            crate::diagnostic_conversion::convert(diagnostic, &source, profile.as_str())
        })
        .collect();
    let tokens = crate::token_conversion::convert(&tree, &source);
    let mut response = AnalyzeResponse::new(true, converted, tokens);
    response.schema = crate::diagnostic_conversion::schema(&tree, &source);
    response
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
