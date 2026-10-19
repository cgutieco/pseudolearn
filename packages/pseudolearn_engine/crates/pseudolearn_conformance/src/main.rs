#![forbid(unsafe_code)]

use pseudolearn_api::{
    AnalyzeRequest, ENGINE_VERSION, IrRequest, PROTOCOL_VERSION, SUBJECT_NAME, execute_analyze,
    execute_ir, supported_capabilities, supported_profiles, supported_strictness,
};
use serde_json::{Value, json};
use std::io::{BufRead, Write};

mod lsp_handler;
mod service_edit_request;
mod service_edits;
mod service_handler;
mod service_queries;
mod service_request;
mod service_text;

fn main() {
    let raw_arguments: Vec<String> = std::env::args().skip(1).collect();
    let is_service = raw_arguments
        .windows(2)
        .any(|pair| matches!(pair, [flag, value] if flag == "--subject" && value == "service"))
        || raw_arguments.iter().any(|arg| arg == "service");

    let mut session = pseudolearn_api::ApiSession::default();
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
        if !dispatch_request(&mut session, &parsed, is_service) {
            break;
        }
    }
}

fn dispatch_request(
    session: &mut pseudolearn_api::ApiSession,
    parsed: &Value,
    is_service: bool,
) -> bool {
    let kind = parsed.get("kind").and_then(Value::as_str).unwrap_or("");
    match kind {
        "hello" => {
            if is_service {
                respond_hello_service();
            } else {
                respond_hello();
            }
        }
        "shutdown" => {
            respond_shutdown();
            return false;
        }
        "service" => {
            let outcome = service_handler::handle_service_request(parsed);
            send_response(&json!({ "kind": "service", "service": outcome }));
        }
        "analyze" => respond_analyze(parsed),
        "ir" => respond_ir(parsed),
        "execute" => respond_execute(parsed),
        "probe" => send_response(&pseudolearn_api::probe(parsed)),
        "api" => respond_api(session, parsed),
        _ => respond_unsupported(),
    }
    true
}

fn respond_hello_service() {
    let response = json!({
        "kind": "hello",
        "protocol": PROTOCOL_VERSION,
        "subject": "service",
        "subject_version": ENGINE_VERSION,
        "capabilities": ["service"],
        "profiles": supported_profiles(),
        "strictness": supported_strictness(),
    });
    send_response(&response);
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
    let mut serialized = match serde_json::to_value(&response) {
        Ok(value) => value,
        Err(_) => return,
    };
    let wants_view = request_value
        .get("include_program_view")
        .and_then(Value::as_bool)
        .unwrap_or(false);
    if let (true, Some(fields), Some(view)) = (
        wants_view,
        serialized.as_object_mut(),
        pseudolearn_api::analysis_program_view(&request),
    ) {
        fields.insert("program_view".to_owned(), view);
    }
    send_response(&serialized);
}

fn respond_ir(request_value: &Value) {
    let program_ir = request_value
        .get("program_ir")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned();
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

    let request = IrRequest {
        program_ir,
        program,
        profile,
        strictness,
    };
    let response = execute_ir(&request);
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

fn respond_execute(request_value: &Value) {
    match serde_json::from_value::<pseudolearn_api::ExecuteRequest>(request_value.clone()) {
        Ok(request) => {
            if let Ok(response) = serde_json::to_value(pseudolearn_api::execute_program(&request)) {
                send_response(&response);
            }
        }
        Err(_) => respond_unsupported(),
    }
}

fn respond_api(session: &mut pseudolearn_api::ApiSession, request: &Value) {
    let result = session.call(
        request
            .get("operation")
            .and_then(Value::as_str)
            .unwrap_or(""),
        request.get("arguments").unwrap_or(&Value::Null),
    );
    send_response(&json!({"kind":"api","result":result}));
}
