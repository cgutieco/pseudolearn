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
fn the_return_type_comes_from_the_declared_variable() {
    let program = "function r <- Larger(a as integer, b as integer)\ndefine r as integer;\nif a > b then\nr <- a;\nelse\nr <- b;\nendIf\nendSubroutine\nalgorithm Main\ndefine m as integer <- Larger(1, 2);\nwrite m;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(module.is_some());
}

#[test]
fn a_path_that_leaves_the_variable_empty_is_reported_at_the_end() {
    let program = "function r <- Positive(a as integer)\ndefine r as integer;\nif a > 0 then\nr <- a;\nendIf\nendSubroutine\nalgorithm Main\nwrite Positive(1);\nendAlgorithm\n";
    assert_eq!(codes(program), [DiagnosticCode::VariableUsedUninitialized]);
}

#[test]
fn a_return_with_a_value_and_a_missing_declaration_are_rejected() {
    let with_value = "function r <- One()\ndefine r as integer;\nr <- 1;\nreturn r;\nendSubroutine\nalgorithm Main\nwrite One();\nendAlgorithm\n";
    assert_eq!(
        codes(with_value),
        [DiagnosticCode::ReturnValueInReturnVariableFunction]
    );
    let undeclared =
        "function r <- One()\nendSubroutine\nalgorithm Main\nwrite One();\nendAlgorithm\n";
    assert!(codes(undeclared).contains(&DiagnosticCode::ReturnVariableNotDeclared));
}

#[test]
fn an_empty_return_hands_back_the_assigned_variable() {
    let program = "function r <- Sign(a as integer)\ndefine r as integer;\nr <- 1;\nif a < 0 then\nr <- -1;\nreturn;\nendIf\nendSubroutine\nalgorithm Main\nwrite Sign(-2);\nendAlgorithm\n";
    assert!(codes(program).is_empty());
}
