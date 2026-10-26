mod support;
use pseudolearn_semantic::{HirExpression, Literal, Type};

#[test]
fn retains_literal_code_points_with_explicit_numeric_widening() -> Result<(), String> {
    let source = "algorithm Unicode\ndefine amount as real <- 3;\nwrite amount, \"e\u{301}\";\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let module = module.ok_or("Missing HIR")?;
    assert!(
        module
            .expressions
            .kinds
            .iter()
            .any(|expression| matches!(expression, HirExpression::Widen(_)))
    );
    assert!(module.expressions.kinds.iter().any(|expression| matches!(expression, HirExpression::Literal(Literal::String(text)) if text == "e\u{301}")));
    assert_eq!(
        module.expressions.kinds.len(),
        module.expressions.types.len()
    );
    assert_eq!(
        module.expressions.kinds.len(),
        module.expressions.spans.len()
    );
    assert!(
        module
            .expressions
            .types
            .iter()
            .all(|kind| !matches!(module.types.get(*kind), Type::Unknown | Type::Error))
    );
    Ok(())
}

#[test]
fn widens_mixed_numeric_operands_before_binary_operations() -> Result<(), String> {
    let source = "algorithm Mixed\nwrite 1 + 2.5, 3 < 4.5;\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let module = module.ok_or("Missing HIR")?;
    let widenings = module
        .expressions
        .kinds
        .iter()
        .filter(|expression| matches!(expression, HirExpression::Widen(_)))
        .count();
    assert_eq!(widenings, 2);
    Ok(())
}
