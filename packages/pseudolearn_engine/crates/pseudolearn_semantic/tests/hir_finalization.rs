mod support;
use pseudolearn_semantic::{HirExpression, HirStatement, Type};

#[test]
fn models_untyped_failed_reads_without_inventing_a_primitive_type() -> Result<(), String> {
    let (module, diagnostics) =
        support::analyze("algorithm Main\nwrite absent;\nendAlgorithm\n", false);
    assert!(diagnostics.iter().all(
        |diagnostic| diagnostic.severity != pseudolearn_diagnostics::DiagnosticSeverity::Error
    ));
    let module = module.ok_or("Missing HIR")?;
    assert!(
        module
            .expressions
            .kinds
            .iter()
            .any(|expression| matches!(expression, HirExpression::Uninitialized(_)))
    );
    assert!(
        module
            .expressions
            .types
            .iter()
            .any(|kind| module.types.get(*kind) == Type::Never)
    );
    assert!(
        module
            .expressions
            .types
            .iter()
            .all(|kind| module.types.get(*kind) != Type::Unknown)
    );
    Ok(())
}

#[test]
fn preserves_integer_reads_before_a_later_real_widening() -> Result<(), String> {
    let (module, diagnostics) = support::analyze(
        "algorithm Main\namount <- 1;\nwrite amount;\namount <- 1.5;\nwrite amount;\nendAlgorithm\n",
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
    assert_eq!(written, vec![Type::Integer, Type::Real]);
    assert!(
        module
            .expressions
            .types
            .iter()
            .all(|kind| module.types.get(*kind) != Type::Unknown)
    );
    Ok(())
}
