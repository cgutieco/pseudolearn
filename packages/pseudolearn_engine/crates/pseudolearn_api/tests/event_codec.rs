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
                "identity":{"project_id":"7","revision_id":"11","source_id":2},
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

#[test]
fn binary_v2_retains_identity_and_binary_v1_remains_readable() -> Result<(), String> {
    let mut session = ApiSession::default();
    let events = json!([
        {"class":"statement_entered","line":1,"depth":1,"source":{
            "revision_id":"rev1","node_id":"rev1.n1","span":{
                "start":{"line":1,"column":1},"end":{"line":1,"column":2},
                "start_byte":"0","end_byte":"1"
            }
        }}
    ]);
    let encoded = session.call(
        "encode_events",
        &json!({"events":events,"encoding":"binary","version":1}),
    );
    let bytes: Vec<u8> = serde_json::from_value(
        encoded
            .pointer("/value")
            .cloned()
            .ok_or("missing binary batch")?,
    )
    .map_err(|error| error.to_string())?;
    assert_eq!(bytes.get(4), Some(&1));
    let decoded = session.call(
        "decode_events",
        &json!({"encoded":bytes.clone(),"encoding":"binary"}),
    );
    assert_eq!(decoded.get("value"), Some(&events));
    let mut unsupported = bytes;
    if let Some(version) = unsupported.get_mut(4) {
        *version = 99;
    }
    let rejected = session.call(
        "decode_events",
        &json!({"encoded":unsupported,"encoding":"binary"}),
    );
    assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn truncated_binary_batches_are_usage_errors() {
    let mut session = ApiSession::default();
    let response = session.call(
        "decode_events",
        &json!({"encoded":[80,76,69,86,2],"encoding":"binary"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn unsupported_binary_writer_versions_are_usage_errors() {
    let mut session = ApiSession::default();
    for version in [json!(3), json!(u32::MAX)] {
        let response = session.call(
            "encode_events",
            &json!({"events":[],"encoding":"binary","version":version}),
        );
        assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    }
    let response = session.call(
        "encode_events",
        &json!({"events":[],"encoding":"binary","version":"2"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn binary_format_negotiation_selects_a_supported_version() {
    let mut session = ApiSession::default();
    let negotiated = session.call("negotiate", &json!({"event_binary_versions":[1,2]}));
    assert_eq!(
        negotiated.get("value"),
        Some(&json!({
            "event_binary_version":2,
            "event_binary_write_version":2,
            "event_binary_read_versions":[1,2]
        }))
    );
    let legacy = session.call("negotiate", &json!({"event_binary_versions":[1]}));
    assert_eq!(
        legacy.pointer("/value/event_binary_write_version"),
        Some(&json!(1))
    );
    let unsupported = session.call("negotiate", &json!({"event_binary_versions":[3]}));
    assert_eq!(
        unsupported.pointer("/failure/family"),
        Some(&json!("version"))
    );
}

#[test]
fn binary_v2_round_trip_preserves_source_identity() -> Result<(), String> {
    let mut session = ApiSession::default();
    let events = json!([{"class":"statement_entered","line":1,"depth":1,"source":{
        "revision_id":"rev1","node_id":"rev1.n1",
        "identity":{"project_id":"7","revision_id":"11","source_id":2},
        "span":{"start":{"line":1,"column":1},"end":{"line":1,"column":2},
            "start_byte":"0","end_byte":"1"}
    }}]);
    let encoded = session.call(
        "encode_events",
        &json!({"events":events,"encoding":"binary","version":2}),
    );
    let bytes: Vec<u8> = serde_json::from_value(
        encoded
            .pointer("/value")
            .cloned()
            .ok_or("missing binary batch")?,
    )
    .map_err(|error| error.to_string())?;
    assert_eq!(bytes.get(4), Some(&2));
    let decoded = session.call(
        "decode_events",
        &json!({"encoded":bytes,"encoding":"binary"}),
    );
    assert_eq!(decoded.get("value"), Some(&events));
    Ok(())
}

#[test]
fn malformed_event_identity_is_rejected() {
    let mut session = ApiSession::default();
    let response = session.call(
        "encode_events",
        &json!({"events":[{"class":"statement_entered","line":1,"depth":1,"source":{
            "revision_id":"rev1","node_id":"rev1.n1","identity":{
                "project_id":"0","revision_id":"1","source_id":2
            },"span":{}
        }}],"encoding":"json"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn legacy_binary_writer_rejects_source_identity() {
    let mut session = ApiSession::default();
    let response = session.call(
        "encode_events",
        &json!({"events":[{"class":"statement_entered","line":1,"depth":1,"source":{
            "revision_id":"rev1","node_id":"rev1.n1","identity":{
                "project_id":"7","revision_id":"11","source_id":2
            },"span":{}
        }}],"encoding":"binary","version":1}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}
