mod support;

use pseudolearn_diagnostics::{Diagnostic, DiagnosticArgument, DiagnosticCode};

fn causes(program: &str) -> Vec<String> {
    let (_, diagnostics) = support::analyze(program);
    diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::VariableUsedUninitialized)
        .filter_map(cause)
        .collect()
}

fn cause(diagnostic: &Diagnostic) -> Option<String> {
    match diagnostic.arguments.get("cause") {
        Some(DiagnosticArgument::Term(term)) => Some(term.clone()),
        _ => None,
    }
}

fn program(body: &str) -> String {
    format!("algorithm Main\ndefine x as integer;\ndefine c as boolean <- true;\n{body}\nendAlgorithm\n")
}

#[test]
fn a_join_keeps_only_what_every_path_assigns() {
    assert!(causes(&program("if c then\nx <- 1;\nelse\nx <- 2;\nendIf\nwrite x;")).is_empty());
    assert_eq!(
        causes(&program("if c then\nx <- 1;\nendIf\nwrite x;")),
        ["branchWithoutElse"]
    );
    assert_eq!(
        causes(&program("if c then\nx <- 1;\nelse\nwrite 0;\nendIf\nwrite x;")),
        ["branchWithoutAssignment"]
    );
}

#[test]
fn loops_that_may_not_run_drop_their_assignments() {
    assert_eq!(
        causes(&program("while c do\nx <- 1;\nc <- false;\nendWhile\nwrite x;")),
        ["loopMayNotRun"]
    );
    assert_eq!(
        causes(&program("for i <- 1 to 2 do\nx <- i;\nendFor\nwrite x;")),
        ["loopMayNotRun"]
    );
    assert!(causes(&program("repeat\nx <- 1;\nuntil x > 0\nwrite x;")).is_empty());
}

#[test]
fn a_break_before_the_assignment_reaches_the_end_of_a_repeat() {
    assert_eq!(
        causes(&program(
            "repeat\nif c then\nbreak;\nendIf\nx <- 1;\nuntil x > 0\nwrite x;"
        )),
        ["branchWithoutAssignment"]
    );
}

#[test]
fn a_returning_branch_does_not_restrict_the_join() {
    let source = "subroutine F(c as boolean) as integer\ndefine x as integer;\nif c then\nx <- 1;\nelse\nreturn 0;\nendIf\nreturn x;\nendSubroutine\nalgorithm Main\nwrite F(true);\nendAlgorithm\n";
    assert!(causes(source).is_empty());
}

#[test]
fn switches_without_default_keep_the_path_that_matches_no_branch() {
    assert_eq!(
        causes(&program(
            "define k as integer <- 2;\nswitch k do\n1: x <- 1;\n2: x <- 2;\nendSwitch\nwrite x;"
        )),
        ["switchWithoutDefault"]
    );
    assert!(
        causes(&program(
            "define k as integer <- 2;\nswitch k do\n1: x <- 1;\notherwise: x <- 2;\nendSwitch\nwrite x;"
        ))
        .is_empty()
    );
}

#[test]
fn a_single_letter_variable_deep_inside_three_loops_is_tracked() {
    let nested = "for i <- 1 to 2 do\nfor j <- 1 to 2 do\nfor k <- 1 to 2 do\nx <- i + j + k;\nendFor\nendFor\nendFor\nwrite x;";
    assert_eq!(causes(&program(nested)), ["loopMayNotRun"]);
}

#[test]
fn reading_with_no_previous_assignment_names_no_join() {
    assert_eq!(causes(&program("write x;")), ["noAssignment"]);
    assert!(causes(&program("read x;\nwrite x;")).is_empty());
}
