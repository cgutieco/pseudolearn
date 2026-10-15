use pseudolearn_api::{
    AnalyzeRequest, ENGINE_VERSION, PROTOCOL_VERSION, SUBJECT_NAME, execute_analyze,
    supported_capabilities, supported_profiles, supported_strictness,
};
use serde_json::{Value, json};
use std::io::{BufRead, Write};

fn main() {
    let stdin = std::io::stdin();
    let locked_stdin = stdin.lock();
    for line in locked_stdin.lines() {
        let line_text = match line {
            Ok(content) => content,
            Err(_) => break,
        };
        let trimmed = line_text.trim();
        if trimmed.is_empty() {
            continue;
        }
        let parsed: Value = match serde_json::from_str(trimmed) {
            Ok(value) => value,
            Err(_) => continue,
        };
        let kind = parsed.get("kind").and_then(Value::as_str).unwrap_or("");
        match kind {
            "hello" => respond_hello(),
            "shutdown" => {
                respond_shutdown();
                break;
            }
            "analyze" => respond_analyze(&parsed),
            _ => respond_unsupported(),
        }
    }
}

fn respond_hello() {
    let response = json!({
        "kind": "hello",
        "protocol": PROTOCOL_VERSION,
        "subject": SUBJECT_NAME,
        "subject_version": ENGINE_VERSION,
        "capabilities": supported_capabilities(),
        "profiles": supported_profiles(),
        "strictness": supported_strictness(),
    });
    send_response(&response);
}

fn respond_shutdown() {
    let response = json!({
        "kind": "shutdown"
    });
    send_response(&response);
}

fn respond_analyze(request_value: &Value) {
    let program = request_value
        .get("program")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned();
    let profile = request_value
        .get("profile")
        .and_then(Value::as_str)
        .unwrap_or("es")
        .to_owned();
    let strictness = request_value
        .get("strictness")
        .and_then(Value::as_str)
        .unwrap_or("strict")
        .to_owned();

    let request = AnalyzeRequest {
        program,
        profile,
        strictness,
    };
    let response = execute_analyze(&request);
    let serialized = match serde_json::to_value(&response) {
        Ok(value) => value,
        Err(_) => return,
    };
    send_response(&serialized);
}

fn respond_unsupported() {
    let response = json!({
        "kind": "error",
        "message": "Unsupported operation"
    });
    send_response(&response);
}

fn send_response(value: &Value) {
    let mut stdout = std::io::stdout().lock();
    if let Ok(serialized) = serde_json::to_string(value) {
        let _ = writeln!(stdout, "{serialized}");
        let _ = stdout.flush();
    }
}
