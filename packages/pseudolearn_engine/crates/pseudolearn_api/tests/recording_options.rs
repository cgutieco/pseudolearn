use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str =
    "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n";

fn record(options: Value) -> Value {
    let mut session = ApiSession::default();
    let request = json!({"program":PROGRAM,"profile":"es","strictness":"strict","seed":7,"inputs":["21"],"observe":"events"});
    session.call("record", &json!({"request":request,"options":options}))
}

fn json_at(value: &Value, path: &str) -> Value {
    value.pointer(path).cloned().unwrap_or(Value::Null)
}

#[test]
fn partitioned_input_tape_yields_the_same_observations() {
    let base = record(json!({"batch_size":1}));
    for split in [0, 1] {
        let partitioned = record(json!({"input_batch_sizes":[split, 1 - split]}));
        for field in ["events", "output", "termination", "inputs_consumed"] {
            assert_eq!(
                json_at(&partitioned, &format!("/value/{field}")),
                json_at(&base, &format!("/value/{field}")),
                "{field}"
            );
        }
    }
}

#[test]
fn seeking_every_event_does_not_change_the_recording() {
    let base = record(json!({"batch_size":1}));
    let seeking = record(json!({"seek_every_event":true}));
    assert_eq!(
        json_at(&seeking, "/value/events"),
        json_at(&base, "/value/events")
    );
    assert_eq!(
        json_at(&seeking, "/value/historical_states"),
        json_at(&base, "/value/historical_states")
    );
}

#[test]
fn host_tape_replays_the_recorded_run() {
    let base = record(json!({"batch_size":1}));
    let tape = json_at(&base, "/value/host_tape").clone();
    let replay = record(json!({"host_tape":tape}));
    assert_eq!(
        json_at(&replay, "/value/output"),
        json_at(&base, "/value/output")
    );
}

#[test]
fn recording_without_states_skips_state_capture() {
    let result = record(json!({"capture_states":false}));
    assert_eq!(json_at(&result, "/value/states"), json!([]));
    assert!(
        !json_at(&result, "/value/events")
            .as_array()
            .is_none_or(Vec::is_empty)
    );
}

#[test]
fn unsupported_option_is_a_usage_failure() {
    let result = record(json!({"warp":true}));
    assert_eq!(json_at(&result, "/failure/family"), json!("usage"));
}

#[test]
fn malformed_host_tape_is_a_usage_failure() {
    let result = record(json!({"host_tape":{"seed":"x"}}));
    assert_eq!(json_at(&result, "/failure/family"), json!("usage"));
}
