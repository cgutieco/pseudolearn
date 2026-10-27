use crate::protocol::Session;
use serde_json::{Map, Value, json};

const REPLAY_MODE: &str = "replay_from_tape";
const IDENTITY_FIELDS: [&str; 3] = ["permissions", "requested_permissions", "max_tape_bytes"];

pub(crate) fn requested(request: &Value) -> bool {
    request
        .pointer("/host/grabar_y_reproducir")
        .and_then(Value::as_bool)
        .unwrap_or(false)
}

pub(crate) fn replay_request(request: &Value, live: &Value) -> Result<Value, String> {
    let tape = live
        .get("effect_tape")
        .filter(|tape| !tape.is_null())
        .ok_or_else(|| {
            format!(
                "SEE-RECORDING: live execution produced no effect tape (termination {}, diagnostics {})",
                live.get("termination").unwrap_or(&Value::Null),
                live.get("diagnostics").unwrap_or(&Value::Null)
            )
        })?;
    let mut replay = request.clone();
    let fields = replay
        .as_object_mut()
        .ok_or("SEE-RECORDING: request is not an object")?;
    fields.insert("execution_mode".to_owned(), json!(REPLAY_MODE));
    fields.insert("effect_tape".to_owned(), tape.clone());
    fields.insert("host".to_owned(), identity_host(request));
    Ok(replay)
}

fn identity_host(request: &Value) -> Value {
    let mut kept = Map::new();
    for name in IDENTITY_FIELDS {
        if let Some(value) = request.pointer(&format!("/host/{name}")) {
            kept.insert(name.to_owned(), value.clone());
        }
    }
    Value::Object(kept)
}

pub(crate) fn compare_replay(live: &Value, replayed: &Value) -> Vec<String> {
    let mut differences = Vec::new();
    for field in ["output", "termination"] {
        if live.get(field) != replayed.get(field) {
            differences.push(format!(
                "grabar_y_reproducir: {field} differs between live and replay"
            ));
        }
    }
    let calls = replayed
        .pointer("/host_observation/calls")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    if calls != 0 {
        differences.push(format!(
            "grabar_y_reproducir: replay consulted the live host {calls} times"
        ));
    }
    differences
}

pub(crate) fn verify(
    session: &mut Session,
    request: &Value,
    live: &Value,
) -> Result<Vec<String>, String> {
    let mut differences = leaked_secrets(request, live);
    if requested(request) {
        let replayed = session.request(&replay_request(request, live)?)?;
        differences.extend(compare_replay(live, &replayed));
    }
    Ok(differences)
}

fn secret_forms(value: &str) -> Vec<String> {
    let escaped = serde_json::to_string(value).unwrap_or_default();
    let decimal: Vec<String> = value.bytes().map(|byte| byte.to_string()).collect();
    let hexadecimal: String = value.bytes().map(|byte| format!("{byte:02x}")).collect();
    vec![
        value.to_owned(),
        escaped.trim_matches('"').to_owned(),
        decimal.join(","),
        hexadecimal,
    ]
}

fn tape_forms(tape: &Value) -> Vec<String> {
    let compact = tape.to_string();
    let mut forms = vec![compact.clone(), compact.replace(", ", ",")];
    let entries = tape.get("entries").and_then(Value::as_array);
    for entry in entries.into_iter().flatten() {
        let bytes: Vec<u8> = entry
            .get("payload_bytes")
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
            .filter_map(|byte| byte.as_u64().and_then(|byte| u8::try_from(byte).ok()))
            .collect();
        forms.push(String::from_utf8_lossy(&bytes).into_owned());
    }
    forms
}

pub(crate) fn leaked_secrets(request: &Value, live: &Value) -> Vec<String> {
    let secrets = request
        .pointer("/host/secrets")
        .and_then(Value::as_object)
        .into_iter()
        .flatten();
    let Some(tape) = live.get("effect_tape").filter(|tape| !tape.is_null()) else {
        return Vec::new();
    };
    let haystacks = tape_forms(tape);
    let mut leaks = Vec::new();
    for (name, secret) in secrets {
        let value = secret.get("value").and_then(Value::as_str).unwrap_or("");
        let found = !value.is_empty()
            && secret_forms(value)
                .iter()
                .any(|form| haystacks.iter().any(|haystack| haystack.contains(form.as_str())));
        if found {
            leaks.push(format!("SEE-PRIVACY: secret {name} appears in the effect tape"));
        }
    }
    leaks
}

#[cfg(test)]
mod tests {
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
        assert_eq!(replay["host"], json!({"permissions":["reloj"]}));
        assert_eq!(replay["execution_mode"], json!(REPLAY_MODE));
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
}
