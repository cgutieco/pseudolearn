use pseudolearn_api::ApiSession;
use pseudolearn_api::tape_wire::{tape_from_value, tape_to_value};
use pseudolearn_runtime::{EffectTape, TapeEntry};
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir second Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir left Como Cadena <- Propagar file.LeerTexto();\nDefinir right Como Cadena <- Propagar second.LeerTexto();\nRetornar Exito(left + right);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn live_host() -> Value {
    json!({"permissions":["archivos_lectura"],"files":{"a":"hola","b":"mundo"}})
}

fn identity_host() -> Value {
    json!({"permissions":["archivos_lectura"]})
}

fn recorded_tape() -> Result<Value, String> {
    let recording = ApiSession::default().call(
        "record",
        &json!({"request":{"program":PROGRAM,"profile":"es","strictness":"strict","seed":42,"host":live_host()}}),
    );
    recording
        .pointer("/value/effect_tape")
        .cloned()
        .ok_or_else(|| format!("missing tape: {recording}"))
}

fn rebuilt(tape: &Value, change: impl Fn(&mut Vec<TapeEntry>)) -> Result<Value, String> {
    let original = tape_from_value(tape).map_err(|failure| format!("{failure:?}"))?;
    let mut entries = original.entries().to_vec();
    change(&mut entries);
    let mut copy = EffectTape::new(original.identity.clone());
    for entry in entries {
        copy.append(entry);
    }
    Ok(tape_to_value(&copy))
}

fn replay(mode: &str, program: &str, seed: i64, tape: &Value) -> Value {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,"profile":"es",
            "strictness":"strict","seed":seed,"host":identity_host(),
            "execution_mode":mode,"effect_tape":tape}),
    );
    if started.get("failure").is_some() {
        return started;
    }
    session.call(
        "advance",
        &json!({"resource":started.pointer("/value/resource"),"batch_size":1000}),
    )
}

fn rejection(response: &Value) -> Option<&str> {
    response.pointer("/failure/detail").and_then(Value::as_str)
}

fn assert_rejected(mode: &str, tape: &Value, code: &str) {
    let response = replay(mode, PROGRAM, 42, tape);
    assert_eq!(
        rejection(&response),
        Some(format!("Invalid protocol: {code}").as_str()),
        "{mode}: {response}"
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    assert!(response.pointer("/value/output").is_none(), "{response}");
}

#[test]
fn intact_tape_replays_in_both_isolated_modes_without_host_calls() -> Result<(), String> {
    let tape = recorded_tape()?;
    for mode in ["replay_from_tape", "history_seek"] {
        let response = replay(mode, PROGRAM, 42, &tape);
        assert_eq!(
            response.pointer("/value/output"),
            Some(&json!("holamundo\n")),
            "{response}"
        );
        assert_eq!(
            response.pointer("/value/host_observation/calls"),
            Some(&json!(0))
        );
    }
    Ok(())
}

#[test]
fn changed_source_seed_or_permissions_reject_with_identity_mismatch() -> Result<(), String> {
    let tape = recorded_tape()?;
    for mode in ["replay_from_tape", "history_seek"] {
        let other_source = format!("{PROGRAM}\n");
        let response = replay(mode, &other_source, 42, &tape);
        assert_eq!(
            rejection(&response),
            Some("Invalid protocol: replay_identity_mismatch")
        );
        let response = replay(mode, PROGRAM, 43, &tape);
        assert_eq!(
            rejection(&response),
            Some("Invalid protocol: replay_identity_mismatch")
        );
    }
    Ok(())
}

#[test]
fn tape_ending_early_rejects_with_truncated_tape() -> Result<(), String> {
    let tape = recorded_tape()?;
    let without_last = rebuilt(&tape, |entries| {
        entries.pop();
    })?;
    let empty = rebuilt(&tape, Vec::clear)?;
    for mode in ["replay_from_tape", "history_seek"] {
        assert_rejected(mode, &without_last, "replay_truncated_tape");
        assert_rejected(mode, &empty, "replay_truncated_tape");
    }
    Ok(())
}

#[test]
fn unexpected_effect_arguments_or_order_reject_with_divergence() -> Result<(), String> {
    let tape = recorded_tape()?;
    let other_digest = rebuilt(&tape, |entries| {
        if let Some(entry) = entries.last_mut() {
            entry.request_digest.push_str("-altered");
        }
    })?;
    let swapped = rebuilt(&tape, |entries| {
        entries.swap(1, 2);
        for (index, entry) in entries.iter_mut().enumerate() {
            entry.effect_seq = u64::try_from(index).map_or(0, |index| index + 1);
        }
    })?;
    let surplus = rebuilt(&tape, |entries| {
        if let Some(first) = entries.first().cloned() {
            let mut extra = first;
            extra.effect_seq = u64::try_from(entries.len()).map_or(0, |count| count + 1);
            entries.push(extra);
        }
    })?;
    for altered in [&other_digest, &swapped, &surplus] {
        assert_rejected("replay_from_tape", altered, "replay_divergence");
    }
    Ok(())
}

#[test]
fn altered_hash_payload_sequence_schema_or_fields_reject_as_corrupted() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut hash = tape.clone();
    let mut payload = tape.clone();
    let mut sequence = tape.clone();
    let mut unknown = tape.clone();
    *hash.pointer_mut("/entries/0/entry_hash").ok_or("hash")? = json!("00");
    *payload
        .pointer_mut("/entries/1/payload_bytes/0")
        .ok_or("payload")? = json!(255);
    *sequence
        .pointer_mut("/entries/1/effect_seq")
        .ok_or("sequence")? = json!(5);
    unknown
        .as_object_mut()
        .ok_or("object")?
        .insert("surprise".to_owned(), json!(1));
    for altered in [&hash, &payload, &sequence, &unknown] {
        assert_rejected("replay_from_tape", altered, "replay_corrupted_tape");
        assert_rejected("history_seek", altered, "replay_corrupted_tape");
    }
    Ok(())
}

