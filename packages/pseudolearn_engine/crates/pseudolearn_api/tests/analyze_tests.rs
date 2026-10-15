use pseudolearn_api::{AnalyzeRequest, execute_analyze, render_diagnostic};

#[test]
fn suppresses_semantics_after_syntax_errors() {
    let request = AnalyzeRequest {
        program: "algorithm Entry\ndefine as integer;\nwrite absent;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
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
