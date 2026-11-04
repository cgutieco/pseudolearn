mod support;

#[test]
fn merges_definition_from_every_branch() {
    let source = "algorithm Branches\ndefine mutable answer as integer <- 0;\nif true then\nanswer <- 7;\nelse\nanswer <- 11;\nendIf\nwrite answer;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source);
    assert!(module.is_some());
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn a_declaration_without_initializer_is_rejected() {
    let source = "algorithm Branches\ndefine answer as integer;\nwrite 1;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source);
    assert!(module.is_none());
    assert!(diagnostics.iter().any(|diagnostic| diagnostic.code
        == pseudolearn_diagnostics::DiagnosticCode::MissingBindingInitializer));
}
