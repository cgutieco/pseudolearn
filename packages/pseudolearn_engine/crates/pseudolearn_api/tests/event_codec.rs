use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn event_encodings_preserve_control_characters_unicode_and_large_indices() -> Result<(), String> {
    let mut session = ApiSession::default();
    let events = json!([{"class":"output","line":u32::MAX,"depth":2,"data":{"texto":"\u{0001}\t\n\"\\🙂"}},
        {"class":"decision","line":4,"depth":1,"data":{"rama":"caso","indice":u64::MAX}}]);
    for encoding in ["json", "binary"] {
        let encoded = session.call(
            "encode_events",
            &json!({"events":events,"encoding":encoding}),
        );
        let encoded = encoded.get("value").ok_or_else(|| encoded.to_string())?;
        let decoded = session.call(
            "decode_events",
            &json!({"encoded":encoded,"encoding":encoding}),
        );
        assert_eq!(decoded.get("value"), Some(&events));
    }
    Ok(())
}

#[test]
fn corrupt_binary_batches_are_usage_errors() {
    let mut session = ApiSession::default();
    for encoded in [json!([]), json!([255, 0, 1]), json!([256]), Value::Null] {
        let response = session.call(
            "decode_events",
            &json!({"encoded":encoded,"encoding":"binary"}),
        );
        assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    }
    let response = session.call(
        "encode_events",
        &json!({"events":[{"class":"unknown"}],"encoding":"binary"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}
