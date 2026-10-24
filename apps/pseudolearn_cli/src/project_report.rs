use crate::messages;
use crate::options::CliOptions;
use crate::project_files::{MANIFEST_NAME, ProjectSnapshot};
use pseudolearn_api::ApiDiagnostic;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Copy)]
pub(crate) enum Stream {
    Standard,
    Error,
}

pub(crate) fn emit(stream: Stream, text: &str) {
    match stream {
        Stream::Standard => print!("{text}"),
        Stream::Error => eprint!("{text}"),
    }
}

pub(crate) fn has_failures(value: &Value) -> bool {
    ["project_errors", "manifest_errors"]
        .iter()
        .any(|name| non_empty(value, name))
        || diagnostics(value)
            .iter()
            .any(|diagnostic| diagnostic.severity == "error")
}

fn non_empty(value: &Value, name: &str) -> bool {
    value
        .get(name)
        .and_then(Value::as_array)
        .is_some_and(|list| !list.is_empty())
}

pub(crate) fn diagnostics(value: &Value) -> Vec<ApiDiagnostic> {
    serde_json::from_value(value.get("diagnostics").cloned().unwrap_or(Value::Null))
        .unwrap_or_default()
}

pub(crate) fn render(
    options: &CliOptions,
    snapshot: &ProjectSnapshot,
    (value, stream): (&Value, Stream),
) {
    let locale = &options.interface_language;
    for failure in list(value, "manifest_errors") {
        emit(stream, &manifest_line(locale, snapshot, failure));
    }
    for failure in list(value, "project_errors") {
        emit(stream, &project_line(locale, snapshot, failure));
    }
    let names = names(snapshot);
    for diagnostic in diagnostics(value) {
        let path = diagnostic
            .span
            .source
            .and_then(|source| names.get(&source.source_id))
            .map_or(snapshot.label.as_str(), String::as_str);
        let position = (diagnostic.span.start.line, diagnostic.span.start.column);
        emit(
            stream,
            &messages::format_diagnostic_line(locale, path, position, &diagnostic),
        );
    }
}

fn list<'value>(value: &'value Value, name: &str) -> &'value [Value] {
    value
        .get(name)
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice)
}

fn names(snapshot: &ProjectSnapshot) -> BTreeMap<u32, String> {
    snapshot
        .sources
        .iter()
        .map(|source| (source.source_id, source.display.clone()))
        .collect()
}

fn text<'value>(value: &'value Value, name: &str) -> &'value str {
    value.get(name).and_then(Value::as_str).unwrap_or("")
}

fn number(value: &Value, name: &str) -> String {
    value
        .get(name)
        .and_then(Value::as_u64)
        .unwrap_or(0)
        .to_string()
}

fn manifest_line(locale: &str, snapshot: &ProjectSnapshot, failure: &Value) -> String {
    let path = format!(
        "{}/{}/{MANIFEST_NAME}",
        snapshot.label.trim_end_matches('/'),
        text(failure, "location")
    );
    messages::render(
        "manifestError",
        locale,
        &[
            ("path", &path),
            ("line", &number(failure, "line")),
            ("column", &number(failure, "column")),
            ("field", text(failure, "field")),
            ("code", text(failure, "code")),
        ],
    )
}

fn project_line(locale: &str, snapshot: &ProjectSnapshot, failure: &Value) -> String {
    let path = match failure.get("path").and_then(Value::as_str) {
        Some(path) => format!("{}/{path}", snapshot.label.trim_end_matches('/')),
        None => snapshot.label.clone(),
    };
    messages::render(
        "projectError",
        locale,
        &[("path", &path), ("code", text(failure, "code"))],
    )
}
