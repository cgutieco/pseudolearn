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
    expected: &Value,
    live: &Value,
) -> Result<Vec<String>, String> {
    let mut differences = leaked_secrets(request, live);
    if requested(request) {
        let replayed = session.request(&replay_request(request, live)?)?;
        differences.extend(compare_replay(live, &replayed));
    }
    if let Some(expected_failure) = expected
        .pointer("/anfitrion_observado/reproduccion_fallo")
        .and_then(Value::as_str)
    {
        let mut replay = replay_request(request, live)?;
        if let Some(alteration) = request
            .pointer("/host/alterar_cinta")
            .and_then(Value::as_str)
        {
            apply_alteration(&mut replay, alteration);
        }
        let replayed = session.request(&replay)?;
        differences.extend(compare_replay_failure(expected_failure, &replayed));
    }
    Ok(differences)
}

pub(crate) fn apply_alteration(replay: &mut Value, alteration: &str) {
    match alteration {
        "truncar_entrada" => {
            if let Some(entries) = replay
                .pointer_mut("/effect_tape/entries")
                .and_then(Value::as_array_mut)
            {
                entries.pop();
            }
        }
        "corromper_hash" => {
            if let Some(hash) = replay.pointer_mut("/effect_tape/entries/0/entry_hash") {
                *hash = json!("0000000000000000000000000000000000000000000000000000000000000000");
            }
        }
        "corromper_payload" => {
            if let Some(payload) = replay
                .pointer_mut("/effect_tape/entries/0/payload_bytes")
                .and_then(Value::as_array_mut)
            {
                payload.push(json!(255));
            }
        }
        "cambiar_semilla" => {
            if let Some(fields) = replay.as_object_mut() {
                fields.insert("seed".to_owned(), json!(999_999));
            }
        }
        _ => {}
    }
}

pub(crate) fn compare_replay_failure(expected_code: &str, replayed: &Value) -> Vec<String> {
    let mut differences = Vec::new();
    let kind = replayed.pointer("/termination/kind").and_then(Value::as_str);
    let code = replayed.pointer("/termination/code").and_then(Value::as_str);
    if kind != Some("failed") || code != Some(expected_code) {
        differences.push(format!(
            "reproduccion_fallo: expected failed/{expected_code}, got {kind:?}/{code:?}"
        ));
    }
    let calls = replayed
        .pointer("/host_observation/calls")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    if calls != 0 {
        differences.push(format!(
            "reproduccion_fallo: rejected replay consulted the live host {calls} times"
        ));
    }
    differences
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
#[path = "recording_replay_tests.rs"]
mod recording_replay_tests;
