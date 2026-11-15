pub(crate) mod diagnostics;
mod inspection;
mod launcher;
mod provenance;
mod stationarity;
mod storage;
mod summary;
mod validation;

#[cfg(test)]
mod summary_tests;
#[cfg(test)]
mod validation_tests;

use serde_json::{Value, json};
use std::path::Path;

pub fn collect(output: &str) -> Result<(), String> {
    let directory = Path::new(output);
    if output.is_empty() || directory.exists() {
        return Err("Output must be a new evidence directory".to_owned());
    }
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    storage::write(&directory.join("capture.json"), &provenance::describe()?)?;
    let archive = storage::archive()?;
    storage::manifest(directory, &archive)?;
    let workspace =
        Scratch(std::env::temp_dir().join(format!("pseudolearn_pairs_{}", std::process::id())));
    std::fs::create_dir_all(&workspace.0).map_err(|error| error.to_string())?;
    let (launchers, emissions) = prepare(directory, &workspace.0, &archive)?;
    let mut records = Vec::new();
    for process in 0..10 {
        for (workload, launcher) in &launchers {
            let pairs = launcher::run(launcher, process)?;
            records.push(
                json!({"workload":workload,"process":process,"pairs":pairs,"measurementVersion":2}),
            );
            storage::write(&directory.join("raw.json"), &json!(records))?;
        }
    }
    let report = summary::summarize(&records, &json!(emissions))?;
    storage::write(
        &directory.join("stationarity.json"),
        &stationarity::analyze(&records)?,
    )?;
    storage::write(&directory.join("summary.json"), &report)?;
    if report.get("targetReached") == Some(&json!(true)) {
        Ok(())
    } else {
        Err("Native level target not reached; evidence preserved".to_owned())
    }
}

type Launchers = Vec<(String, launcher::Launcher)>;
type Emissions = serde_json::Map<String, Value>;

fn prepare(
    directory: &Path,
    workspace: &Path,
    archive: &Path,
) -> Result<(Launchers, Emissions), String> {
    let mut inspections = serde_json::Map::new();
    let mut launchers = Vec::new();
    let mut emissions = serde_json::Map::new();
    for case in crate::corpus::awfy_cases()? {
        let emission = crate::aot::emission::measure(&case)?;
        launchers.push((
            case.name.clone(),
            launcher::build(&case, &emission.object, (workspace, archive))?,
        ));
        launcher::verify(
            launchers
                .last()
                .map(|(_, launcher)| launcher)
                .ok_or("Missing launcher")?,
        )?;
        inspections.insert(
            case.name.clone(),
            inspection::save(
                &case,
                directory,
                &workspace.join(&case.name).join("program.o"),
            )?,
        );
        emissions.insert(case.name, json!(emission.timings));
    }
    storage::write(&directory.join("emission.json"), &json!(emissions))?;
    storage::write(&directory.join("inspection.json"), &json!(inspections))?;
    Ok((launchers, emissions))
}

pub fn summarize_existing(directory: &str) -> Result<(), String> {
    let directory = Path::new(directory);
    let read = |name| -> Result<Value, String> {
        let bytes = std::fs::read(directory.join(name)).map_err(|error| error.to_string())?;
        serde_json::from_slice(&bytes).map_err(|error| error.to_string())
    };
    let records = read("raw.json")?;
    let records = records.as_array().ok_or("Invalid records")?;
    let report = summary::summarize(records, &read("emission.json")?)?;
    println!(
        "{}",
        serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?
    );
    Ok(())
}

struct Scratch(std::path::PathBuf);

impl Drop for Scratch {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}
