mod support;

use pseudolearn_diagnostics::DiagnosticCode;

#[test]
fn reports_missing_members_in_declaration_order() {
    let program = "enum Color\nRed, Green, Blue\nendEnum\nalgorithm Main\nswitch Color.Red do\nColor.Green: write 1;\nendSwitch\nendAlgorithm\n";
    let (_, diagnostics) = support::analyze(program, true);
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::NonExhaustiveSwitch)
    );
    assert!(format!("{diagnostics:?}").contains("Color.Red, Color.Blue"));
}

#[test]
fn accepts_single_member_and_wildcard_coverage() {
    for branches in ["Color.Red: write 1;", "otherwise: write 1;"] {
        let program = format!(
            "enum Color\nRed\nendEnum\nalgorithm Main\nswitch Color.Red do\n{branches}\nendSwitch\nendAlgorithm\n"
        );
        let (module, diagnostics) = support::analyze(&program, true);
        assert!(module.is_some(), "{diagnostics:?}");
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
    }
}

#[test]
fn rejects_patterns_after_wildcard_without_coverage_cascade() {
    let program = "enum Color\nRed, Green\nendEnum\nalgorithm Main\nswitch Color.Red do\notherwise: write 1;\nColor.Green: write 2;\nendSwitch\nendAlgorithm\n";
    let (_, diagnostics) = support::analyze(program, true);
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::UnreachableSwitchPattern)
    );
}
