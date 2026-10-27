use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const WRITER: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"escritura\");\nRetornar file.EscribirTexto(\"s3cr3t\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const READER: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir first Como Cadena <- Propagar file.LeerTexto();\nDefinir second Como Cadena <- Propagar file.LeerTexto();\nDefinir third Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(3);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn record(program: &str, host: Value) -> Value {
    let request = json!({"kind":"execute","program":program,"profile":"es","strictness":"strict",
        "inputs":[],"seed":42,"observe":"none","host":host});
    let response = ApiSession::default().call(
        "record",
        &json!({"request":request,"options":{"capture_states":false,"batch_size":100_000}}),
    );
    response.get("value").cloned().unwrap_or(response)
}

fn secret_host(value: &str, key: &str) -> Value {
    json!({"permissions":["archivos_escritura"],"requested_permissions":["archivos_escritura"],
        "secrets":{"token":{"key_id":"k1","value":value}},"secret_keys":{"k1":key}})
}

fn reader_host(budget: Option<usize>) -> Value {
    let mut host = json!({"permissions":["archivos_lectura"],"requested_permissions":["archivos_lectura"],
        "files":{"a":"hola"}});
    if let (Some(fields), Some(budget)) = (host.as_object_mut(), budget) {
        fields.insert("max_tape_bytes".to_owned(), json!(budget));
    }
    host
}

fn replay_rejection(program: &str, tape: &Value, host: &Value) -> Option<String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let identity_host = json!({"permissions":host.get("permissions").cloned().unwrap_or(Value::Null)});
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,"profile":"es",
            "strictness":"strict","seed":42,"host":identity_host,
            "execution_mode":"replay_from_tape","effect_tape":tape}),
    );
    started.pointer("/failure/detail").and_then(Value::as_str).map(str::to_owned)
}

fn status(recorded: &Value) -> Option<&str> {
    recorded.pointer("/effect_tape/status").and_then(Value::as_str)
}

fn leaks(serialized: &str, secret: &str) -> bool {
    let decimal: Vec<String> = secret.bytes().map(|byte| byte.to_string()).collect();
    let hexadecimal: String = secret.bytes().map(|byte| format!("{byte:02x}")).collect();
    [secret.to_owned(), decimal.join(","), decimal.join(", "), hexadecimal]
        .iter()
        .any(|form| serialized.contains(form.as_str()))
}

#[test]
fn secret_argument_is_recorded_as_a_reference_and_the_tape_is_redacted() {
    let recorded = record(WRITER, secret_host("s3cr3t", "clave-privada"));
    assert_eq!(recorded.get("output"), Some(&json!("6\n")), "{recorded}");
    assert_eq!(status(&recorded), Some("non_reproducible_redacted"), "{recorded}");
    let tape = recorded.get("effect_tape").cloned().unwrap_or(Value::Null);
    let serialized = tape.to_string();
    assert!(!leaks(&serialized, "s3cr3t"), "{serialized}");
    assert!(!serialized.contains("clave-privada"), "{serialized}");
    let references: Vec<&str> = tape
        .get("entries")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(|entry| entry.get("secret_reference").and_then(Value::as_str))
        .collect();
    assert_eq!(references.len(), 1, "{serialized}");
    assert!(references.first().is_some_and(|reference| reference.starts_with("secret:k1:")), "{references:?}");
}

#[test]
fn reference_depends_on_both_the_value_and_the_key() {
    let reference = |value: &str, key: &str| {
        record(WRITER, secret_host(value, key))
            .pointer("/effect_tape/entries")
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
            .find_map(|entry| entry.get("secret_reference").and_then(Value::as_str).map(str::to_owned))
    };
    let base = reference("s3cr3t", "clave-privada");
    assert!(base.is_some());
    assert_eq!(base, reference("s3cr3t", "clave-privada"));
    assert_ne!(base, reference("s3cr3t", "otra-clave"));
}

#[test]
fn write_without_the_secret_value_keeps_the_tape_reproducible() {
    let recorded = record(WRITER, secret_host("not-written", "clave-privada"));
    assert_eq!(status(&recorded), Some("reproducible"), "{recorded}");
}

