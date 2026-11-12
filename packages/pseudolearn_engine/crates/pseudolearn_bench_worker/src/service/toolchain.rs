use crate::service::corpus::machine_description;
use crate::service::statistics::summarize;
use pseudolearn_api::service::LspServer;
use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::Instant;

const SAMPLES: usize = 30;
const WARMUP: usize = 3;
const HELLO: &str = "Algoritmo Hola\n  Escribir \"hola\";\nFinAlgoritmo\n";

struct Workspace {
    directory: PathBuf,
    small: PathBuf,
    large: PathBuf,
    large_text: String,
}

fn prepare() -> Result<Workspace, String> {
    let directory = std::env::temp_dir().join(format!("pseudo-e20-{}", std::process::id()));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let workload = crate::workloads::load()?
        .into_iter()
        .find(|entry| entry.name == "generated-es-strict-1000-false")
        .ok_or("Missing 1000-line workload")?;
    let large_text = workload
        .requests
        .first()
        .map(|request| request.program.clone())
        .ok_or("Empty workload")?;
    let small = directory.join("hola.pseudo");
    let large = directory.join("mil.pseudo");
    std::fs::write(&small, HELLO).map_err(|error| error.to_string())?;
    std::fs::write(&large, &large_text).map_err(|error| error.to_string())?;
    Ok(Workspace {
        directory,
        small,
        large,
        large_text,
    })
}

fn timed_process(binary: &Path, arguments: &[&str]) -> Result<f64, String> {
    let started = Instant::now();
    let output = Command::new(binary)
        .args(arguments)
        .output()
        .map_err(|error| error.to_string())?;
    let elapsed = started.elapsed().as_secs_f64() * 1000.0;
    if output.status.code() != Some(0) {
        return Err(format!(
            "pseudo {arguments:?} failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    Ok(elapsed)
}

fn measure_command(label: &str, binary: &Path, arguments: &[&str]) -> Result<Value, String> {
    for _ in 0..WARMUP {
        timed_process(binary, arguments)?;
    }
    let mut samples = Vec::new();
    for _ in 0..SAMPLES {
        samples.push(timed_process(binary, arguments)?);
    }
    let summary = summarize(&samples).ok_or("No samples")?;
    Ok(json!({ "operation": label, "samples": SAMPLES, "latency_ms": summary.to_json() }))
}

fn frame(payload: &Value) -> Vec<u8> {
    let body = payload.to_string();
    format!("Content-Length: {}\r\n\r\n{body}", body.len()).into_bytes()
}

fn read_frame<Reader: BufRead>(reader: &mut Reader) -> Result<Value, String> {
    let mut length = 0usize;
    loop {
        let mut line = String::new();
        if reader
            .read_line(&mut line)
            .map_err(|error| error.to_string())?
            == 0
        {
            return Err("LSP stream closed".to_owned());
        }
        let trimmed = line.trim();
        if trimmed.is_empty() {
            break;
        }
        if let Some(value) = trimmed.strip_prefix("Content-Length:") {
            length = value
                .trim()
                .parse()
                .map_err(|_| "Bad Content-Length".to_owned())?;
        }
    }
    let mut body = vec![0u8; length];
    reader
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    serde_json::from_slice(&body).map_err(|error| error.to_string())
}

fn lsp_session(binary: &Path) -> Result<f64, String> {
    let started = Instant::now();
    let mut child = Command::new(binary)
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    let mut input = child.stdin.take().ok_or("Missing stdin")?;
    let mut reader = BufReader::new(child.stdout.take().ok_or("Missing stdout")?);
    let messages = [
        json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}),
        json!({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{
            "uri":"file:///hola.pseudo","languageId":"pseudolearn","version":1,"text":HELLO}}}),
    ];
    for message in &messages {
        input
            .write_all(&frame(message))
            .map_err(|error| error.to_string())?;
    }
    input.flush().map_err(|error| error.to_string())?;
    let mut diagnostics_seen = false;
    while !diagnostics_seen {
        let answer = read_frame(&mut reader)?;
        diagnostics_seen =
            answer.get("method").and_then(Value::as_str) == Some("textDocument/publishDiagnostics");
    }
    let elapsed = started.elapsed().as_secs_f64() * 1000.0;
    for message in [
        json!({"jsonrpc":"2.0","id":2,"method":"shutdown"}),
        json!({"jsonrpc":"2.0","method":"exit"}),
    ] {
        input
            .write_all(&frame(&message))
            .map_err(|error| error.to_string())?;
    }
    drop(input);
    child.wait().map_err(|error| error.to_string())?;
    Ok(elapsed)
}

