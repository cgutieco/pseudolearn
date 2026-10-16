use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn declared_editions_and_capabilities_negotiate_without_changing_resources() -> Result<(), String> {
    let mut session = ApiSession::default();
    let declared = session.call("version", &json!({}));
    assert_eq!(declared.pointer("/value/editions"), Some(&json!(["2026"])));
    for name in ["editions", "capabilities"] {
        let values = declared
            .pointer(&format!("/value/{name}"))
            .and_then(Value::as_array)
            .ok_or("missing declaration")?;
        for value in values {
            assert_eq!(
                session.call("negotiate", &json!({name:value})),
                json!({"value":null})
            );
        }
        let rejected = session.call("negotiate", &json!({name:"unknown"}));
        assert_eq!(rejected.pointer("/failure/family"), Some(&json!("version")));
        let malformed = session.call("negotiate", &json!({name:17}));
        assert_eq!(malformed.pointer("/failure/family"), Some(&json!("usage")));
    }
    assert_eq!(session.call("version", &json!({})), declared);
    Ok(())
}
