use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::process::{Child, ChildStdin, Command, Stdio};
use std::sync::mpsc::{Receiver, channel};
use std::thread;
use std::time::{Duration, Instant};

const MAIN_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/vector.pseudo";
const MAIN_TEXT: &str =
    "Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n";
const LIBRARY_TEXT: &str = "Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n";
const RESPONSE_TIMEOUT: Duration = Duration::from_secs(60);
const CLIENT_FILE_COUNT: usize = 600;

struct Session {
    child: Child,
    client: ChildStdin,
    server: Receiver<Result<Value, String>>,
}

#[test]
fn cancelled_costly_rename_is_answered_before_the_full_query_finishes() -> Result<(), String> {
    let mut session = start_project_session(CLIENT_FILE_COUNT)?;
    let full_started = Instant::now();
    send(&mut session, &rename_request(10, "Twice"))?;
    let full = read_response(&mut session.server, 10)?;
    let full_elapsed = full_started.elapsed();
    assert!(full.pointer("/result/documentChanges").is_some());

    let cancelled_started = Instant::now();
    send(&mut session, &rename_request(11, "Twice"))?;
    send(
        &mut session,
        &json!({"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":11}}),
    )?;
    let cancelled = read_response(&mut session.server, 11)?;
    let cancelled_elapsed = cancelled_started.elapsed();
    assert_eq!(cancelled.pointer("/error/code"), Some(&json!(-32800)));
    assert!(cancelled.get("result").is_none());
    assert!(cancelled_elapsed <= full_elapsed + Duration::from_millis(50));

    send(&mut session, &references_request(12))?;
    let after = read_response(&mut session.server, 12)?;
    assert!(after.pointer("/result").is_some_and(Value::is_array));
    finish(session, 13)
}

#[test]
fn cancelling_an_unknown_request_leaves_the_session_usable() -> Result<(), String> {
    let mut session = start_project_session(1)?;
    send(
        &mut session,
        &json!({"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":999}}),
    )?;
    send(&mut session, &references_request(2))?;
    let answer = read_response(&mut session.server, 2)?;
    assert!(answer.pointer("/result").is_some_and(Value::is_array));
    finish(session, 3)
}

#[test]
fn open_notification_burst_does_not_end_the_session() -> Result<(), String> {
    let mut session = start_project_session(0)?;
    for index in 0..100 {
        let uri = format!("file:///burst/note{index}.pseudo");
        open_document(&mut session, &uri, 1, MAIN_TEXT)?;
    }
    send(&mut session, &references_request(2))?;
    let answer = read_response(&mut session.server, 2)?;
    assert!(answer.pointer("/result").is_some_and(Value::is_array));
    finish(session, 3)
}

#[test]
fn disconnect_without_exit_ends_with_failure_and_a_restart_recovers() -> Result<(), String> {
    let mut first = start_project_session(1)?;
    send(&mut first, &references_request(2))?;
    read_response(&mut first.server, 2)?;
    let Session {
        mut child, client, ..
    } = first;
    drop(client);
    let status = child.wait().map_err(|error| error.to_string())?;
    assert_eq!(status.code(), Some(1));

    let mut second = start_project_session(1)?;
    send(&mut second, &references_request(2))?;
    let answer = read_response(&mut second.server, 2)?;
    assert!(answer.pointer("/result").is_some_and(Value::is_array));
    finish(second, 3)
}

#[test]
fn rename_battery_applies_valid_names_and_rejects_the_rest_without_edits() -> Result<(), String> {
    let mut session = start_project_session(0)?;
    send(&mut session, &rename_request(2, "Twice"))?;
    let valid = read_response(&mut session.server, 2)?;
    let changes = valid
        .pointer("/result/documentChanges")
        .and_then(Value::as_array)
        .ok_or("valid rename returned no document changes")?;
    assert!(changes.len() >= 2);
    assert!(
        changes
            .iter()
            .any(|change| { change.pointer("/textDocument/uri") == Some(&json!(LIBRARY_URI)) })
    );

    for (identifier, name) in [(3, "Escribir"), (4, "1invalid"), (5, "")] {
        send(&mut session, &rename_request(identifier, name))?;
        let rejected = read_response(&mut session.server, identifier)?;
        assert_eq!(rejected.pointer("/error/code"), Some(&json!(-32602)));
        assert!(rejected.get("result").is_none());
    }
    finish(session, 6)
}

fn spawn_session() -> Result<Session, String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    let client = child.stdin.take().ok_or("missing child stdin")?;
    let output = child.stdout.take().ok_or("missing child stdout")?;
    let (sender, server) = channel();
    thread::spawn(move || {
        let mut reader = BufReader::new(output);
        loop {
            let message = read_message(&mut reader);
            let failed = message.is_err();
            if sender.send(message).is_err() || failed {
                break;
            }
        }
    });
    Ok(Session {
        child,
        client,
        server,
    })
}

