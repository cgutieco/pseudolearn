use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};

const MAIN_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/vector.pseudo";
const PROJECT_MAIN: &str =
    "Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n";
const PROJECT_LIBRARY: &str = "Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n";

#[test]
fn independent_stdio_client_materializes_closed_sources_before_transactional_rename()
-> Result<(), String> {
    let (mut child, mut client, mut server) = start_lsp()?;
    initialize_project(&mut client)?;
    read_response(&mut server, 1)?;
    open_project_document(&mut client, MAIN_URI, 3, PROJECT_MAIN)?;
    let before = request_references(&mut client, &mut server, 2)?;
    assert!(references_contain(&before, LIBRARY_URI));
    open_project_document(&mut client, LIBRARY_URI, 8, PROJECT_LIBRARY)?;
    let prepared = request_prepare_rename(&mut client, &mut server, 3)?;
    assert_eq!(
        prepared.pointer("/result/placeholder"),
        Some(&json!("Double"))
    );
    let refreshed = request_references(&mut client, &mut server, 4)?;
    assert!(references_contain(&refreshed, LIBRARY_URI));
    let renamed = request_rename(&mut client, &mut server, 5)?;
    assert_versioned_rename(&renamed)?;
    finish_lsp(client, &mut server, &mut child, 6)?;
    Ok(())
}

fn start_lsp() -> Result<(Child, ChildStdin, BufReader<ChildStdout>), String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    let client = child.stdin.take().ok_or("missing child stdin")?;
    let output = child.stdout.take().ok_or("missing child stdout")?;
    Ok((child, client, BufReader::new(output)))
}

fn initialize_project(client: &mut impl Write) -> Result<(), String> {
    let message = json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"es","initializationOptions":{"profile":"es"},"capabilities":{
            "workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}
        }}
    });
    write_message(client, &message)?;
    write_message(client, &project_snapshot())
}

fn project_snapshot() -> Value {
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{"project":{"project_id":7,"revision_id":1,"packages":[
            {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
            {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
        ],"files":[
            {"path":"app/main","source_id":1,"text":PROJECT_MAIN},
            {"path":"geo/vector","source_id":2,"text":PROJECT_LIBRARY}
        ]},"uris":{"app/main":MAIN_URI,"geo/vector":LIBRARY_URI}}
    })
}

fn open_project_document(
    client: &mut impl Write,
    uri: &str,
    version: u64,
    text: &str,
) -> Result<(), String> {
    write_message(
        client,
        &json!({
            "jsonrpc":"2.0","method":"textDocument/didOpen",
            "params":{"textDocument":{"uri":uri,"languageId":"pseudolearn","version":version,"text":text}}
        }),
    )
}

fn request_references(
    client: &mut impl Write,
    server: &mut impl BufRead,
    id: u64,
) -> Result<Value, String> {
    write_message(
        client,
        &json!({
            "jsonrpc":"2.0","id":id,"method":"textDocument/references",
            "params":{"textDocument":{"uri":MAIN_URI},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}
        }),
    )?;
    read_response(server, id)
}

fn request_prepare_rename(
    client: &mut impl Write,
    server: &mut impl BufRead,
    id: u64,
) -> Result<Value, String> {
    write_message(
        client,
        &json!({
            "jsonrpc":"2.0","id":id,"method":"textDocument/prepareRename",
            "params":{"textDocument":{"uri":MAIN_URI},"position":{"line":2,"character":9}}
        }),
    )?;
    read_response(server, id)
}

fn request_rename(
    client: &mut impl Write,
    server: &mut impl BufRead,
    id: u64,
) -> Result<Value, String> {
    write_message(
        client,
        &json!({
            "jsonrpc":"2.0","id":id,"method":"textDocument/rename",
            "params":{"textDocument":{"uri":MAIN_URI},"position":{"line":2,"character":9},"newName":"Twice"}
        }),
    )?;
    read_response(server, id)
}

fn references_contain(response: &Value, uri: &str) -> bool {
    response
        .pointer("/result")
        .and_then(Value::as_array)
        .is_some_and(|locations| {
            locations
                .iter()
                .any(|location| location.pointer("/uri") == Some(&json!(uri)))
        })
}

fn assert_versioned_rename(response: &Value) -> Result<(), String> {
    let changes = response
        .pointer("/result/documentChanges")
        .and_then(Value::as_array)
        .ok_or("rename did not return document changes")?;
    assert_eq!(changes.len(), 2);
    assert!(changes.iter().any(|edit| {
        edit.pointer("/textDocument/uri") == Some(&json!(MAIN_URI))
            && edit.pointer("/textDocument/version") == Some(&json!(3))
    }));
    assert!(changes.iter().any(|edit| {
        edit.pointer("/textDocument/uri") == Some(&json!(LIBRARY_URI))
            && edit.pointer("/textDocument/version") == Some(&json!(8))
    }));
    Ok(())
}

fn finish_lsp(
    mut client: ChildStdin,
    server: &mut impl BufRead,
    child: &mut Child,
    shutdown_id: u64,
) -> Result<(), String> {
    write_message(
        &mut client,
        &json!({"jsonrpc":"2.0","id":shutdown_id,"method":"shutdown"}),
    )?;
    assert_eq!(
        read_response(server, shutdown_id)?.get("result"),
        Some(&Value::Null)
    );
    write_message(&mut client, &json!({"jsonrpc":"2.0","method":"exit"}))?;
    drop(client);
    let status = child.wait().map_err(|error| error.to_string())?;
    assert_eq!(status.code(), Some(0));
    Ok(())
}

fn write_message(client: &mut impl Write, message: &Value) -> Result<(), String> {
    client
        .write_all(&frame(message))
        .map_err(|error| error.to_string())
}

fn frame(message: &Value) -> Vec<u8> {
    let body = serde_json::to_vec(message).unwrap_or_default();
    let mut bytes = format!("Content-Length: {}\r\n\r\n", body.len()).into_bytes();
    bytes.extend(body);
    bytes
}

fn read_response(server: &mut impl BufRead, wanted_id: u64) -> Result<Value, String> {
    loop {
        let message = read_message(server)?;
        if message.get("id") == Some(&json!(wanted_id)) {
            return Ok(message);
        }
    }
}

fn read_message(server: &mut impl BufRead) -> Result<Value, String> {
    let mut length = None;
    loop {
        let mut line = Vec::new();
        server
            .read_until(b'\n', &mut line)
            .map_err(|error| error.to_string())?;
        if line == b"\r\n" || line == b"\n" {
            break;
        }
        if line.len() > 8192 {
            return Err("response header exceeds limit".to_owned());
        }
        if let Some(value) = line.strip_prefix(b"Content-Length: ") {
            let digits = value.strip_suffix(b"\r\n").unwrap_or(value);
            let digits = digits.strip_suffix(b"\n").unwrap_or(digits);
            length = Some(
                std::str::from_utf8(digits)
                    .map_err(|error| error.to_string())?
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
