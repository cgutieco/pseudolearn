use pseudolearn_api::service::{FormatOptions, Profile, format_checked, translate_source};
use pseudolearn_api::{
    AnalyzeRequest, ApiDiagnostic, ApiSession, ExecuteRequest, ExecutionLimits,
    detect_vocabulary_profile, execute_analyze, execute_program, render_diagnostic,
};
use serde_json::{Value, json};

pub(crate) const DEFAULT_STEP_LIMIT: u64 = 10_000;
pub(crate) const MAXIMUM_STEP_LIMIT: u64 = 100_000;
pub(crate) const RUN_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

pub(crate) fn check(arguments: &Value) -> (Value, bool) {
    let Some(source) = text(arguments, "source") else {
        return invalid();
    };
    let diagnostics = execute_analyze(&AnalyzeRequest {
        source: None,
        program: source.to_owned(),
        profile: profile_of(arguments, "profile", source),
    })
    .diagnostics;
    (
        diagnostics_payload(&diagnostics, locale_of(arguments)),
        false,
    )
}

pub(crate) fn run(arguments: &Value) -> (Value, bool) {
    let Some(source) = text(arguments, "source") else {
        return invalid();
    };
    let profile = profile_of(arguments, "profile", source);
    let analysis = execute_analyze(&AnalyzeRequest {
        source: None,
        program: source.to_owned(),
        profile: profile.clone(),
    });
    if analysis
        .diagnostics
        .iter()
        .any(|entry| entry.severity == "error")
    {
        return (
            diagnostics_payload(&analysis.diagnostics, locale_of(arguments)),
            true,
        );
    }
    let request = ExecuteRequest {
        program: source.to_owned(),
        profile,
        inputs: strings(arguments.get("inputs")),
        limits: ExecutionLimits {
            statements: Some(step_limit(arguments)),
            ..ExecutionLimits::default()
        },
        ..ExecuteRequest::default()
    };
    (run_bounded(request), false)
}

fn run_bounded(request: ExecuteRequest) -> Value {
    let (sender, receiver) = std::sync::mpsc::channel();
    std::thread::spawn(move || {
        let response = execute_program(&request);
        let _sent = sender.send((response.output, response.termination));
    });
    match receiver.recv_timeout(RUN_TIMEOUT) {
        Ok((output, termination)) => run_payload(&output, &termination),
        Err(_) => json!({"output": "", "termination": "limit_reached", "limit": "time"}),
    }
}

pub(crate) fn format(arguments: &Value) -> (Value, bool) {
    let Some(source) = text(arguments, "source") else {
        return invalid();
    };
    let options = FormatOptions {
        profile: profile_enum(&profile_of(arguments, "profile", source)),
        indent_size: 2,
    };
    match format_checked(source, options) {
        Some(formatted) => (json!({"source": formatted}), false),
        None => (json!({"error": "syntax_errors"}), true),
    }
}

pub(crate) fn translate(arguments: &Value) -> (Value, bool) {
    let (Some(source), Some(target)) =
        (text(arguments, "source"), text(arguments, "target_profile"))
    else {
        return invalid();
    };
    match translate_source(source, profile_enum(target)) {
        Ok(translated) => (json!({"source": translated}), false),
        Err(_) => (json!({"error": "translation_rejected"}), true),
    }
}

pub(crate) fn explain(arguments: &Value) -> (Value, bool) {
    let Some(code) = text(arguments, "code") else {
        return invalid();
    };
    let reply = ApiSession::default().call(
        "diagnostic_template",
        &json!({"code": code, "locale": locale_of(arguments)}),
    );
    match reply
        .get("value")
        .filter(|value| value.get("template").is_some())
    {
        Some(value) => (value.clone(), false),
        None => (json!({"error": "unknown_code"}), true),
    }
}

pub(crate) fn step_limit(arguments: &Value) -> u64 {
    arguments
        .get("step_limit")
        .and_then(Value::as_u64)
        .unwrap_or(DEFAULT_STEP_LIMIT)
        .clamp(1, MAXIMUM_STEP_LIMIT)
}

pub(crate) fn text<'value>(arguments: &'value Value, name: &str) -> Option<&'value str> {
    arguments.get(name).and_then(Value::as_str)
}

pub(crate) fn locale_of(arguments: &Value) -> &str {
    match text(arguments, "locale") {
        Some("en") => "en",
        _ => "es",
    }
}

pub(crate) fn invalid() -> (Value, bool) {
    (json!({"error": "invalid_arguments"}), true)
}

fn run_payload(output: &str, termination: &Value) -> Value {
    let kind = termination
        .get("kind")
        .and_then(Value::as_str)
        .unwrap_or("failed");
    match termination.get("limit").and_then(Value::as_str) {
        Some(limit) => json!({"output": output, "termination": kind, "limit": limit}),
        None => json!({"output": output, "termination": kind}),
    }
}

fn diagnostics_payload(diagnostics: &[ApiDiagnostic], locale: &str) -> Value {
    let entries: Vec<Value> = diagnostics
        .iter()
        .map(|diagnostic| {
            json!({
                "code": diagnostic.code,
                "severity": diagnostic.severity,
                "line": diagnostic.span.start.line,
                "column": diagnostic.span.start.column,
                "message": render_diagnostic(diagnostic, locale),
            })
        })
        .collect();
    let executable = !diagnostics.iter().any(|entry| entry.severity == "error");
    json!({"diagnostics": entries, "executable": executable})
}

fn profile_of(arguments: &Value, name: &str, source: &str) -> String {
    match text(arguments, name) {
        Some("en") => "en".to_owned(),
        Some("es") => "es".to_owned(),
        _ => detect_vocabulary_profile(source).unwrap_or("es").to_owned(),
    }
}

fn profile_enum(name: &str) -> Profile {
    if name == "en" {
        Profile::English
    } else {
        Profile::Spanish
    }
}

fn strings(value: Option<&Value>) -> Vec<String> {
    value
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter_map(Value::as_str)
                .map(str::to_owned)
                .collect()
        })
        .unwrap_or_default()
}
