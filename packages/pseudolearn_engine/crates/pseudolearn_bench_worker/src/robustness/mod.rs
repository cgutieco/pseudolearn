mod bytecode;
mod campaigns;
mod isolation;
mod mutation;
mod sources;

use campaigns::{Outcome, PANICS};
use isolation::Slice;
use serde_json::{Value, json};
use std::sync::atomic::Ordering;

const SLICE_LENGTH: u64 = 250;

pub fn collect() -> Result<(), String> {
    let arguments: Vec<String> = std::env::args().skip(2).collect();
    let campaign = arguments
        .first()
        .ok_or("Usage: robust <campaign> <seed> <cases>")?;
    let seed = number(&arguments, 1)?;
    let cases = number(&arguments, 2)?;
    let mut summary = json!({"campaign":campaign,"seed":seed,"cases":cases,
        "clean":0,"rejected":0,"not_applicable":0});
    let mut findings = Vec::new();
    let mut start = 0_u64;
    while start < cases {
        let length = SLICE_LENGTH.min(cases.saturating_sub(start));
        let slice = Slice {
            campaign,
            seed,
            start,
            length,
        };
        let result = isolation::run_slice(&slice);
        if result.get("crash").is_some() {
            isolation::isolate_crash(&slice, &mut findings);
        } else {
            merge(&mut summary, &mut findings, &result);
        }
        start = start.saturating_add(length);
    }
    set_field(&mut summary, "findings", json!(findings));
    set_field(&mut summary, "isolated_processes", json!(true));
    println!("{summary}");
    Ok(())
}

fn merge(summary: &mut Value, findings: &mut Vec<Value>, result: &Value) {
    for counter in ["clean", "rejected", "not_applicable"] {
        let total = summary.get(counter).and_then(Value::as_u64).unwrap_or(0);
        let part = result.get(counter).and_then(Value::as_u64).unwrap_or(0);
        set_field(summary, counter, json!(total.saturating_add(part)));
    }
    if let Some(items) = result.get("findings").and_then(Value::as_array) {
        findings.extend(items.iter().cloned());
    }
}

pub fn child() -> Result<(), String> {
    std::panic::set_hook(Box::new(|_| {
        PANICS.fetch_add(1, Ordering::SeqCst);
    }));
    let arguments: Vec<String> = std::env::args().skip(2).collect();
    let campaign = arguments.first().ok_or("Missing campaign")?;
    let seed = number(&arguments, 1)?;
    let start = number(&arguments, 2)?;
    let length = number(&arguments, 3)?;
    let corpus = sources::corpus_sources()?;
    let mut counters = [0_u64; 3];
    let mut findings = Vec::new();
    for case in start..start.saturating_add(length) {
        match campaigns::evaluate(campaign, seed, case, &corpus)? {
            Outcome::Clean => counters[0] = counters[0].saturating_add(1),
            Outcome::Rejected => counters[1] = counters[1].saturating_add(1),
            Outcome::NotApplicable => counters[2] = counters[2].saturating_add(1),
            Outcome::Finding(mut detail) => {
                set_field(&mut detail, "campaign", json!(campaign));
                set_field(&mut detail, "seed", json!(seed));
                set_field(&mut detail, "case", json!(case));
                findings.push(detail);
            }
        }
    }
    let [clean, rejected, not_applicable] = counters;
    println!(
        "{}",
        json!({"clean":clean,"rejected":rejected,
        "not_applicable":not_applicable,"findings":findings})
    );
    Ok(())
}

fn set_field(target: &mut Value, key: &str, value: Value) {
    if let Some(object) = target.as_object_mut() {
        object.insert(key.to_owned(), value);
    }
}

fn number(arguments: &[String], position: usize) -> Result<u64, String> {
    arguments
        .get(position)
        .and_then(|text| text.parse().ok())
        .ok_or_else(|| "SEE-ROBUSTNESS: numeric argument expected".to_owned())
}
