mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use support::analyze;

#[test]
fn requires_types_on_parameters() {
    let (_, diagnostics) = analyze(
        "subroutine writeValue(value)\nendSubroutine\nalgorithm Main\nwriteValue(1);\nendAlgorithm\n",
    );
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::ExpectedType)
    );
}

#[test]
fn accepts_typed_parameters() {
    let (_, diagnostics) = analyze(
        "subroutine writeValue(value as integer)\nwrite value;\nendSubroutine\nalgorithm Main\nwriteValue(1);\nendAlgorithm\n",
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}
