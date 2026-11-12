use pseudolearn_api::{
    ApiDiagnostic, ExecuteRequest, ExecutionLimits, execute_program, render_diagnostic,
};
use reference_model::{EngineDiagnostic, ExecutionReport, ExecutionRequest, TraceRecord};
use serde_json::Value;

pub const SEED: i64 = 42;

pub fn execute(request: &ExecutionRequest) -> ExecutionReport {
    let host = match request.host.as_deref().map(serde_json::from_str::<Value>) {
        Some(Ok(document)) => Some(document),
        Some(Err(error)) => return host_failure(&error.to_string()),
        None => None,
    };
    let response = execute_program(&ExecuteRequest {
        program: request.code.clone(),
        profile: request.profile.code().to_owned(),
        seed: SEED,
        inputs: request.inputs.clone(),
        observe: if request.trace { "events" } else { "none" }.to_owned(),
        host,
        limits: ExecutionLimits {
            statements: request.statement_limit,
            depth: request.depth_limit,
            ..ExecutionLimits::default()
        },
        ..ExecuteRequest::default()
    });
    ExecutionReport {
        output: response.output,
        termination: response
            .termination
            .get("kind")
            .and_then(Value::as_str)
            .unwrap_or("rejected")
            .to_owned(),
        diagnostics: response.diagnostics.iter().map(diagnostic).collect(),
        trace: response.events.iter().map(trace_record).collect(),
    }
}

fn host_failure(detail: &str) -> ExecutionReport {
    ExecutionReport {
        termination: "rejected".to_owned(),
        diagnostics: vec![EngineDiagnostic {
            code: "invalidHostDocument".to_owned(),
            severity: "error".to_owned(),
            spanish: detail.to_owned(),
            english: detail.to_owned(),
            ..EngineDiagnostic::default()
        }],
        ..ExecutionReport::default()
    }
}

fn diagnostic(source: &ApiDiagnostic) -> EngineDiagnostic {
    EngineDiagnostic {
        code: source.code.clone(),
        severity: source.severity.clone(),
        line: u64::from(source.span.start.line),
        column: u64::from(source.span.start.column),
        spanish: render_diagnostic(source, "es"),
        english: render_diagnostic(source, "en"),
    }
}

fn trace_record(event: &Value) -> TraceRecord {
    TraceRecord {
        line: event
            .get("line")
            .and_then(Value::as_u64)
            .unwrap_or_default(),
        class: event
            .get("class")
            .and_then(Value::as_str)
            .unwrap_or_default()
            .to_owned(),
        detail: event.get("data").map(Value::to_string).unwrap_or_default(),
    }
}
