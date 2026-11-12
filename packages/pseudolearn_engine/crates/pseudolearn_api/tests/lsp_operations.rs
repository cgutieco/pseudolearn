use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn create(session: &mut ApiSession) -> Result<Value, String> {
    session
        .call("create_lsp", &json!({}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing LSP resource".to_owned())
}

#[test]
fn persistent_lsp_resources_are_isolated_and_released() -> Result<(), String> {
    let mut session = ApiSession::default();
    let first = create(&mut session)?;
    let second = create(&mut session)?;
    let initialize = json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{}});
    let answer = session.call(
        "lsp_message",
        &json!({"resource":first,"message":initialize}),
    );
    assert!(
        answer
            .pointer("/value/messages/0/result/capabilities")
            .is_some()
    );
    let query = json!({"jsonrpc":"2.0","id":2,"method":"textDocument/hover","params":{}});
    let answer = session.call("lsp_message", &json!({"resource":second,"message":query}));
    assert_eq!(
        answer.pointer("/value/messages/0/error/code"),
        Some(&json!(-32002))
    );
    session.call("release", &json!({"resource":first}));
    let answer = session.call(
        "lsp_message",
        &json!({"resource":first,"message":initialize}),
    );
    assert_eq!(answer.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn lsp_rejects_nonmessage_and_wrong_resource() {
    let mut session = ApiSession::default();
    let answer = session.call("lsp_message", &json!({"resource":1,"message":[]}));
    assert_eq!(answer.pointer("/failure/family"), Some(&json!("usage")));
    let answer = session.call("create_lsp", &json!({"unexpected":true}));
    assert_eq!(answer.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn translation_uses_existing_service_and_rejects_invalid_profile() {
    let mut session = ApiSession::default();
    let translated = session.call(
        "translate",
        &json!({"program":"Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n","target_profile":"en"}),
    );
    assert!(
        translated
            .pointer("/value/text")
            .and_then(Value::as_str)
            .is_some_and(|text| text.contains("Algorithm"))
    );
    let rejected = session.call(
        "translate",
        &json!({"program":"","target_profile":"unknown"}),
    );
    assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
}
