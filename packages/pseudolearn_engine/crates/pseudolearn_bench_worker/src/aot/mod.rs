mod baseline;
pub(crate) mod emission;
mod launcher;
mod measurement;
mod provenance;
mod runtime_archive;
pub(crate) mod statistics;
mod summary;

#[cfg(test)]
mod baseline_tests;
#[cfg(test)]
mod launcher_tests;
#[cfg(test)]
mod measurement_tests;
#[cfg(test)]
mod statistics_tests;
#[cfg(test)]
mod summary_tests;

use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use summary::{Sample, SummaryInput};

const PROCESSES: u32 = 10;

struct Workspace(PathBuf);

impl Drop for Workspace {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}

pub fn collect(output: &str, ceiling_path: &str, machine_path: &str) -> Result<(), String> {
    if Path::new(output).exists() {
        return Err("Refusing to overwrite existing evidence".to_owned());
    }
    let references = baseline::load(Path::new(ceiling_path), Path::new(machine_path))?;
    let workspace = Workspace(
        std::env::temp_dir().join(format!("pseudolearn_aot_bench_{}", std::process::id())),
    );
    std::fs::create_dir_all(&workspace.0).map_err(|error| error.to_string())?;
    let archive = runtime_archive::build()?;
    let (launchers, emission_milliseconds) = prepare_all((&workspace.0, &archive))?;
    let mut samples = Vec::new();
    for process in 0..PROCESSES {
        for launcher in &launchers {
            samples.extend(measurement::run(launcher, process)?);
        }
    }
    let summary = summary::summarize(&SummaryInput {
        samples: &samples,
        references: &references,
        emission_milliseconds: &emission_milliseconds,
    })?;
    save(Path::new(output), &samples, &summary)?;
    if summary.get("targetReached") == Some(&json!(true)) {
        Ok(())
    } else {
        Err(format!(
            "Native level target not reached; see {output}/summary.json"
        ))
    }
}

fn prepare_all(
    locations: (&Path, &Path),
) -> Result<(Vec<launcher::Launcher>, BTreeMap<String, f64>), String> {
    let mut launchers = Vec::new();
    let mut emission_milliseconds = BTreeMap::new();
    for case in crate::corpus::awfy_cases()? {
        let emission = emission::measure(&case)?;
        launchers.push(launcher::prepare(&case, &emission.object, locations)?);
        emission_milliseconds.insert(case.name, emission.milliseconds);
    }
    Ok((launchers, emission_milliseconds))
}

fn save(output: &Path, samples: &[Sample], summary: &Value) -> Result<(), String> {
    std::fs::create_dir_all(output).map_err(|error| error.to_string())?;
    let raw: Vec<Value> = samples
        .iter()
        .map(|sample| {
            json!({"workload": sample.workload, "process": sample.process,
                "nanoseconds": sample.nanoseconds})
        })
        .collect();
    let document = json!({"environment": provenance::describe(), "summary": summary});
    write(&output.join("raw.json"), &Value::Array(raw))?;
    write(&output.join("summary.json"), &document)
}

fn write(path: &Path, value: &Value) -> Result<(), String> {
    let text = serde_json::to_string_pretty(value).map_err(|error| error.to_string())?;
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}
