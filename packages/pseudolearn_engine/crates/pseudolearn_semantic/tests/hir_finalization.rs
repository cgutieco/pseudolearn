mod support;
use pseudolearn_semantic::{HirStatement, Type};

#[test]
fn undeclared_reads_are_errors_in_both_modes_and_produce_no_hir() {
    for strict in [true, false] {
        let (module, diagnostics) =
            support::analyze("algorithm Main\nwrite absent;\nendAlgorithm\n", strict);
        assert!(module.is_none(), "strict={strict}");
        assert!(
            diagnostics.iter().any(|diagnostic| diagnostic.code
                == pseudolearn_diagnostics::DiagnosticCode::UndeclaredVariable),
            "strict={strict}"
        );
    }
}

#[test]
fn declared_real_binding_keeps_its_type_across_integer_writes() -> Result<(), String> {
    let (module, diagnostics) = support::analyze(
        "algorithm Main\ndefine mutable amount as real <- 1;\nwrite amount;\namount <- 2;\nwrite amount;\nendAlgorithm\n",
        false,
    );
    assert!(diagnostics.iter().all(
        |diagnostic| diagnostic.severity != pseudolearn_diagnostics::DiagnosticSeverity::Error
    ));
    let module = module.ok_or("Missing HIR")?;
    let written: Vec<_> = module
        .statements
        .kinds
        .iter()
        .filter_map(|statement| match statement {
            HirStatement::Write { values, .. } => values
                .first()
                .and_then(|expression| usize::try_from(expression.0).ok())
                .and_then(|index| module.expressions.types.get(index))
                .map(|kind| module.types.get(*kind)),
            _ => None,
        })
        .collect();
    assert_eq!(written, vec![Type::Real, Type::Real]);
    assert!(
        module
            .expressions
            .types
            .iter()
            .all(|kind| module.types.get(*kind) != Type::Unknown)
    );
    Ok(())
}