#[test]
fn unknown_schema_version_is_not_a_replay_error() -> Result<(), String> {
    let mut tape = recorded_tape()?;
    *tape.pointer_mut("/format").ok_or("format")? = json!("pseudolearn.tape/v9");
    let response = replay("replay_from_tape", PROGRAM, 42, &tape);
    assert_eq!(
        response.pointer("/failure/family"),
        Some(&json!("version")),
        "{response}"
    );
    Ok(())
}

#[test]
fn incomplete_or_truncated_budget_tape_rejects_as_non_reproducible() -> Result<(), String> {
    let tape = recorded_tape()?;
    let original = tape_from_value(&tape).map_err(|failure| format!("{failure:?}"))?;
    let mut incomplete = original.clone();
    incomplete.mark_incomplete();
    let mut first_only = EffectTape::new(original.identity.clone());
    first_only.append(original.entries().first().ok_or("missing entry")?.clone());
    let budget = pseudolearn_runtime::encode_effect_tape(&first_only)
        .map_err(|failure| format!("{failure:?}"))?
        .len()
        .saturating_add(1);
    let mut tiny = EffectTape::with_budget(original.identity.clone(), budget);
    for entry in original.entries() {
        tiny.append(entry.clone());
    }
    assert!(!tiny.is_reproducible());
    assert!(tiny.entries().len() < original.entries().len());
    for sealed in [tape_to_value(&incomplete), tape_to_value(&tiny)] {
        assert_rejected("replay_from_tape", &sealed, "replay_non_reproducible");
    }
    Ok(())
}

#[test]
fn replay_rejects_external_input_without_consulting_anything() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":PROGRAM}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":PROGRAM,"profile":"es",
            "strictness":"strict","seed":42,"host":identity_host(),
            "execution_mode":"replay_from_tape","effect_tape":tape}),
    );
    let rejected = session.call(
        "input",
        &json!({"resource":started.pointer("/value/resource"),"text":"x"}),
    );
    assert_eq!(
        rejected.pointer("/failure/family"),
        Some(&json!("usage")),
        "{rejected}"
    );
    Ok(())
}
