use pseudolearn_host::PhysicalHost;
use serde_json::{Value, json};

fn host() -> PhysicalHost {
    PhysicalHost::new(std::env::temp_dir(), Vec::new())
}

fn read(name: &str) -> Value {
    let effect = json!({"effect_seq":1,"operation":"environment_get","receiver":null,
        "arguments":[{"kind":"text","value":name}],"result_capability":null});
    host().perform(&effect)
}

#[test]
fn a_variable_the_process_really_has_is_returned_as_some_text() {
    let reply = read("PATH");
    assert_eq!(reply.pointer("/outcome"), Some(&json!("committed")));
    assert_eq!(reply.pointer("/value/kind"), Some(&json!("optional_text")));
    assert_eq!(
        reply.pointer("/value/value"),
        std::env::var("PATH").ok().map(Value::from).as_ref()
    );
}

#[test]
fn a_variable_nobody_defined_is_none() {
    let reply = read("PSEUDOLEARN_SURELY_NOT_DEFINED_ANYWHERE");
    assert_eq!(reply.pointer("/outcome"), Some(&json!("committed")));
    assert_eq!(reply.pointer("/value/value"), Some(&Value::Null));
}

#[test]
fn invalid_names_are_rejected_before_asking_the_system() {
    for name in ["", "A=B", "A\0B"] {
        let reply = read(name);
        assert_eq!(
            reply.pointer("/outcome"),
            Some(&json!("failed")),
            "{name:?}"
        );
        assert_eq!(
            reply.pointer("/value/code"),
            Some(&json!("peticion_invalida"))
        );
    }
}

#[test]
fn a_request_without_a_text_name_is_an_invalid_request() {
    let effect = json!({"effect_seq":1,"operation":"environment_get","receiver":null,
        "arguments":[],"result_capability":null});
    let reply = host().perform(&effect);
    assert_eq!(
        reply.pointer("/value/code"),
        Some(&json!("peticion_invalida"))
    );
}

#[test]
fn the_local_clock_reads_the_instant_and_a_whole_minute_offset() {
    let effect = json!({"effect_seq":1,"operation":"clock_local_now","receiver":null,
        "arguments":[],"result_capability":null});
    let reply = host().perform(&effect);
    assert_eq!(reply.pointer("/value/kind"), Some(&json!("date_time")));
    let offset = reply
        .pointer("/value/value/offset_seconds")
        .and_then(Value::as_i64);
    assert!(offset.is_some_and(|seconds| seconds.rem_euclid(60) == 0));
    let nanos = reply.pointer("/value/value/nanos").and_then(Value::as_i64);
    assert!(nanos.is_some_and(|value| value > 1_700_000_000_000_000_000));
}
