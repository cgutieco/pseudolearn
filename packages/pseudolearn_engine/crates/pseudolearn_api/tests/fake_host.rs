use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn library_cases_execute_and_replay_without_live_host_calls() -> Result<(), String> {
    for corpus in [
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.time.md"),
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.io.md"),
    ] {
        for block in corpus.split("```caso\n").skip(1) {
            let case: Value =
                serde_json::from_str(block.split("\n```").next().ok_or("missing body")?)
                    .map_err(|error| error.to_string())?;
            let Some(host) = case.get("anfitrion") else {
                continue;
            };
            if case.pointer("/espera/fallo").is_some() {
                continue;
            }
            for profile in ["es", "en"] {
                run_case(&case, profile, host)?;
            }
        }
    }
    Ok(())
}

fn run_case(case: &Value, profile: &str, host: &Value) -> Result<(), String> {
    let program = case
        .get("programas")
        .and_then(|programs| programs.get(profile))
        .ok_or("missing program")?;
    let request = json!({"program":program,"profile":profile,"strictness":"strict","host":host});
    let mut session = ApiSession::default();
    let record = session.call("record", &json!({"request":request,"options":{"capture_states":true,"seek_every_event":true,"batch_size":1000}}));
    let value = record
        .get("value")
        .ok_or_else(|| format!("{:?} {profile}: {record}", case.get("id")))?;
    assert_eq!(
        value.get("output"),
        case.pointer("/espera/salida"),
        "{:?} {profile}: {record}",
        case.get("id")
    );
    assert_eq!(
        value.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{record}"
    );
    let mut replay_request = request;
    let fields = replay_request
        .as_object_mut()
        .ok_or("request is not an object")?;
    fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
    fields.insert(
        "effect_tape".to_owned(),
        value.get("effect_tape").cloned().ok_or("missing tape")?,
    );
    let replay = session.call(
        "record",
        &json!({"request":replay_request,"options":{"capture_states":false,"batch_size":1000}}),
    );
    assert_eq!(
        replay.pointer("/value/output"),
        value.get("output"),
        "{replay}"
    );
    assert_eq!(
        replay.pointer("/value/host_observation/calls"),
        Some(&json!(0)),
        "{replay}"
    );
    Ok(())
}
