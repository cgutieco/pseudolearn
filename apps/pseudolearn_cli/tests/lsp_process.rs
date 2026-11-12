use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::process::{Command, Stdio};

#[test]
fn independent_stdio_client_navigates_and_reads_semantic_tokens() -> Result<(), String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    let mut client = child.stdin.take().ok_or("missing child stdin")?;
    let output = child.stdout.take().ok_or("missing child stdout")?;
    let mut server = BufReader::new(output);
    initialize(&mut client)?;
    let initialized = read_response(&mut server, 1)?;
    assert!(
        initialized
            .pointer("/result/capabilities/renameProvider/prepareProvider")
            .is_some()
    );
    open_document(&mut client)?;
    verify_project_queries(&mut client, &mut server)?;
    shutdown(&mut client)?;
    assert_eq!(
        read_response(&mut server, 4)?.get("result"),
        Some(&Value::Null)
    );
    client
        .write_all(&frame(&json!({"jsonrpc":"2.0","method":"exit"})))
        .map_err(|error| error.to_string())?;
    drop(client);
    let status = child.wait().map_err(|error| error.to_string())?;
    assert_eq!(status.code(), Some(0));
    Ok(())
}

fn verify_project_queries(
    client: &mut impl Write,
    server: &mut impl BufRead,
) -> Result<(), String> {
    let definition = request_definition(client, server)?;
    assert_eq!(
        definition.pointer("/result/uri"),
        Some(&json!("file:///main.pseudo"))
    );
    let semantic = request_semantic_tokens(client, server)?;
    assert!(
        semantic
            .pointer("/result/data")
            .and_then(Value::as_array)
            .is_some_and(|tokens| !tokens.is_empty())
    );
    Ok(())
}

fn initialize(client: &mut impl Write) -> Result<(), String> {
    let message = json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","initializationOptions":{"profile":"en"},"capabilities":{
            "textDocument":{"completion":{"completionItem":{"snippetSupport":true}},"publishDiagnostics":{"relatedInformation":true},"semanticTokens":{"requests":{"full":true}}},
            "workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}
        }}
    });
    client
        .write_all(&frame(&message))
        .map_err(|error| error.to_string())
}

fn open_document(client: &mut impl Write) -> Result<(), String> {
    let message = json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":"file:///main.pseudo","languageId":"pseudolearn","version":1,"text":"algorithm Main\ndefine count as integer <- 1;\nwrite count;\nendAlgorithm\n"}}
    });
    client
        .write_all(&frame(&message))
        .map_err(|error| error.to_string())
}

fn request_definition(client: &mut impl Write, server: &mut impl BufRead) -> Result<Value, String> {
    let message = json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/definition",
        "params":{"textDocument":{"uri":"file:///main.pseudo"},"position":{"line":2,"character":6}}
    });
    client
        .write_all(&frame(&message))
        .map_err(|error| error.to_string())?;
    read_response(server, 2)
}

fn request_semantic_tokens(
    client: &mut impl Write,
    server: &mut impl BufRead,
) -> Result<Value, String> {
    let message = json!({
        "jsonrpc":"2.0","id":3,"method":"textDocument/semanticTokens/full",
        "params":{"textDocument":{"uri":"file:///main.pseudo"}}
    });
    client
        .write_all(&frame(&message))
        .map_err(|error| error.to_string())?;
    read_response(server, 3)
}

fn shutdown(client: &mut impl Write) -> Result<(), String> {
    let message = json!({"jsonrpc":"2.0","id":4,"method":"shutdown"});
    client
        .write_all(&frame(&message))
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
