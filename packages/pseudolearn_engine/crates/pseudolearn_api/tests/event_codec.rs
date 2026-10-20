use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn event_encodings_preserve_control_characters_unicode_and_large_indices() -> Result<(), String> {
    let mut session = ApiSession::default();
    let events = json!([
        {
            "class":"output",
            "line":u32::MAX,
            "depth":2,
            "data":{"texto":"\u{0001}\t\n\"\\🙂"},
            "source":{
                "revision_id":"rev1",
                "node_id":"rev1.n1",
                "span":{
                    "start":{"line":1,"column":1},
                    "end":{"line":1,"column":2},
                    "start_byte":"0",
                    "end_byte":"1"
                }
            }
        },
        {"class":"statement_entered","line":2,"depth":1,"source":null},
        {"class":"decision","line":4,"depth":1,"data":{"rama":"caso","indice":u64::MAX},"source":null}
    ]);
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

#[test]
fn event_source_must_be_an_object_or_null() {
    let mut session = ApiSession::default();
    let response = session.call(
        "encode_events",
        &json!({"events":[{"class":"statement_entered","line":1,"depth":1,"source":7}],"encoding":"json"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}
