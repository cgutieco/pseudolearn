#[path = "support/translation.rs"]
mod translation;

use pseudolearn_transpiler::TargetLanguage;
use translation::code;

#[test]
fn numeric_literal_receivers_name_their_type() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir raiz(4), abs(-3), max(2, 5);\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("f64::sqrt(4.0)"));
    assert!(text.contains("f64::abs(-3 as f64)"));
    assert!(text.contains("i64::max(2, 5)"));
    Ok(())
}

#[test]
fn variables_keep_method_syntax() -> Result<(), String> {
    let program = "Algoritmo P\nDefinir x Como Real <- 2.0;\nEscribir raiz(x);\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("finite(x.sqrt())"));
    Ok(())
}

#[test]
fn real_extremes_follow_the_signed_zero_rule() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir min(0.0, -0.0), max(-0.0, 0.0);\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("real_minimum(0.0, (-0.0))"));
    assert!(text.contains("fn real_maximum(left: f64, right: f64) -> f64 {"));
    Ok(())
}

#[test]
fn random_ranges_and_units_bring_the_random_source() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir Aleatorio(1, 6) >= 1, AzarReal() < 1.0;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("random_between(1, 6)"));
    assert!(text.contains("fn random_unit() -> f64 {"));
    assert!(text.contains("struct RandomSource {"));
    Ok(())
}
