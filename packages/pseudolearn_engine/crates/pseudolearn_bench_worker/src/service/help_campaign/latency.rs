use crate::service::help_campaign::documents::{Document, SEED, large, small};
use crate::service::help_campaign::expectation::Query;
use crate::service::help_campaign::judging::{Context, judge_api};
use crate::service::help_campaign::oracle::Oracle;
use crate::service::help_campaign::transports::answer_from_response;
use pseudolearn_api::ApiSession;
use pseudolearn_api::service::{
    DocumentSession, HelpFormat, HelpLocale, Position, Profile, help_content, render_help,
    resolve_help_with_locale,
};
use serde_json::{Value, json};
use std::time::Instant;

pub const ITERATIONS: usize = 30;
const CLOCK_PROBES: usize = 100_000;

fn milliseconds(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1000.0
}

pub fn clock_resolution_nanoseconds() -> u128 {
    let mut smallest = u128::MAX;
    let mut previous = Instant::now();
    for _ in 0..CLOCK_PROBES {
        let now = Instant::now();
        let delta = now.duration_since(previous).as_nanos();
        if delta > 0 && delta < smallest {
            smallest = delta;
        }
        previous = now;
    }
    if smallest == u128::MAX { 0 } else { smallest }
}

pub fn resident_kibibytes() -> Option<u64> {
    let output = std::process::Command::new("ps")
        .args(["-o", "rss=", "-p", &std::process::id().to_string()])
        .output()
        .ok()?;
    String::from_utf8(output.stdout).ok()?.trim().parse().ok()
}

fn open(document: &Document) -> Result<(ApiSession, u64), String> {
    let mut session = ApiSession::default();
    let opened = session.call(
        "open_edit_session",
        &json!({"program": document.program, "profile": document.profile, "strictness": "strict"}),
    );
    let resource = opened
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("open_edit_session failed: {opened}"))?;
    Ok((session, resource))
}

fn request(resource: u64, query: &Query) -> Value {
    json!({
        "resource": resource, "revision": "1",
        "position": {"line": query.line, "column": query.column, "unit": "unicode_scalar"},
        "language": "es", "detail": "full"
    })
}

fn validate(oracle: &Oracle, response: &Value, query: &Query) -> Result<(), String> {
    let value = response
        .get("value")
        .ok_or_else(|| format!("help_query failed: {response}"))?;
    let answer = answer_from_response(value);
    judge_api(
        oracle,
        &answer,
        query,
        &Context {
            language: "es",
            partial: false,
        },
    )
    .map_err(|reason| format!("{}:{} {reason}", query.line, query.column))
}

fn hot_document(oracle: &Oracle, document: &Document) -> Result<Value, String> {
    let (mut api, mut core, mut render) = (Vec::new(), Vec::new(), Vec::new());
    for query in &document.queries {
        let (mut session, resource) = open(document)?;
        let payload = request(resource, query);
        let started = Instant::now();
        let response = session.call("help_query", &payload);
        api.push(milliseconds(started));
        validate(oracle, &response, query)?;
        let (core_ms, render_ms) = core_and_render(document, query)?;
        core.push(core_ms);
        render.push(render_ms);
    }
    Ok(document_record(
        document,
        &[("api_ms", api), ("core_ms", core), ("render_ms", render)],
    ))
}

fn core_and_render(document: &Document, query: &Query) -> Result<(f64, f64), String> {
    let service = DocumentSession::new(document.program.clone(), Profile::Spanish, true);
    let position = Position {
        line: query.line,
        column: query.column,
    };
    let started = Instant::now();
    let outcome = resolve_help_with_locale(&service, position, HelpLocale::Spanish)
        .ok_or("core query found nothing")?;
    let content = help_content(&outcome, HelpLocale::Spanish).ok_or("no card for the query")?;
    let core = milliseconds(started);
    let started = Instant::now();
    render_help(&content, HelpLocale::Spanish, HelpFormat::Markdown)
        .map_err(|error| format!("{error:?}"))?;
    Ok((core, milliseconds(started)))
}

fn cold_document(oracle: &Oracle, document: &Document) -> Result<Value, String> {
    let (mut cold, mut first) = (Vec::new(), Vec::new());
    for query in &document.queries {
        let started = Instant::now();
        let (mut session, resource) = open(document)?;
        let response = session.call("help_query", &request(resource, query));
        session.call("release", &json!({"resource": resource}));
        let elapsed = milliseconds(started);
        validate(oracle, &response, query)?;
        if first.is_empty() {
            first.push(elapsed);
        }
        cold.push(elapsed);
    }
    Ok(document_record(
        document,
        &[("cold_ms", cold), ("first_in_series_ms", first)],
    ))
}

fn document_record(document: &Document, series: &[(&str, Vec<f64>)]) -> Value {
    let mut record = serde_json::Map::new();
    record.insert("name".to_owned(), json!(document.name));
    record.insert("lines".to_owned(), json!(document.program.lines().count()));
    let queries: Vec<Value> = document
        .queries
        .iter()
        .map(|query| json!({"line": query.line, "column": query.column}))
        .collect();
    record.insert("queries".to_owned(), json!(queries));
    for (name, samples) in series {
        record.insert((*name).to_owned(), json!(samples));
    }
    Value::Object(record)
}

fn measure_documents(series: &str, oracle: &Oracle) -> Result<Vec<Value>, String> {
    let documents = [small(oracle, ITERATIONS)?, large(oracle, ITERATIONS)?];
    let mut records = Vec::new();
    for document in &documents {
        if document.queries.len() < ITERATIONS {
            return Err(format!(
                "{} yields fewer than {ITERATIONS} queries",
                document.name
            ));
        }
        records.push(if series == "hot" {
            hot_document(oracle, document)?
        } else {
            cold_document(oracle, document)?
        });
    }
    Ok(records)
}

fn write_report(
    directory: &str,
    series: &str,
    process: &str,
    report: &Value,
) -> Result<(), String> {
    let text = serde_json::to_string_pretty(report).map_err(|error| error.to_string())?;
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    let path = format!("{directory}/{series}-process-{process}.json");
    if std::path::Path::new(&path).exists() {
        return Err(format!(
            "{path} already exists; campaigns are never overwritten"
        ));
    }
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}

pub fn run(series: &str, output: &str, process: &str) -> Result<(), String> {
    if !matches!(series, "hot" | "cold") {
        return Err("Usage: service help-latency hot|cold <output> <process>".to_owned());
    }
    let oracle = Oracle::load()?;
    let resolution = clock_resolution_nanoseconds();
    if resolution == 0 {
        return Err("The clock reported no measurable resolution".to_owned());
    }
    let before = resident_kibibytes();
    let documents = measure_documents(series, &oracle)?;
    let report = json!({
        "format": "e-pg-11-process/1",
        "series": series,
        "process": process,
        "seed": SEED,
        "iterations": ITERATIONS,
        "clock_resolution_ns": resolution.to_string(),
        "rss_kib_before": before,
        "rss_kib_after": resident_kibibytes(),
        "documents": documents,
    });
    write_report(output, series, process, &report)
}
