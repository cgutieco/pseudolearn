use pseudolearn_api::{ApiSession, ExecuteRequest, execute_program};
use serde_json::{Value, json};

fn encode(session: &mut ApiSession, events: &Value, encoding: &str) -> Value {
    session.call(
        "encode_events",
        &json!({"events":events,"encoding":encoding}),
    )
}

fn is_usage(response: &Value) -> bool {
    response.pointer("/failure/family") == Some(&json!("usage"))
}

fn decode_pool(session: &mut ApiSession, record: &[u8]) -> Value {
    let mut bytes = vec![80_u8, 76, 69, 86, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0];
    bytes.push(0);
    bytes.extend_from_slice(&1_u32.to_le_bytes());
    bytes.extend_from_slice(&1_u32.to_le_bytes());
    bytes.extend_from_slice(&0_u32.to_le_bytes());
    bytes.extend_from_slice(&u32::try_from(record.len()).unwrap_or(0).to_le_bytes());
    bytes.extend_from_slice(record);
    session.call(
        "decode_events",
        &json!({"encoded":bytes,"encoding":"binary"}),
    )
}

fn round_trip(session: &mut ApiSession, events: &Value, encoding: &str) -> Option<Value> {
    let encoded = encode(session, events, encoding).get("value").cloned()?;
    let decoded = session.call(
        "decode_events",
        &json!({"encoded":encoded,"encoding":encoding}),
    );
    decoded.get("value").cloned()
}

fn with_explicit_source(events: &[Value]) -> Value {
    events
        .iter()
        .cloned()
        .map(|mut event| {
            if let Some(fields) = event.as_object_mut() {
                fields.entry("source").or_insert(Value::Null);
            }
            event
        })
        .collect()
}

#[test]
fn events_the_engine_emits_pass_the_strict_codec() {
    let response = execute_program(&ExecuteRequest {
        program: "function r <- twice(a as integer)\ndefine r as integer;\nr <- a * 2;\nendFunction\nalgorithm P\nif twice(2) = 4 then\nwrite \"ok\";\nendIf\nswitch indexOf(\"ab\", \"b\") do\nnone: write -1;\nsome(position): write position;\nendSwitch\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        observe: "events".to_owned(),
        ..Default::default()
    });
    let classes: Vec<_> = response
        .events
        .iter()
        .filter_map(|event| event.get("class").and_then(Value::as_str))
        .collect();
    assert!(
        classes.contains(&"decision") && classes.contains(&"call") && classes.contains(&"output"),
        "{classes:?}"
    );
    let mut session = ApiSession::default();
    let events = json!(response.events);
    assert_eq!(round_trip(&mut session, &events, "json"), Some(events));
    let explicit = with_explicit_source(&response.events);
    assert_eq!(
        round_trip(&mut session, &explicit, "binary"),
        Some(explicit)
    );
}

#[test]
fn unknown_top_level_fields_are_rejected_instead_of_dropped() {
    let mut session = ApiSession::default();
    let events =
        json!([{"class":"statement_entered","line":1,"depth":1,"source":null,"task_id":0}]);
    for encoding in ["json", "binary"] {
        assert!(
            is_usage(&encode(&mut session, &events, encoding)),
            "{encoding}"
        );
    }
}

#[test]
fn ordinary_payloads_accept_only_their_declared_keys() {
    let mut session = ApiSession::default();
    for payload in [
        json!({"texto":"a","extra":1}),
        json!({}),
        json!({"nombre":"a"}),
    ] {
        let events = json!([{"class":"output","line":1,"depth":1,"data":payload}]);
        assert!(
            is_usage(&encode(&mut session, &events, "json")),
            "{payload}"
        );
    }
}

#[test]
fn decisions_require_a_known_branch_and_a_numeric_index() {
    let mut session = ApiSession::default();
    for payload in [
        json!({"rama":"caso","indice":"7"}),
        json!({"rama":"caso","indice":-1}),
        json!({"rama":"caso","indice":1.5}),
        json!({"rama":"tal vez"}),
        json!({"rama":"caso","indice":0,"extra":true}),
    ] {
        let events = json!([{"class":"decision","line":1,"depth":1,"data":payload}]);
        assert!(
            is_usage(&encode(&mut session, &events, "binary")),
            "{payload}"
        );
    }
    for payload in [json!({"rama":"otro"}), json!({"rama":"caso","indice":0})] {
        let events = json!([{"class":"decision","line":1,"depth":1,"data":payload,"source":null}]);
        let encoded = encode(&mut session, &events, "binary");
        assert!(encoded.get("value").is_some(), "{payload}");
    }
}

#[test]
fn the_binary_decoder_accepts_only_canonical_pool_records() {
    let mut session = ApiSession::default();
    let canonical = decode_pool(&mut session, br#"{"data":null,"source":null}"#);
    assert_eq!(
        canonical,
        json!({"value":[{"class":"statement_entered","line":1,"depth":1,"source":null}]})
    );
    for record in [
        &br#"{"source":null,"data":null}"#[..],
        br#"{"data": null,"source":null}"#,
        br#"{"data":null,"data":null,"source":null}"#,
        br#"{"data":null,"source":null,"extra":0}"#,
        br#"{"source":null}"#,
        br#" {"data":null,"source":null}"#,
    ] {
        let response = decode_pool(&mut session, record);
        assert!(is_usage(&response), "{}", String::from_utf8_lossy(record));
    }
}
