mod bootstrap;
mod digest;
mod documents;
mod expectation;
mod functional;
mod judging;
mod latency;
mod oracle;
mod scanner;
mod summary;
mod transports;
mod verification;

use serde_json::json;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let argument = |slot: usize| arguments.get(slot).map(String::as_str).unwrap_or_default();
    match argument(0) {
        "functional" => run_functional(argument(1)),
        "latency" => latency::run(argument(1), argument(2), argument(3)),
        "summary" => summary::write(argument(1)),
        "verify" => verification::verify(argument(1)),
        _ => Err(
            "Usage: service help functional <dir> | latency hot|cold <dir> <process> | summary <dir> | verify <dir>"
                .to_owned(),
        ),
    }
}

fn run_functional(directory: &str) -> Result<(), String> {
    let oracle = oracle::Oracle::load()?;
    let report = functional::run(&oracle)?;
    let folder = format!("{directory}/functional");
    std::fs::create_dir_all(&folder).map_err(|error| error.to_string())?;
    let summary = json!({
        "format": "e-pg-11-functional/1",
        "programs": report.programs,
        "dataset_digest": report.digest,
        "seed": documents::SEED,
        "transports": {"api": report.api.to_json(), "lsp": report.lsp.to_json()},
        "failure_count": report.failures.len(),
    });
    write_new(&format!("{folder}/summary.json"), &summary)?;
    write_new(&format!("{folder}/failures.json"), &json!(report.failures))?;
    if report.failures.is_empty() {
        Ok(())
    } else {
        Err(format!(
            "{} functional failures; see {folder}/failures.json",
            report.failures.len()
        ))
    }
}

fn write_new(path: &str, value: &serde_json::Value) -> Result<(), String> {
    if std::path::Path::new(path).exists() {
        return Err(format!(
            "{path} already exists; campaigns are never overwritten"
        ));
    }
    let text = serde_json::to_string_pretty(value).map_err(|error| error.to_string())?;
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}

#[cfg(test)]
mod bootstrap_tests;
#[cfg(test)]
mod scanner_tests;
#[cfg(test)]
mod verification_tests;
