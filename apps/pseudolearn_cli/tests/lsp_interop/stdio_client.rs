use crate::framing::{read_message, write_message};
use crate::sequence::{Step, StepKind};
use crate::transcript::Transcript;
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::io::{BufRead, BufReader};
use std::process::{Child, Command, Stdio};

pub fn run(root: &str, steps: &[Step]) -> Result<Transcript, String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    let outcome = drive(&mut child, root, steps);
    if outcome.is_err() {
        let _ = child.kill();
    }
    let _ = child.wait();
    outcome
}

fn drive(child: &mut Child, root: &str, steps: &[Step]) -> Result<Transcript, String> {
    let mut client = child.stdin.take().ok_or("missing child stdin")?;
    let mut server = BufReader::new(child.stdout.take().ok_or("missing child stdout")?);
    let mut recorded = Vec::new();
    let mut diagnostics = BTreeMap::new();
    for step in steps {
        write_message(&mut client, &envelope(step))?;
        if step.kind == StepKind::Request {
            let message = await_response(&mut server, step.number, &mut diagnostics)?;
            recorded.push(json!({"step": step.number, "method": step.method, "message": message}));
        }
    }
    drop(client);
    collect_trailing(&mut server, &mut diagnostics)?;
    Transcript::from_value(
        root,
        &json!({"steps": recorded, "diagnostics": diagnostics}),
    )
}

fn envelope(step: &Step) -> Value {
    let mut message = json!({"jsonrpc": "2.0", "method": step.method});
    if step.kind == StepKind::Request {
        message["id"] = json!(step.number);
    }
    if !step.payload.is_null() {
        message["params"] = step.payload.clone();
    }
    message
}

fn await_response(
    server: &mut impl BufRead,
    wanted: u64,
    diagnostics: &mut BTreeMap<String, Value>,
) -> Result<Value, String> {
    loop {
        let message = read_message(server)?.ok_or("server closed before responding")?;
        if remember_diagnostics(&message, diagnostics) {
            continue;
        }
        if message.get("id") == Some(&json!(wanted)) && message.get("method").is_none() {
            return Ok(strip_envelope(message));
        }
    }
}

fn collect_trailing(
    server: &mut impl BufRead,
    diagnostics: &mut BTreeMap<String, Value>,
) -> Result<(), String> {
    while let Some(message) = read_message(server)? {
        remember_diagnostics(&message, diagnostics);
    }
    Ok(())
}

fn remember_diagnostics(message: &Value, diagnostics: &mut BTreeMap<String, Value>) -> bool {
    if message.get("method") != Some(&json!("textDocument/publishDiagnostics")) {
        return false;
    }
    if let Some(uri) = message.pointer("/params/uri").and_then(Value::as_str) {
        let published = message
            .pointer("/params/diagnostics")
            .cloned()
            .unwrap_or(Value::Null);
        diagnostics.insert(uri.to_owned(), published);
    }
    true
}

fn strip_envelope(mut message: Value) -> Value {
    if let Some(object) = message.as_object_mut() {
        object.remove("jsonrpc");
    }
    message
}
