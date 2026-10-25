mod support;
use pseudolearn_diagnostics::DiagnosticCode;

#[test]
fn preserves_invalid_bindings_after_parameter_inference_repeats() {
    let program = "subroutine Echo(value)\nwrite value;\nendSubroutine\nalgorithm Main\namount <- 1;\nwrite amount;\nEcho(2);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program, false);
    assert!(module.is_none(), "{diagnostics:?}");
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code == DiagnosticCode::UndeclaredVariable)
            .count(),
        1
    );
    assert!(!diagnostics.iter().any(|diagnostic| matches!(
        diagnostic.code,
        DiagnosticCode::InferredVariableType | DiagnosticCode::VariableUsedUninitialized
    )));
}

#[test]
fn preserves_explicit_mutability_after_parameter_inference_repeats() {
    let program = "subroutine Echo(value)\nwrite value;\nendSubroutine\nalgorithm Main\ndefine mutable amount as integer <- 1;\namount <- 2;\nEcho(amount);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program, false);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(module.is_some());
    if let Some(module) = module {
        assert!(
            module
                .locals
                .iter()
                .any(|local| local.name == "amount" && local.mutable)
        );
        assert!(
            module
                .locals
                .iter()
                .filter(|local| local.name == "amount")
                .count()
                == 1
        );
    }
}
