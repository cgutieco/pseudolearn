mod support;

use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};

#[test]
fn initialized_bindings_preserve_mutability_and_leaf_initialization() {
    let program = "record Pair\ndefine left, right as integer;\nendRecord\nalgorithm Main\ndefine pair as Pair <- Pair(1, 2);\ndefine mutable total as integer <- pair.left;\ntotal <- total + pair.right;\nwrite total;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program, true);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(module.is_some());
    if let Some(module) = module {
        assert!(
            module
                .locals
                .iter()
                .any(|local| local.name == "pair" && !local.mutable)
        );
        assert!(
            module
                .locals
                .iter()
                .any(|local| local.name == "total" && local.mutable)
        );
    }
}

#[test]
fn rejects_rebinding_record_field_and_reference_argument() {
    for body in [
        "define number as integer <- 1;\nnumber <- 2;\nwrite number;",
        "define number as integer <- 1;\nread number;\nwrite number;",
        "define number as integer <- 1;\nUpdate(number);\nwrite number;",
    ] {
        let program = format!(
            "subroutine Update(number as integer byReference)\nnumber <- 2;\nendSubroutine\nalgorithm Main\n{body}\nendAlgorithm\n"
        );
        let (module, diagnostics) = support::analyze(&program, true);
        assert!(module.is_none());
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code == DiagnosticCode::ImmutableBindingAssignment),
            "{diagnostics:?}"
        );
    }
}

#[test]
fn rejects_implicit_declaration_in_both_strictness_modes() {
    for strict in [true, false] {
        let (module, diagnostics) = support::analyze(
            "algorithm Main\nnumber <- 1;\nwrite number;\nendAlgorithm\n",
            strict,
        );
        assert!(module.is_none());
        assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
        assert_eq!(
            diagnostics.first().map(|diagnostic| diagnostic.severity),
            Some(DiagnosticSeverity::Error)
        );
        assert_eq!(
            diagnostics.first().map(|diagnostic| diagnostic.code),
            Some(DiagnosticCode::UndeclaredVariable)
        );
    }
}

#[test]
fn warns_only_when_mutability_is_unnecessary() {
    let (_, diagnostics) = support::analyze(
        "algorithm Main\ndefine mutable number as integer <- 1;\nwrite number;\nendAlgorithm\n",
        true,
    );
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::MutableBindingNeverModified)
    );
}

#[test]
fn permits_object_mutation_but_rejects_value_record_mutation() {
    let object = "class Holder\ndefine amount as integer;\nendClass\nalgorithm Main\ndefine holder as Holder <- new Holder();\nholder.amount <- 5;\nwrite holder.amount;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(object, true);
    assert!(module.is_some(), "{diagnostics:?}");
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let record = "record Pair\ndefine left, right as integer;\nendRecord\nalgorithm Main\ndefine pair as Pair <- Pair(1, 2);\npair.left <- 3;\nwrite pair.right;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(record, true);
    assert!(module.is_none());
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::ImmutableBindingAssignment)
    );
}