fn start_project_session(extra_files: usize) -> Result<Session, String> {
    let mut session = spawn_session()?;
    send(&mut session, &initialize_request())?;
    read_response(&mut session.server, 1)?;
    send(&mut session, &snapshot_notification(extra_files))?;
    open_document(&mut session, MAIN_URI, 3, MAIN_TEXT)?;
    send(&mut session, &references_request(90))?;
    read_response(&mut session.server, 90)?;
    open_document(&mut session, LIBRARY_URI, 8, LIBRARY_TEXT)?;
    for index in 0..extra_files {
        open_document(&mut session, &client_uri(index), 1, &client_text(index))?;
        let barrier = 1000 + index as u64;
        send(&mut session, &references_request(barrier))?;
        read_response(&mut session.server, barrier)?;
    }
    Ok(session)
}

fn client_uri(index: usize) -> String {
    format!("file:///client/user{index}.pseudo")
}

fn client_text(index: usize) -> String {
    format!(
        "Importar geo.vector.Double;\nPublico SubProceso Use{index}() Como Entero\nRetornar Double(2);\nFinSubProceso\n"
    )
}

fn initialize_request() -> Value {
    json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"es","initializationOptions":{"profile":"es"},"capabilities":{
            "workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}
        }}
    })
}

fn snapshot_notification(extra_files: usize) -> Value {
    let mut files = vec![
        json!({"path":"app/main","source_id":1,"text":MAIN_TEXT}),
        json!({"path":"geo/vector","source_id":2,"text":LIBRARY_TEXT}),
    ];
    let mut uris = json!({"app/main":MAIN_URI,"geo/vector":LIBRARY_URI});
    for index in 0..extra_files {
        let path = format!("client/user{index}");
        files.push(json!({"path":path,"source_id":index + 10,"text":client_text(index)}));
        uris[&path] = json!(client_uri(index));
    }
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{"project":{"project_id":7,"revision_id":1,"packages":[
            {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
            {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}},
            {"name":"client","root":"client","kind":"library","entries":[],"dependencies":{"geo":"geo"}}
        ],"files":files},"uris":uris}
    })
}

fn open_document(session: &mut Session, uri: &str, version: u64, text: &str) -> Result<(), String> {
    send(
        session,
        &json!({
            "jsonrpc":"2.0","method":"textDocument/didOpen",
            "params":{"textDocument":{"uri":uri,"languageId":"pseudolearn","version":version,"text":text}}
        }),
    )
}

fn references_request(identifier: u64) -> Value {
    json!({
        "jsonrpc":"2.0","id":identifier,"method":"textDocument/references",
        "params":{"textDocument":{"uri":MAIN_URI},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}
    })
}

fn rename_request(identifier: u64, new_name: &str) -> Value {
    json!({
        "jsonrpc":"2.0","id":identifier,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":MAIN_URI},"position":{"line":2,"character":9},"newName":new_name}
    })
}

fn finish(mut session: Session, shutdown_id: u64) -> Result<(), String> {
    send(
        &mut session,
        &json!({"jsonrpc":"2.0","id":shutdown_id,"method":"shutdown"}),
    )?;
    assert_eq!(
        read_response(&mut session.server, shutdown_id)?.get("result"),
        Some(&Value::Null)
    );
    send(&mut session, &json!({"jsonrpc":"2.0","method":"exit"}))?;
    drop(session.client);
    let status = session.child.wait().map_err(|error| error.to_string())?;
    assert_eq!(status.code(), Some(0));
    Ok(())
}

fn send(session: &mut Session, message: &Value) -> Result<(), String> {
    let body = serde_json::to_vec(message).map_err(|error| error.to_string())?;
    let mut bytes = format!("Content-Length: {}\r\n\r\n", body.len()).into_bytes();
    bytes.extend(body);
    session
        .client
        .write_all(&bytes)
        .map_err(|error| error.to_string())
}

fn read_response(
    server: &mut Receiver<Result<Value, String>>,
    wanted_id: u64,
) -> Result<Value, String> {
    loop {
        let message = server
            .recv_timeout(RESPONSE_TIMEOUT)
            .map_err(|error| error.to_string())??;
        if message.get("id") == Some(&json!(wanted_id)) && message.get("method").is_none() {
            return Ok(message);
        }
    }
}

fn read_message(server: &mut impl BufRead) -> Result<Value, String> {
    let mut length = None;
    loop {
        let mut line = Vec::new();
        let read = server
            .read_until(b'\n', &mut line)
            .map_err(|error| error.to_string())?;
        if read == 0 {
            return Err("server closed the stream".to_owned());
        }
        if line == b"\r\n" || line == b"\n" {
            break;
        }
        if let Some(value) = line.strip_prefix(b"Content-Length: ") {
            let digits = String::from_utf8_lossy(value);
            length = Some(
                digits
                    .trim()
                    .parse::<usize>()
                    .map_err(|error| error.to_string())?,
            );
        }
    }
    let mut body = vec![0; length.ok_or("response has no content length")?];
    server
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    serde_json::from_slice(&body).map_err(|error| error.to_string())
}
