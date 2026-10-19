use crate::service::corpus::machine_description;
use crate::service::measurement_file::{Measurement, entry, record};
use crate::service::precision_tally::{Evaluation, Tally, evaluate};
use crate::service::statistics::{percent, round, summarize};
use crate::service::thresholds::threshold;
use pseudolearn_api::service::{
    DocumentSession, Position, Profile, template_constructions, template_parses_cleanly,
};
use serde_json::{Value, json};
use std::time::Instant;

const SPECIFICATION: &str = "TOOL.SERVICE.COMPLETION";
const REFERENCE: &str = "TOOL.SERVICE.COMPLETION@0.1.0";

fn template_report() -> Value {
    let mut checked = 0usize;
    let mut valid = 0usize;
    for profile in [Profile::Spanish, Profile::English] {
        for construction in template_constructions() {
            checked = checked.saturating_add(1);
            if template_parses_cleanly(construction, profile) {
                valid = valid.saturating_add(1);
            }
        }
    }
    json!({ "checked": checked, "valid": valid, "valid_percent": percent(valid, checked) })
}

fn large_document_text() -> Result<(String, u32, u32), String> {
    let workload = crate::workloads::load()?
        .into_iter()
        .find(|entry| entry.name == "generated-es-strict-10000-false")
        .ok_or("Missing 10000-line workload")?;
    let program = workload
        .requests
        .first()
        .map(|request| request.program.clone())
        .ok_or("Empty workload")?;
    let mut lines: Vec<&str> = program.lines().collect();
    let last = lines.len().saturating_sub(1);
    lines.insert(last, "  Esc");
    let cursor_line = u32::try_from(last.saturating_add(1)).map_err(|error| error.to_string())?;
    Ok((
        format!("{}\n", lines.join("\n")),
        cursor_line,
        workload.lines,
    ))
}

fn large_document_latency() -> Result<Value, String> {
    let (text, cursor_line, lines) = large_document_text()?;
    let position = Position {
        line: cursor_line,
        column: 6,
    };
    let started = Instant::now();
    let session = DocumentSession::new(text, Profile::Spanish, true);
    let build_ms = started.elapsed().as_secs_f64() * 1000.0;
    let mut samples = Vec::new();
    for _ in 0..30 {
        let begun = Instant::now();
        let entries = session.queries().complete_with_edit(position).entries;
        samples.push(begun.elapsed().as_secs_f64() * 1000.0);
        if entries.is_empty() {
            return Err("No candidates in the large document".to_owned());
        }
    }
    let summary = summarize(&samples).ok_or("No samples")?;
    Ok(
        json!({ "lines": lines, "session_build_ms": round(build_ms), "query_ms": summary.to_json() }),
    )
}

struct Limits {
    latency: f64,
    five: f64,
    first: f64,
    saved: f64,
}

fn limits() -> Result<Limits, String> {
    Ok(Limits {
        latency: threshold(SPECIFICATION, "M1")?,
        five: threshold(SPECIFICATION, "M2")?,
        first: threshold(SPECIFICATION, "M3")?,
        saved: threshold(SPECIFICATION, "M4")?,
    })
}

struct Observed {
    latency: f64,
    five: f64,
    first: f64,
    saved: f64,
    templates_valid: bool,
}

impl Observed {
    fn passes(&self, limits: &Limits) -> bool {
        self.latency <= limits.latency
            && self.five >= limits.five
            && self.first >= limits.first
            && self.saved >= limits.saved
            && self.templates_valid
    }
}

fn observe(evaluation: &Evaluation, large: &Value, templates: &Value) -> Result<Observed, String> {
    let at_two = evaluation.merged(1);
    let five = |profile| {
        evaluation
            .tally(profile, 1)
            .map_or(0.0, Tally::precision_at_five)
    };
    Ok(Observed {
        latency: large
            .pointer("/query_ms/p95")
            .and_then(Value::as_f64)
            .ok_or("Missing latency")?,
        five: five(Profile::Spanish).min(five(Profile::English)),
        first: percent(at_two.first, at_two.queries),
        saved: percent(at_two.saved_chars, at_two.total_chars),
        templates_valid: templates.get("valid_percent").and_then(Value::as_f64) == Some(100.0),
    })
}

fn thresholds_json(limits: &Limits) -> Value {
    json!({
        "latency_p95_ms": limits.latency,
        "precision_at_5_percent_each_language": limits.five,
        "precision_at_1_percent": limits.first,
        "keystrokes_saved_percent": limits.saved,
    })
}

fn prefix_two_json(evaluation: &Evaluation) -> Value {
    let per_profile = |profile| {
        evaluation
            .tally(profile, 1)
            .map(Tally::to_json)
            .unwrap_or(Value::Null)
    };
    json!({
        "es": per_profile(Profile::Spanish),
        "en": per_profile(Profile::English),
        "all": evaluation.merged(1).to_json(),
    })
}

fn build_report(
    evaluation: &Evaluation,
    extra: (&Value, &Value),
    outcome: (&Observed, &Limits),
) -> Value {
    let (large, templates) = extra;
    let (observed, limits) = outcome;
    json!({
        "experiment": "E-09",
        "status": if observed.passes(limits) { "passed" } else { "failed" },
        "machine": machine_description(),
        "protocol": "PERF.PROTOCOL#R1",
        "programs_evaluated": evaluation.programs,
        "queries_evaluated": evaluation.merged(1).queries,
        "template_validity": templates,
        "prefix_2": prefix_two_json(evaluation),
        "prefix_0": evaluation.merged(0).to_json(),
        "small_document_query_ms": summarize(&evaluation.latencies).map(|summary| summary.to_json()),
        "large_document": large,
        "thresholds": thresholds_json(limits),
    })
}

fn make_entry(suffix: &str, metric: (&str, &str, &str), values: (f64, f64)) -> Value {
    let reference = format!("{REFERENCE}#{suffix}");
    let (name, unit, comparator) = metric;
    let measurement = Measurement {
        reference: &reference,
        metric: name,
        unit,
        comparator,
    };
    entry(&measurement, values)
}

fn measurement_entries(observed: &Observed, limits: &Limits) -> Vec<Value> {
    let latency = (limits.latency, observed.latency);
    let five = (limits.five, observed.five);
    let first = (limits.first, observed.first);
    let saved = (limits.saved, observed.saved);
    vec![
        make_entry("M1", ("latencia_p95", "milisegundos", "<="), latency),
        make_entry("M2", ("precision_en_5", "porcentaje", ">="), five),
        make_entry("M3", ("precision_en_1", "porcentaje", ">="), first),
        make_entry("M4", ("ahorro_de_pulsaciones", "porcentaje", ">="), saved),
    ]
}

pub fn run(output: &str, measurements_path: &str) -> Result<(), String> {
    let evaluation = evaluate()?;
    let large = large_document_latency()?;
    let templates = template_report();
    let limits = limits()?;
    let observed = observe(&evaluation, &large, &templates)?;
    let report = build_report(&evaluation, (&large, &templates), (&observed, &limits));
    let text = serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?;
    std::fs::write(output, format!("{text}\n")).map_err(|error| error.to_string())?;
    record(measurements_path, measurement_entries(&observed, &limits))?;
    if observed.passes(&limits) {
        Ok(())
    } else {
        Err(format!("E-09 thresholds not met: {report}"))
    }
}
