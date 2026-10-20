use super::verify;
use serde_json::json;

#[test]
fn verifies_canonical_ir_and_rejects_malformed_requests() -> Result<(), String> {
    let compiled = verify(
        &json!({"program":"Algoritmo P\nFinAlgoritmo\n","profile":"es","strictness":"strict"}),
    );
    assert_eq!(compiled.pointer("/ir/accepted"), Some(&json!(true)));
    let source = compiled.pointer("/ir/reprint").ok_or("missing RI")?;
    let reloaded = verify(&json!({"program_ir":source,"profile":"es","strictness":"strict"}));
    assert_eq!(reloaded, compiled);
    assert_eq!(
        verify(&json!({"program_ir":"invalid","profile":"es","strictness":"strict"}))
            .pointer("/ir/accepted"),
        Some(&json!(false))
    );
    assert_eq!(verify(&json!({})).get("kind"), Some(&json!("error")));
    Ok(())
}
