use super::*;

fn response(output: &str, calls: u64) -> Value {
    json!({"output":output,"termination":{"kind":"completed"},
        "effect_tape":{"entries":[]},"host_observation":{"calls":calls}})
}

#[test]
fn identical_replay_without_host_calls_has_no_differences() {
    assert!(compare_replay(&response("a\n", 3), &response("a\n", 0)).is_empty());
}

#[test]
fn different_output_is_reported() {
    assert_eq!(
        compare_replay(&response("a\n", 3), &response("b\n", 0)).len(),
        1
    );
}

#[test]
fn replay_that_consults_the_host_is_reported() {
    assert_eq!(
        compare_replay(&response("a\n", 3), &response("a\n", 2)).len(),
        1
    );
}

#[test]
fn replay_request_keeps_only_identity_fields_of_the_host() -> Result<(), String> {
    let request = json!({"host":{"permissions":["reloj"],"clock":[1],"grabar_y_reproducir":true}});
    let replay = replay_request(&request, &response("a\n", 1))?;
    assert_eq!(replay.get("host"), Some(&json!({"permissions":["reloj"]})));
    assert_eq!(replay.get("execution_mode"), Some(&json!(REPLAY_MODE)));
    Ok(())
}

#[test]
fn live_execution_without_tape_is_an_error() {
    let request = json!({"host":{"grabar_y_reproducir":true}});
    assert!(replay_request(&request, &json!({"effect_tape":null})).is_err());
}

fn secret_request() -> Value {
    json!({"host":{"secrets":{"token":{"key_id":"k1","value":"s3cr3t"}}}})
}

#[test]
fn tape_with_a_textual_secret_is_reported() {
    let live = json!({"effect_tape":{"entries":[{"operation":"s3cr3t"}]}});
    assert_eq!(leaked_secrets(&secret_request(), &live).len(), 1);
}

#[test]
fn tape_with_an_escaped_secret_is_reported() {
    let request = json!({"host":{"secrets":{"t":{"key_id":"k","value":"a\"b"}}}});
    let live = json!({"effect_tape":{"entries":[{"operation":"x a\"b"}]}});
    assert_eq!(leaked_secrets(&request, &live).len(), 1);
}

#[test]
fn tape_with_binary_payload_secret_is_reported() {
    let bytes: Vec<u8> = b"..s3cr3t..".to_vec();
    let live = json!({"effect_tape":{"entries":[{"payload_bytes":bytes}]}});
    assert_eq!(leaked_secrets(&secret_request(), &live).len(), 1);
}

#[test]
fn tape_with_a_hexadecimal_secret_is_reported() {
    let live = json!({"effect_tape":{"entries":[{"digest":"733363723374"}]}});
    assert_eq!(leaked_secrets(&secret_request(), &live).len(), 1);
}

#[test]
fn redacted_tape_has_no_leaks() {
    let live = json!({"effect_tape":{"entries":[{"secret_ref":{"key_id":"k1","value_hmac":"ab"}}]}});
    assert!(leaked_secrets(&secret_request(), &live).is_empty());
    assert!(leaked_secrets(&secret_request(), &json!({})).is_empty());
}

#[test]
fn flag_is_read_from_the_host_document() {
    assert!(requested(&json!({"host":{"grabar_y_reproducir":true}})));
    assert!(!requested(&json!({"host":{}})));
    assert!(!requested(&json!({})));
}

#[test]
fn tape_alterations_and_replay_failure_checks_cover_happy_and_unhappy_paths() {
    let mut replay = json!({
        "seed": 42,
        "effect_tape": {
            "entries": [
                {"entry_hash": "abc", "payload_bytes": [1, 2]},
                {"entry_hash": "def", "payload_bytes": [3]}
            ]
        }
    });
    apply_alteration(&mut replay, "truncar_entrada");
    assert_eq!(
        replay.pointer("/effect_tape/entries").and_then(Value::as_array).map(Vec::len),
        Some(1)
    );
    apply_alteration(&mut replay, "corromper_hash");
    assert_eq!(
        replay.pointer("/effect_tape/entries/0/entry_hash"),
        Some(&json!("0000000000000000000000000000000000000000000000000000000000000000"))
    );
    apply_alteration(&mut replay, "corromper_payload");
    assert_eq!(
        replay.pointer("/effect_tape/entries/0/payload_bytes"),
        Some(&json!([1, 2, 255]))
    );
    apply_alteration(&mut replay, "cambiar_semilla");
    assert_eq!(replay.get("seed"), Some(&json!(999_999)));

    let matching = json!({"termination":{"kind":"failed","code":"replay_truncated_tape"},"host_observation":{"calls":0}});
    assert!(compare_replay_failure("replay_truncated_tape", &matching).is_empty());
    let wrong_code = json!({"termination":{"kind":"failed","code":"replay_corrupted_tape"},"host_observation":{"calls":0}});
    assert_eq!(compare_replay_failure("replay_truncated_tape", &wrong_code).len(), 1);
    let called_host = json!({"termination":{"kind":"failed","code":"replay_truncated_tape"},"host_observation":{"calls":1}});
    assert_eq!(compare_replay_failure("replay_truncated_tape", &called_host).len(), 1);
}
