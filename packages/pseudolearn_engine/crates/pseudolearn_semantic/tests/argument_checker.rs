mod support;

#[test]
fn reference_parameters_require_locations_and_exact_types() {
    let source = "subroutine update(target as integer byReference)\ntarget <- 8;\nendSubroutine\nalgorithm Entry\nupdate(4);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(module.is_none());
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "byReferenceArgumentRequiresDesignator")
    );
    assert!(
        !diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "internalFault")
    );
}

#[test]
fn invalid_names_suppress_initialization_cascades() {
    let (module, diagnostics) = support::analyze(
        "algorithm Unresolved\nwrite absent, absent;\nendAlgorithm\n",
        true,
    );
    assert!(module.is_none());
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code.as_str() == "undeclaredVariable")
            .count(),
        1
    );
    assert!(
        !diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "variableUsedUninitialized")
    );
}
