mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use support::analyze;

#[test]
fn accepts_a_missing_step_clause() {
    let (module, diagnostics) =
        analyze("algorithm Main\nfor index <- 1 to 3 do\nwrite index;\nendFor\nendAlgorithm\n");
    assert!(module.is_some());
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn accepts_a_typed_step_clause() {
    let (_, diagnostics) = analyze(
        "algorithm Main\nfor index <- 1 to 3 step 1 do\nwrite index;\nendFor\nendAlgorithm\n",
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}
