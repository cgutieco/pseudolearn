use pseudolearn_diagnostics::{Diagnostic, DiagnosticArgument, DiagnosticCode, render};
use pseudolearn_source::Span;

fn uninitialized(cause: &str) -> Diagnostic {
    let mut diagnostic =
        Diagnostic::new(DiagnosticCode::VariableUsedUninitialized, Span::new(0, 1))
            .with_argument("lexeme", "x");
    diagnostic.arguments.insert(
        "cause".to_owned(),
        DiagnosticArgument::Term(cause.to_owned()),
    );
    diagnostic
}

#[test]
fn presents_a_listed_term_with_the_text_of_each_locale() {
    let diagnostic = uninitialized("branchWithoutElse");
    let spanish = render(&diagnostic, "es");
    let english = render(&diagnostic, "en");
    assert!(
        spanish.contains("(causa: una condición sin rama alternativa puede dejarla sin valor)"),
        "{spanish}"
    );
    assert!(
        english.contains(
            "(cause: a condition without an alternative branch may leave it without a value)"
        ),
        "{english}"
    );
    assert!(!spanish.contains("branchWithoutElse") && !english.contains("branchWithoutElse"));
}

#[test]
fn keeps_the_term_in_the_argument() {
    let diagnostic = uninitialized("loopMayNotRun");
    let _ = render(&diagnostic, "es");
    assert_eq!(
        diagnostic.arguments.get("cause"),
        Some(&DiagnosticArgument::Term("loopMayNotRun".to_owned()))
    );
}

#[test]
fn presents_an_unlisted_term_as_is() {
    let diagnostic = uninitialized("unknownCause");
    assert!(render(&diagnostic, "es").contains("(causa: unknownCause)"));
    assert!(render(&diagnostic, "en").contains("(cause: unknownCause)"));
}

#[test]
fn does_not_translate_a_lexeme_equal_to_a_term() {
    let diagnostic = Diagnostic::new(DiagnosticCode::VariableUsedUninitialized, Span::new(0, 1))
        .with_argument("lexeme", "noAssignment")
        .with_argument("cause", "noAssignment");
    let spanish = render(&diagnostic, "es");
    assert!(
        spanish.starts_with("La variable noAssignment "),
        "{spanish}"
    );
}
