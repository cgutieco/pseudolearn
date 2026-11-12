mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn unassigned(program: &str) -> usize {
    let (_, diagnostics) = support::analyze(program);
    diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::VariableUsedUninitialized)
        .count()
}

const SET: &str = "subroutine Set(n as integer byReference)\nn <- 7;\nendSubroutine\n";

#[test]
fn a_parameter_assigned_before_any_read_gives_its_argument_a_value() {
    let program =
        format!("{SET}algorithm Main\ndefine a as integer;\nSet(a);\nwrite a;\nendAlgorithm\n");
    assert_eq!(unassigned(&program), 0);
}

#[test]
fn a_parameter_read_first_needs_an_assigned_argument() {
    let program = "subroutine Twice(n as integer byReference)\nn <- n * 2;\nendSubroutine\nalgorithm Main\ndefine a as integer;\nTwice(a);\nwrite a;\nendAlgorithm\n";
    assert_eq!(unassigned(program), 1);
}

#[test]
fn a_parameter_left_without_value_on_some_path_is_not_an_output() {
    let program = "subroutine Maybe(c as boolean, n as integer byReference)\nif c then\nn <- 1;\nendIf\nendSubroutine\nalgorithm Main\ndefine a as integer;\nMaybe(true, a);\nwrite a;\nendAlgorithm\n";
    assert_eq!(unassigned(program), 1);
}

#[test]
fn recursive_subroutines_have_no_output_parameters() {
    let program = "subroutine Count(k as integer, n as integer byReference)\nif k > 0 then\nCount(k - 1, n);\nendIf\nn <- k;\nendSubroutine\nalgorithm Main\ndefine a as integer;\nCount(2, a);\nwrite a;\nendAlgorithm\n";
    assert_eq!(unassigned(program), 1);
}

#[test]
fn forwarding_to_another_output_parameter_keeps_the_output() {
    let program = format!(
        "{SET}subroutine Forward(n as integer byReference)\nSet(n);\nendSubroutine\nalgorithm Main\ndefine a as integer;\nForward(a);\nwrite a;\nendAlgorithm\n"
    );
    assert_eq!(unassigned(&program), 0);
}

#[test]
fn indirect_calls_require_every_reference_argument_to_have_a_value() {
    let program = format!(
        "{SET}algorithm Main\ndefine f as subroutine(integer byReference) <- Set;\ndefine a as integer;\nf(a);\nwrite a;\nendAlgorithm\n"
    );
    assert_eq!(unassigned(&program), 1);
}

#[test]
fn array_parameters_are_never_outputs_but_arrays_already_have_a_value() {
    let program = "subroutine Fill(v[] as integer)\nv[0] <- 1;\nendSubroutine\nalgorithm Main\ndimension a[1] as integer;\nFill(a);\nwrite a[0];\nendAlgorithm\n";
    assert_eq!(unassigned(program), 0);
}
