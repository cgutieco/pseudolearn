mod support;

use pseudolearn_diagnostics::{DiagnosticArgument, DiagnosticCode};

#[test]
fn names_the_variable_its_declaration_and_the_construct_that_left_it_empty() {
    let program = "algorithm Main\ndefine x as integer;\ndefine c as boolean <- true;\nif c then\nx <- 1;\nendIf\nwrite x;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program);
    assert!(module.is_none());
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    for diagnostic in &diagnostics {
        assert_eq!(diagnostic.code, DiagnosticCode::VariableUsedUninitialized);
        assert_eq!(
            diagnostic.arguments.get("lexeme"),
            Some(&DiagnosticArgument::Lexeme("x".to_owned()))
        );
        assert_eq!(diagnostic.related.len(), 2);
        assert!(
            diagnostic
                .related
                .iter()
                .all(|span| span.start < diagnostic.span.start)
        );
    }
}

#[test]
fn a_read_without_any_assignment_has_only_the_declaration_as_origin() {
    let (_, diagnostics) =
        support::analyze("algorithm Main\ndefine x as integer;\nwrite x;\nendAlgorithm\n");
    assert_eq!(
        diagnostics
            .iter()
            .map(|diagnostic| diagnostic.related.len())
            .collect::<Vec<_>>(),
        [1]
    );
}

#[test]
fn an_unassigned_argument_by_value_is_reported_after_the_call_is_checked() {
    let program = "subroutine Show(value as integer)\nwrite value;\nendSubroutine\nalgorithm Main\ndefine x as integer;\nShow(x);\nendAlgorithm\n";
    let (_, diagnostics) = support::analyze(program);
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code == DiagnosticCode::VariableUsedUninitialized)
            .count(),
        1,
        "{diagnostics:?}"
    );
}

#[test]
fn reading_the_variable_in_its_own_initializer_keeps_its_own_code() {
    let (_, diagnostics) =
        support::analyze("algorithm Main\ndefine x as integer <- x;\nwrite x;\nendAlgorithm\n");
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::BindingReadsOwnInitializer),
        "{diagnostics:?}"
    );
}
