use crate::service::help_campaign::digest::Digest;
use crate::service::help_campaign::documents::SEED;
use crate::service::help_campaign::latency::{ITERATIONS, clock_resolution_nanoseconds};
use crate::service::project_campaign::catalogue::{Case, Entry, PROTOCOL, entries};
use crate::service::project_campaign::functional::{all_datasets, write_new};
use crate::service::project_campaign::lock_inputs::{LockWorkload, lock_workloads};
use crate::service::project_campaign::profiles::{modules_dataset, pairs_dataset};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::time::Instant;

type Samples = Vec<(&'static str, Vec<f64>)>;

fn milliseconds(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1000.0
}

fn value_of(response: &Value) -> Result<&Value, String> {
    response
        .get("value")
        .ok_or_else(|| format!("call failed: {response}"))
}

fn expect_clean(value: &Value, modules: Option<usize>) -> Result<(), String> {
    for name in ["diagnostics", "project_errors"] {
        if !value
            .get(name)
            .and_then(Value::as_array)
            .is_some_and(Vec::is_empty)
        {
            return Err(format!("{name} not empty: {value}"));
        }
    }
    let listed = value.get("modules").and_then(Value::as_array).map(Vec::len);
    match (modules, listed) {
        (Some(expected), Some(actual)) if expected != actual => {
            Err(format!("expected {expected} modules, got {actual}"))
        }
        _ => Ok(()),
    }
}

fn analyze(session: &mut ApiSession, arguments: &Value, modules: usize) -> Result<f64, String> {
    let started = Instant::now();
    let response = session.call("analyze_project", arguments);
    let elapsed = milliseconds(started);
    expect_clean(value_of(&response)?, Some(modules))?;
    Ok(elapsed)
}

fn profile_document(
    name: &str,
    dataset: &crate::service::project_campaign::datasets::Dataset,
) -> Result<Value, String> {
    let (mut analysis, mut execution) = (Vec::new(), Vec::new());
    let arguments = dataset.arguments("1");
    for _ in 0..ITERATIONS {
        analysis.push(analyze(
            &mut ApiSession::default(),
            &arguments,
            dataset.files.len(),
        )?);
        let started = Instant::now();
        let response = ApiSession::default().call("execute_project", &arguments);
        execution.push(milliseconds(started));
        let output = value_of(&response)?
            .get("output")
            .and_then(Value::as_str)
            .unwrap_or("");
        if output != dataset.expected_output {
            return Err(format!("{name}: wrong output {output:?}"));
        }
    }
    Ok(record(
        name,
        dataset.line_count(),
        vec![("analyze_ms", analysis), ("execute_ms", execution)],
    ))
}

fn record(name: &str, lines: usize, samples: Samples) -> Value {
    let mut fields = serde_json::Map::new();
    fields.insert("name".to_owned(), json!(name));
    fields.insert("lines".to_owned(), json!(lines));
    for (metric, values) in samples {
        fields.insert(metric.to_owned(), json!(values));
    }
    Value::Object(fields)
}

fn profile_documents() -> Result<Vec<Value>, String> {
    [
        modules_dataset(true),
        modules_dataset(false),
        pairs_dataset(true),
        pairs_dataset(false),
    ]
    .iter()
    .map(|dataset| profile_document(&dataset.name, dataset))
    .collect()
}

fn project_sample(
    entry: &Entry,
    arguments: (&Value, &Value),
    modules: usize,
) -> Result<f64, String> {
    let (base, edited) = arguments;
    let mut session = ApiSession::default();
    match entry.case {
        Case::Cold => analyze(&mut session, base, modules),
        Case::Same => {
            analyze(&mut session, base, modules)?;
            analyze(&mut session, base, modules)
        }
        Case::Body | Case::Signature => {
            analyze(&mut session, base, modules)?;
            analyze(&mut session, edited, modules)
        }
    }
}

fn project_document(entry: &Entry) -> Result<Value, String> {
    let (base, edited) = (entry.base(), entry.edited());
    let (base_arguments, edited_arguments) = (base.arguments("1"), edited.arguments("2"));
    let mut samples = Vec::new();
    for _ in 0..ITERATIONS {
        let arguments = (&base_arguments, &edited_arguments);
        samples.push(project_sample(entry, arguments, base.files.len())?);
    }
    Ok(record(
        &entry.name,
        edited.line_count(),
        vec![("analyze_ms", samples)],
    ))
}

fn project_documents() -> Result<Vec<Value>, String> {
    entries().iter().map(project_document).collect()
}

fn lock_document(workload: &LockWorkload) -> Result<Value, String> {
    let (mut building, mut resolving) = (Vec::new(), Vec::new());
    for _ in 0..ITERATIONS {
        let mut session = ApiSession::default();
        let started = Instant::now();
        let built = session.call("build_lock", &workload.build_arguments());
        building.push(milliseconds(started));
        let lock = value_of(&built)?
            .get("lock")
            .and_then(Value::as_str)
            .ok_or("lock not built")?;
        let started = Instant::now();
        let verdict = session.call("resolve_lock", &workload.resolve_arguments(lock));
        resolving.push(milliseconds(started));
        if value_of(&verdict)?.get("verified") != Some(&json!(true)) {
            return Err(format!("{}: lock not verified", workload.name));
        }
    }
    Ok(record(
        &workload.name,
        workload.bytes(),
        vec![("build_ms", building), ("resolve_ms", resolving)],
    ))
}

fn resolution_documents() -> Result<Vec<Value>, String> {
    lock_workloads().iter().map(lock_document).collect()
}

pub fn machine() -> String {
    let processors = std::thread::available_parallelism().map_or(0, std::num::NonZero::get);
    format!(
        "{}-{}-{processors}cpu",
        std::env::consts::OS,
        std::env::consts::ARCH
    )
}

pub fn dataset_digest() -> String {
    let mut digest = Digest::new();
    for dataset in all_datasets() {
        dataset.digest(&mut digest);
    }
    digest.hex()
}

pub fn run(series: &str, directory: &str, process: &str) -> Result<(), String> {
    let resolution = clock_resolution_nanoseconds();
    if resolution == 0 {
        return Err("The clock reported no measurable resolution".to_owned());
    }
    let documents = match series {
        "profiles" => profile_documents()?,
        "project" => project_documents()?,
        "resolution" => resolution_documents()?,
        _ => {
            return Err(
                "Usage: service project run profiles|project|resolution <dir> <process>".to_owned(),
            );
        }
    };
    let report = json!({
        "format": "e-pg-13-process/1",
        "protocol": PROTOCOL,
        "machine": machine(),
        "dataset_digest": dataset_digest(),
        "series": series,
        "process": process,
        "seed": SEED,
        "iterations": ITERATIONS,
        "clock_resolution_ns": resolution.to_string(),
        "documents": documents,
    });
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    write_new(
        &format!("{directory}/{series}-process-{process}.json"),
        &report,
    )
}
