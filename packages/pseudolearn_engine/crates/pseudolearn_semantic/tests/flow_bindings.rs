mod support;
use pseudolearn_diagnostics::DiagnosticCode;

#[test]
fn preserves_implicit_variable_diagnostics_after_parameter_inference_repeats() -> Result<(), String>
{
    let program = "subroutine Echo(value)\nwrite value;\nendSubroutine\nalgorithm Main\namount <- 1;\nwrite amount;\nEcho(2);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program, false);
    assert!(module.is_some(), "{diagnostics:?}");
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code == DiagnosticCode::UndeclaredVariable)
            .count(),
        1
    );
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code == DiagnosticCode::InferredVariableType)
            .count(),
        1
    );
    assert!(
        !diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::VariableUsedUninitialized)
    );
    Ok(())
}

#[test]
fn infers_an_assignment_after_an_unexecuted_untyped_read_without_inventing_a_dynamic_type() {
    let program = "algorithm Main\nif false then\nwrite missing;\nendIf\nmissing <- 1;\nwrite missing;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program, false);
    assert!(module.is_some(), "{diagnostics:?}");
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::InferredVariableType)
    );
}