fn measure_lsp_startup(binary: &Path) -> Result<Value, String> {
    for _ in 0..WARMUP {
        lsp_session(binary)?;
    }
    let mut samples = Vec::new();
    for _ in 0..SAMPLES {
        samples.push(lsp_session(binary)?);
    }
    let summary = summarize(&samples).ok_or("No samples")?;
    Ok(json!({
        "operation": "pseudo lsp (spawn + initialize + didOpen + diagnostics)",
        "samples": SAMPLES,
        "latency_ms": summary.to_json(),
    }))
}

fn measure_warm_requests(text: &str) -> Result<Vec<Value>, String> {
    let mut server = LspServer::new();
    server.handle_message(
        &json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}),
    );
    server.handle_message(
        &json!({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{
        "uri":"file:///mil.pseudo","languageId":"pseudolearn","version":1,"text":text}}}),
    );
    let position = json!({"line": 5, "character": 4});
    let mut report = Vec::new();
    for (method, label) in [
        (
            "textDocument/completion",
            "lsp completion (warm, 1000 lines)",
        ),
        ("textDocument/hover", "lsp hover (warm, 1000 lines)"),
    ] {
        let request = json!({"jsonrpc":"2.0","id":9,"method":method,"params":{
            "textDocument":{"uri":"file:///mil.pseudo"},"position":position}});
        let mut samples = Vec::new();
        for _ in 0..SAMPLES {
            let started = Instant::now();
            let answers = server.handle_message(&request);
            samples.push(started.elapsed().as_secs_f64() * 1000.0);
            if answers
                .first()
                .and_then(|answer| answer.get("error"))
                .is_some()
            {
                return Err(format!("{method} failed"));
            }
        }
        let summary = summarize(&samples).ok_or("No samples")?;
        report.push(
            json!({ "operation": label, "samples": SAMPLES, "latency_ms": summary.to_json() }),
        );
    }
    Ok(report)
}

type Suite<'suite> = Vec<(&'suite str, Vec<&'suite str>)>;

fn small_suite<'suite>(small: &'suite str, compiled: &'suite str) -> Suite<'suite> {
    vec![
        ("pseudo comprobar (small)", vec!["comprobar", small]),
        ("pseudo ejecutar (small)", vec!["ejecutar", small]),
        (
            "pseudo compilar (small)",
            vec!["compilar", small, "-o", compiled],
        ),
        ("pseudo formatear (small)", vec!["formatear", small]),
        (
            "pseudo traducir (small)",
            vec!["traducir", small, "--hacia", "en"],
        ),
    ]
}

fn large_suite(large: &str) -> Suite<'_> {
    vec![
        ("pseudo comprobar (1000 lines)", vec!["comprobar", large]),
        ("pseudo formatear (1000 lines)", vec!["formatear", large]),
        (
            "pseudo traducir (1000 lines)",
            vec!["traducir", large, "--hacia", "en"],
        ),
    ]
}

fn command_operations(
    binary: &Path,
    workspace: &Workspace,
    compiled: &str,
) -> Result<Vec<Value>, String> {
    let small = workspace.small.to_string_lossy().into_owned();
    let large = workspace.large.to_string_lossy().into_owned();
    let mut suite = small_suite(&small, compiled);
    suite.extend(large_suite(&large));
    suite
        .iter()
        .map(|(label, arguments)| measure_command(label, binary, arguments))
        .collect()
}

fn verify_compiled_program(compiled: &str) -> Result<(), String> {
    let native = Command::new(compiled)
        .output()
        .map_err(|error| error.to_string())?;
    if String::from_utf8_lossy(&native.stdout).trim() == "hola" {
        Ok(())
    } else {
        Err("Compiled program printed unexpected output".to_owned())
    }
}

pub fn run(binary: &str, output: &str) -> Result<(), String> {
    let binary = Path::new(binary);
    let workspace = prepare()?;
    let compiled = workspace
        .directory
        .join("hola.bin")
        .to_string_lossy()
        .into_owned();
    let mut operations = command_operations(binary, &workspace, &compiled)?;
    verify_compiled_program(&compiled)?;
    operations.push(measure_lsp_startup(binary)?);
    operations.extend(measure_warm_requests(&workspace.large_text)?);
    let report = json!({
        "experiment": "E-20",
        "status": "measured",
        "machine": machine_description(),
        "samples": SAMPLES,
        "warmup": WARMUP,
        "operations": operations,
    });
    let text = serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?;
    std::fs::write(output, format!("{text}\n")).map_err(|error| error.to_string())?;
    std::fs::remove_dir_all(&workspace.directory).map_err(|error| error.to_string())
}
