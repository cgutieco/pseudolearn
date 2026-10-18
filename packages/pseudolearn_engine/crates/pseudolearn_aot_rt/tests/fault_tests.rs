use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;

fn record(code: Option<DiagnosticCode>) -> FaultRecord {
    FaultRecord {
        site: 0,
        code,
        range: SourceRange::default(),
        arguments: Vec::new(),
    }
}

#[test]
fn a_fault_renders_in_the_requested_locale() {
    let spanish = render_fault(&record(Some(DiagnosticCode::DivisionByZero)), "es");
    let english = render_fault(&record(Some(DiagnosticCode::DivisionByZero)), "en");
    assert!(spanish.as_deref().is_some_and(|text| !text.is_empty()));
    assert!(english.as_deref().is_some_and(|text| !text.is_empty()));
    assert_ne!(spanish, english);
}

#[test]
fn arguments_are_substituted_into_the_template() {
    let mut mismatch = record(Some(DiagnosticCode::ReadValueTypeMismatch));
    mismatch.arguments = vec![
        ("expected".to_owned(), "Entero".to_owned()),
        ("found".to_owned(), "abc".to_owned()),
    ];
    let text = render_fault(&mismatch, "es").unwrap_or_default();
    assert!(text.contains("abc"));
    assert!(text.contains("Entero"));
}

#[test]
fn input_exhaustion_has_no_diagnostic_to_render() {
    assert_eq!(render_fault(&record(None), "es"), None);
}
