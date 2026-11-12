mod support;

use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};

#[test]
fn every_declared_variable_is_reassignable_and_leaves_are_initialized() {
    let program = "record Pair\ndefine left, right as integer;\nendRecord\nalgorithm Main\ndefine pair as Pair <- Pair(1, 2);\ndefine total as integer <- pair.left;\ntotal <- total + pair.right;\nwrite total;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(module.is_some());
    if let Some(module) = module {
        assert!(
            module
                .locals
                .iter()
                .any(|local| local.name == "pair" && local.reassignable)
        );
        assert!(
            module
                .locals
                .iter()
                .any(|local| local.name == "total" && local.reassignable)
        );
    }
}

#[test]
fn accepts_reassignment_read_and_reference_argument() {
    for body in [
        "define number as integer <- 1;\nnumber <- 2;\nwrite number;",
        "define number as integer <- 1;\nread number;\nwrite number;",
        "define number as integer <- 1;\nUpdate(number);\nwrite number;",
    ] {
        let program = format!(
            "subroutine Update(number as integer byReference)\nnumber <- 2;\nendSubroutine\nalgorithm Main\n{body}\nendAlgorithm\n"
        );
        let (module, diagnostics) = support::analyze(&program);
        assert!(module.is_some(), "{diagnostics:?}");
        assert!(
            diagnostics
                .iter()
                .all(|diagnostic| diagnostic.severity != DiagnosticSeverity::Error),
            "{diagnostics:?}"
        );
    }
}

#[test]
fn keeps_pattern_bindings_out_of_reach_of_assignment() {
    let program = "algorithm Main\ndefine maybe as optional<integer> <- some(1);\nswitch maybe do\nsome(value): value <- 2;\nnone: write 0;\nendSwitch\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(program);
    assert!(module.is_none());
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::ImmutableBindingAssignment),
        "{diagnostics:?}"
    );
}

#[test]
fn rejects_implicit_declaration() {
    let (module, diagnostics) =
        support::analyze("algorithm Main\nnumber <- 1;\nwrite number;\nendAlgorithm\n");
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

#[test]
fn does_not_warn_about_variables_that_are_never_reassigned() {
    let (module, diagnostics) = support::analyze(
        "algorithm Main\ndefine number as integer <- 1;\nwrite number;\nendAlgorithm\n",
    );
    assert!(module.is_some());
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn permits_object_mutation_and_value_record_mutation() {
    let object = "class Holder\ndefine amount as integer;\nendClass\nalgorithm Main\ndefine holder as Holder <- new Holder();\nholder.amount <- 5;\nwrite holder.amount;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(object);
    assert!(module.is_some(), "{diagnostics:?}");
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let record = "record Pair\ndefine left, right as integer;\nendRecord\nalgorithm Main\ndefine pair as Pair <- Pair(1, 2);\npair.left <- 3;\nwrite pair.right;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(record);
    assert!(module.is_some(), "{diagnostics:?}");
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}
