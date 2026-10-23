use pseudolearn_api::{AnalyzeRequest, execute_analyze, render_diagnostic};

#[test]
fn suppresses_semantics_after_syntax_errors() {
    let request = AnalyzeRequest {
        program: "algorithm Entry\ndefine as integer;\nwrite absent;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    };
    let response = execute_analyze(&request);
    assert!(response.tree);
    assert!(
        response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "expectedIdentifierInDeclaration")
    );
    assert!(
        !response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.class == "semantic")
    );
}

#[test]
fn exposes_positions_with_independent_presentation_language() -> Result<(), String> {
    let response = execute_analyze(&AnalyzeRequest {
        program: "algorithm Entry\nwrite @;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    });
    let diagnostic = response.diagnostics.first().ok_or("Missing diagnostic")?;
    assert_eq!(diagnostic.span.start.line, 2);
    assert_eq!(diagnostic.span.start.column, 7);
    assert!(render_diagnostic(diagnostic, "es").contains("Carácter"));
    assert!(render_diagnostic(diagnostic, "en").contains("character"));
    assert_eq!(
        response.schema.first().map(|unit| unit.name.as_str()),
        Some("Entry")
    );
    Ok(())
}

#[test]
fn exposes_lexical_tokens_in_source_order_with_unicode_positions() -> Result<(), String> {
    let response = execute_analyze(&AnalyzeRequest {
        program: "Algoritmo P\n// ñ\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    });
    let comment = response
        .tokens
        .iter()
        .find(|token| token.kind == "comment")
        .ok_or("Missing comment token")?;
    assert_eq!(comment.span.start.line, 2);
    assert_eq!(comment.span.start.column, 1);
    assert_eq!(comment.span.end.line, 2);
    assert_eq!(comment.span.end.column, 5);
    assert_eq!(
        response
            .tokens
            .first()
            .map(|token| token.keyword.as_deref()),
        Some(Some("algorithm"))
    );
    Ok(())
}

#[test]
fn retains_lexical_tokens_after_syntax_errors() {
    let response = execute_analyze(&AnalyzeRequest {
        program: "Algoritmo P\n@\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    });
    assert!(!response.diagnostics.is_empty());
    assert!(
        response
            .tokens
            .iter()
            .any(|token| token.kind == "invalid_character")
    );
}
