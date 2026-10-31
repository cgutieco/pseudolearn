use crate::service::help_campaign::latency::{ITERATIONS, clock_resolution_nanoseconds};
use crate::service::workspace_campaign::case::build;
use crate::service::workspace_campaign::clock::SystemClock;
use crate::service::workspace_campaign::loads::{LOADS, Load};
use crate::service::workspace_campaign::record::{
    RecordInput, build as build_record, digest_of, write_new,
};
use crate::service::workspace_campaign::run::run_case;
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::selection::Selection;
use crate::service::workspace_campaign::summary::summarize;
use crate::service::workspace_campaign::transport::ProcessTransport;
use serde_json::{Value, json};
use std::path::Path;

pub fn machine() -> String {
    let processors = std::thread::available_parallelism().map_or(0, std::num::NonZero::get);
    format!(
        "{}-{}-{processors}cpu",
        std::env::consts::OS,
        std::env::consts::ARCH
    )
}

pub fn plan(directory: &str) -> Result<(), String> {
    let mut entries = Vec::new();
    for load in &LOADS {
        for scenario in Scenario::SAMPLED.iter().chain(Scenario::CORRECTNESS.iter()) {
            entries.push(json!({
                "load": load.name, "files": load.files, "lines_per_file": load.lines_per_file,
                "scenario": scenario.name(), "case_digest": digest_of(&build(load, *scenario)),
            }));
        }
    }
    write_new(
        &Path::new(directory).join("plan.json"),
        &json!({"entries": entries}),
    )
}

fn sampled_record(
    directory: &Path,
    load: &Load,
    scenario: Scenario,
    context: (&str, usize),
) -> Result<(), String> {
    let (binary, process) = context;
    let case = build(load, scenario);
    let mut connect = || ProcessTransport::spawn(binary);
    let samples = run_case(&mut connect, &mut SystemClock::new(), &case, ITERATIONS)?;
    let record = build_record(&RecordInput {
        load: load.name,
        scenario,
        process,
        machine: &machine(),
        resolution_nanos: clock_resolution_nanoseconds(),
        digest: digest_of(&case),
        candidate_millis: &samples.candidate_millis,
        control_millis: &samples.control_millis,
    });
    let name = format!("{}-process-{process:02}.json", scenario.name());
    write_new(&directory.join(load.name).join(name), &record)
}

fn correctness_pass(binary: &str) -> Result<(), String> {
    let load = LOADS[0];
    for scenario in Scenario::CORRECTNESS {
        let mut connect = || ProcessTransport::spawn(binary);
        run_case(
            &mut connect,
            &mut SystemClock::new(),
            &build(&load, scenario),
            1,
        )?;
    }
    Ok(())
}

pub fn run(
    directory: &str,
    binary: &str,
    process: &str,
    selection: &Selection,
) -> Result<(), String> {
    let process: usize = process.parse().map_err(|_| "process must be a number")?;
    if process == 0 {
        correctness_pass(binary)?;
    }
    for load in &LOADS {
        if !selection.includes_load(load.name) {
            continue;
        }
        for scenario in Scenario::SAMPLED {
            if !selection.includes(load.name, scenario) {
                continue;
            }
            sampled_record(Path::new(directory), load, scenario, (binary, process))?;
        }
    }
    Ok(())
}

fn records_in(directory: &Path, selection: &Selection) -> Result<Vec<Value>, String> {
    let mut records = Vec::new();
    for load in &LOADS {
        if !selection.includes_load(load.name) {
            continue;
        }
        let Ok(entries) = std::fs::read_dir(directory.join(load.name)) else {
            continue;
        };
        for entry in entries.flatten() {
            let text = std::fs::read_to_string(entry.path()).map_err(|error| error.to_string())?;
            records.push(serde_json::from_str(&text).map_err(|error| error.to_string())?);
        }
    }
    Ok(records)
}

pub fn summarize_directory(directory: &str, selection: &Selection) -> Result<(), String> {
    let root = Path::new(directory);
    let summary = summarize(&records_in(root, selection)?, selection)?;
    write_new(&root.join("summary.json"), &summary)
}
