mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn codes(program: &str) -> Vec<DiagnosticCode> {
    let (_, diagnostics) = support::analyze(program);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn a_function_opening_declares_a_pure_unit() {
    let program = "function r <- Shout()\ndefine r as integer;\nwrite 1;\nr <- 1;\nendFunction\nalgorithm Main\nwrite Shout();\nendAlgorithm\n";
    assert!(codes(program).contains(&DiagnosticCode::PureFunctionSideEffect));
}

#[test]
fn a_subroutine_opening_may_have_effects() {
    let program = "subroutine r <- Shout()\ndefine r as integer;\nwrite 1;\nr <- 1;\nendSubroutine\nalgorithm Main\nwrite Shout();\nendAlgorithm\n";
    assert!(codes(program).is_empty());
}

#[test]
fn a_pure_function_type_rejects_an_effectful_value() {
    let program = "subroutine Loud() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nalgorithm Main\ndefine f as function() as integer <- Loud;\nwrite f();\nendAlgorithm\n";
    assert!(codes(program).contains(&DiagnosticCode::PureFunctionTransitiveSideEffect));
}

#[test]
fn a_suspendable_function_is_not_allowed() {
    let program = "function suspendable Work() as integer\nreturn 1;\nendFunction\nalgorithm Main\nendAlgorithm\n";
    assert!(codes(program).contains(&DiagnosticCode::SuspendibleModifierNotAllowed));
}
