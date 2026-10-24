#![forbid(unsafe_code)]

use crate::native_cache::ExecutableCache;
use crate::native_run::run_executable;
use pseudolearn_api::{
    ENGINE_VERSION, ExecuteRequest, ExecuteResponse, NativeBuildFailure, NativeRunReport,
    build_native_object, conformance_build_request, native_execute_response,
    rejected_native_response, supported_profiles, supported_strictness,
};
use serde_json::{Value, json};
use std::io::{BufRead, Write};
use std::process::ExitCode;

pub fn run_aot_adapter() -> ExitCode {
    let Ok(mut cache) = ExecutableCache::create() else {
        return ExitCode::from(3);
    };
    let stdin = std::io::stdin();
    for line in stdin.lock().lines() {
        let Ok(line_text) = line else { break };
        let Ok(parsed) = serde_json::from_str::<Value>(line_text.trim()) else {
            continue;
        };
        match parsed.get("kind").and_then(Value::as_str).unwrap_or("") {
            "hello" => send_response(&hello()),
            "shutdown" => {
                send_response(&json!({"kind":"shutdown"}));
                break;
            }
            "execute" => send_response(&execute(&parsed, &mut cache)),
            _ => send_response(&json!({"kind":"error","message":"Unsupported operation"})),
        }
    }
    ExitCode::SUCCESS
}

fn hello() -> Value {
    json!({
        "kind": "hello",
        "protocol": "see-protocol/1",
        "subject": "aot",
        "subject_version": ENGINE_VERSION,
        "capabilities": ["execute", "gc_stress"],
        "profiles": supported_profiles(),
        "strictness": supported_strictness()
    })
}

fn execute(request_value: &Value, cache: &mut ExecutableCache) -> Value {
    let Ok(request) = serde_json::from_value::<ExecuteRequest>(request_value.clone()) else {
        return json!({"kind":"error","message":"Unsupported operation"});
    };
    let response = execute_natively(&request, cache);
    serde_json::to_value(response).unwrap_or(Value::Null)
}

fn execute_natively(request: &ExecuteRequest, cache: &mut ExecutableCache) -> ExecuteResponse {
    let object = match build_native_object(&conformance_build_request(request)) {
        Ok(object) => object,
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            return rejected_native_response(diagnostics);
        }
        Err(NativeBuildFailure::Backend(_) | NativeBuildFailure::ProjectRejected(_)) => {
            return internal_fault(request);
        }
    };
    let Ok(executable) = cache.executable_for(&object.bytes) else {
        return internal_fault(request);
    };
    match run_executable(&executable, cache.directory(), &request.inputs) {
        Ok(report) => native_execute_response(request, object.warnings, &report),
        Err(_) => internal_fault(request),
    }
}

fn internal_fault(request: &ExecuteRequest) -> ExecuteResponse {
    native_execute_response(request, Vec::new(), &NativeRunReport::default())
}

fn send_response(value: &Value) {
    let mut stdout = std::io::stdout().lock();
    if let Ok(serialized) = serde_json::to_string(value) {
        let _written = writeln!(stdout, "{serialized}");
        let _flushed = stdout.flush();
    }
}