#[test]
fn redacted_tape_cannot_be_replayed() {
    let recorded = record(WRITER, secret_host("s3cr3t", "clave-privada"));
    let tape = recorded.get("effect_tape").cloned().unwrap_or(Value::Null);
    let rejection = replay_rejection(WRITER, &tape, &secret_host("s3cr3t", "clave-privada"));
    assert_eq!(rejection.as_deref(), Some("Invalid protocol: replay_non_reproducible"));
}

fn smallest_complete_budget() -> Result<usize, String> {
    (200..6000)
        .find(|budget| status(&record(READER, reader_host(Some(*budget)))) == Some("reproducible"))
        .ok_or_else(|| "no budget below 6000 keeps the tape reproducible".to_owned())
}

#[test]
fn tape_budget_boundary_switches_between_reproducible_and_truncated() -> Result<(), String> {
    let exact = smallest_complete_budget()?;
    let below = record(READER, reader_host(Some(exact.saturating_sub(1))));
    let exact_run = record(READER, reader_host(Some(exact)));
    let above = record(READER, reader_host(Some(exact.saturating_add(1))));
    assert_eq!(status(&below), Some("non_reproducible_truncated"));
    assert_eq!(status(&exact_run), Some("reproducible"));
    assert_eq!(status(&above), Some("reproducible"));
    Ok(())
}

#[test]
fn live_execution_continues_when_only_the_tape_runs_out_of_budget() -> Result<(), String> {
    let exact = smallest_complete_budget()?;
    let truncated = record(READER, reader_host(Some(exact.saturating_sub(1))));
    let complete = record(READER, reader_host(None));
    assert_eq!(truncated.get("output"), complete.get("output"));
    assert_eq!(truncated.pointer("/termination/kind"), Some(&json!("completed")));
    let kept = |recorded: &Value| recorded.pointer("/effect_tape/entries").and_then(Value::as_array).map(Vec::len);
    assert!(kept(&truncated) < kept(&complete));
    Ok(())
}

#[test]
fn truncated_tape_cannot_be_replayed() -> Result<(), String> {
    let exact = smallest_complete_budget()?;
    let truncated = record(READER, reader_host(Some(exact.saturating_sub(1))));
    let tape = truncated.get("effect_tape").cloned().unwrap_or(Value::Null);
    let rejection = replay_rejection(READER, &tape, &reader_host(None));
    assert_eq!(rejection.as_deref(), Some("Invalid protocol: replay_non_reproducible"));
    Ok(())
}

#[test]
fn zero_budget_truncates_from_the_first_effect() {
    let recorded = record(READER, reader_host(Some(0)));
    assert_eq!(status(&recorded), Some("non_reproducible_truncated"), "{recorded}");
    assert_eq!(recorded.pointer("/termination/kind"), Some(&json!("completed")));
}

#[test]
fn console_output_containing_the_secret_is_redacted() {
    let program = "Algoritmo Main\nEscribir \"s3cr3t\";\nFinAlgoritmo\n";
    let recorded = record(program, secret_host("s3cr3t", "clave-privada"));
    assert_eq!(recorded.get("output"), Some(&json!("s3cr3t\n")), "{recorded}");
    let serialized = recorded.get("effect_tape").map(Value::to_string).unwrap_or_default();
    assert!(!leaks(&serialized, "s3cr3t"), "{serialized}");
    assert_eq!(status(&recorded), Some("non_reproducible_redacted"), "{recorded}");
}

#[test]
fn input_read_containing_the_secret_is_redacted() {
    let program = "Algoritmo Main\nDefinir Mutable word Como Cadena <- \"\";\nLeer word;\nEscribir 1;\nFinAlgoritmo\n";
    let request = json!({"kind":"execute","program":program,"profile":"es","strictness":"strict",
        "inputs":["s3cr3t"],"seed":42,"observe":"none","host":secret_host("s3cr3t", "clave-privada")});
    let response = ApiSession::default().call(
        "record",
        &json!({"request":request,"options":{"capture_states":false,"batch_size":100_000}}),
    );
    let recorded = response.get("value").cloned().unwrap_or(response);
    assert_eq!(recorded.pointer("/termination/kind"), Some(&json!("completed")), "{recorded}");
    let serialized = recorded.get("effect_tape").map(Value::to_string).unwrap_or_default();
    assert!(serialized.contains("\"entries\":[{"), "{serialized}");
    assert!(!leaks(&serialized, "s3cr3t"), "{serialized}");
}
