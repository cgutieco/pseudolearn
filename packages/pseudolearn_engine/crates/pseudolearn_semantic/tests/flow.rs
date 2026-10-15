mod support;

#[test]
fn merges_definition_from_every_branch() {
    let source = "algorithm Branches\ndefine answer as integer;\nif true then\nanswer <- 7;\nelse\nanswer <- 11;\nendIf\nwrite answer;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(module.is_some());
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn a_write_on_one_branch_does_not_define_all_paths() {
    let source = "algorithm Branches\ndefine answer as integer;\nif true then\nanswer <- 7;\nendIf\nwrite answer;\nendAlgorithm\n";
    let (strict_module, strict) = support::analyze(source, true);
    assert!(strict_module.is_none());
    assert!(
        strict
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "variableUsedUninitialized")
    );
    let (flexible_module, flexible) = support::analyze(source, false);
    assert!(flexible_module.is_some());
    assert!(flexible.iter().all(
        |diagnostic| diagnostic.severity != pseudolearn_diagnostics::DiagnosticSeverity::Error
    ));
}
