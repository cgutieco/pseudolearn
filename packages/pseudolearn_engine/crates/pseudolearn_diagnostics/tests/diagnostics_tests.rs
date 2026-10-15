use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, render, sort_diagnostics};
use pseudolearn_source::Span;

#[test]
fn renders_bilingual_template_with_arguments() {
    let diagnostic = Diagnostic::new(DiagnosticCode::ArgumentCountMismatch, Span::new(0, 5))
        .with_number("expected", 2_u32)
        .with_number("found", 1_u32);
    let spanish = render(&diagnostic, "es");
    assert!(spanish.contains("esperaban 2"));
    assert!(spanish.contains("encontraron 1"));
    let english = render(&diagnostic, "en");
    assert!(english.contains("expected 2"));
    assert!(english.contains("found 1"));
}

#[test]
fn sorts_diagnostics_by_span_and_code() {
    let mut collection = vec![
        Diagnostic::new(DiagnosticCode::UndeclaredVariable, Span::new(10, 20)),
        Diagnostic::new(DiagnosticCode::UnexpectedBlockEnd, Span::new(0, 5)),
        Diagnostic::new(
            DiagnosticCode::DuplicateVariableDeclaration,
            Span::new(0, 5),
        ),
    ];
    sort_diagnostics(&mut collection);
    assert_eq!(
        collection.first().map(|d| d.code),
        Some(DiagnosticCode::DuplicateVariableDeclaration)
    );
    assert_eq!(
        collection.last().map(|d| d.code),
        Some(DiagnosticCode::UndeclaredVariable)
    );
}
