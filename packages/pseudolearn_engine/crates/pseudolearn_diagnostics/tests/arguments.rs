use pseudolearn_diagnostics::{
    ArgumentKind, Diagnostic, DiagnosticArgument, DiagnosticCode, render, validate_arguments,
};
use pseudolearn_source::Span;

#[test]
fn preserves_numeric_arguments_and_rejects_text_substitutes_or_missing_keys() -> Result<(), String>
{
    let valid = Diagnostic::new(DiagnosticCode::ArgumentCountMismatch, Span::empty())
        .with_number("expected", 0_u64)
        .with_number("found", u64::MAX);
    assert!(validate_arguments(&valid));
    assert_eq!(
        valid
            .arguments
            .get("found")
            .map(DiagnosticArgument::wire)
            .and_then(|value| value.as_u64()),
        Some(u64::MAX)
    );
    let invalid = Diagnostic::new(DiagnosticCode::ArgumentCountMismatch, Span::empty())
        .with_argument("expected", "0")
        .with_number("found", 1_u64);
    assert!(!validate_arguments(&invalid));
    assert!(!validate_arguments(&Diagnostic::new(
        DiagnosticCode::ArgumentCountMismatch,
        Span::empty()
    )));
    assert!(DiagnosticArgument::from_wire(ArgumentKind::Number, &serde_json::json!("1")).is_none());
    assert_eq!(
        DiagnosticCode::ArgumentCountMismatch.argument_kind("found"),
        Some(ArgumentKind::Number)
    );
    Ok(())
}

#[test]
fn does_not_reinterpret_braces_inside_a_user_lexeme() {
    let diagnostic = Diagnostic::new(DiagnosticCode::PrivateMemberAccess, Span::empty())
        .with_argument("className", "{lexeme}")
        .with_argument("lexeme", "member");
    assert!(validate_arguments(&diagnostic));
    assert!(render(&diagnostic, "es").contains("{lexeme}"));
    assert!(render(&diagnostic, "en").contains("{lexeme}"));
}

#[test]
fn rejects_wrong_argument_kinds_and_accepts_signed_numeric_bounds() {
    assert!(!ArgumentKind::Type.accepts(ArgumentKind::Lexeme));
    assert!(ArgumentKind::TypeOrLexeme.accepts(ArgumentKind::Type));
    assert!(ArgumentKind::TypeOrLexeme.accepts(ArgumentKind::Lexeme));
    let diagnostic = Diagnostic::new(DiagnosticCode::NegativeIntegerExponent, Span::empty())
        .with_number("exponent", i64::MIN);
    assert!(validate_arguments(&diagnostic));
    assert_eq!(
        diagnostic
            .arguments
            .get("exponent")
            .map(DiagnosticArgument::wire)
            .and_then(|value| value.as_i64()),
        Some(i64::MIN)
    );
}
