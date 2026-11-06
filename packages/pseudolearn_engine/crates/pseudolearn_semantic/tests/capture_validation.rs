mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn captures(program: &str) -> Vec<pseudolearn_diagnostics::Diagnostic> {
    let (_, diagnostics) = support::analyze(program);
    diagnostics
        .into_iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::MutableClosureCapture)
        .collect()
}

const LITERAL: &str = "define f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\n";

#[test]
fn a_variable_assigned_once_can_be_captured() {
    let program =
        format!("algorithm Main\ndefine x as integer;\nx <- 1;\n{LITERAL}write f();\nendAlgorithm\n");
    assert!(captures(&program).is_empty());
}

#[test]
fn a_later_reassignment_is_the_related_origin() {
    let program = format!(
        "algorithm Main\ndefine x as integer;\nx <- 1;\n{LITERAL}x <- 2;\nwrite f();\nendAlgorithm\n"
    );
    let found = captures(&program);
    let [diagnostic] = found.as_slice() else {
        panic!("{found:?}");
    };
    assert_eq!(diagnostic.related.len(), 1);
    assert!(diagnostic.related.iter().all(|span| span.start > diagnostic.span.start));
}

#[test]
fn an_assignment_inside_a_loop_counts_as_a_reassignment() {
    let program = format!(
        "algorithm Main\ndefine x as integer;\nfor i <- 1 to 2 do\nx <- i;\nendFor\n{LITERAL}write f();\nendAlgorithm\n"
    );
    assert_eq!(captures(&program).len(), 1);
}

#[test]
fn assignments_in_exclusive_branches_are_not_reassignments() {
    let program = format!(
        "algorithm Main\ndefine x as integer;\ndefine c as boolean <- true;\nif c then\nx <- 1;\nelse\nx <- 2;\nendIf\n{LITERAL}write f();\nendAlgorithm\n"
    );
    assert!(captures(&program).is_empty());
}

#[test]
fn reference_parameters_are_rejected_at_their_declaration() {
    let program = "subroutine Keep(x as integer byReference)\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendSubroutine\nalgorithm Main\ndefine a as integer <- 1;\nKeep(a);\nendAlgorithm\n";
    assert_eq!(captures(program).len(), 1);
}
