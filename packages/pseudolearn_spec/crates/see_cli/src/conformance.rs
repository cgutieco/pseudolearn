use crate::{arguments::Arguments, storage};
use see_model::{
    Corpus,
    contract::Vocabulary,
    evidence::{Conformance, Evidence},
};
use std::process::Command;
use std::time::Duration;

pub fn execute(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let subject = arguments
        .options
        .get("subject")
        .ok_or("Missing --subject")?;
    if subject != "reference" {
        return Err("Unknown subject".to_owned());
    }
    let (core, conformance) = subject_configuration(arguments, corpus)?;
    let selected = select(arguments, corpus, subject)?;
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let mut command = Command::new("dart");
    command
        .current_dir(core)
        .args(["run", "tool/conformance_adapter.dart"]);
    let mut session =
        see_conformance::protocol::Session::start(&mut command, Duration::from_secs(15))?;
    if session
        .hello
        .get("subject")
        .and_then(serde_json::Value::as_str)
        != Some(subject)
    {
        return Err("SEE-PROTOCOL: unexpected subject identity".to_owned());
    }
    let mut evidence = see_conformance::execution::execute(&selected, &vocabulary, &mut session)?;
    for specification in &selected {
        evidence.corpus_hashes.insert(
            specification.metadata.id.clone(),
            see_change::hash(specification)?,
        );
    }
    save(arguments, &selected, &conformance, &evidence)
}

pub fn matrix(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let evidence: Evidence = storage::read_json(&arguments.root.join("results/reference.json"))?;
    if evidence.subject != "reference" {
        return Err("SEE-PROTOCOL: evidence subject mismatch".to_owned());
    }
    for (id, hash) in &evidence.corpus_hashes {
        let specification = corpus
            .iter()
            .find(|specification| &specification.metadata.id == id)
            .ok_or("SEE-STALE: unknown evidence specification")?;
        if &see_change::hash(specification)? != hash {
            return Err("SEE-STALE: evidence corpus hash mismatch".to_owned());
        }
    }
    let conformance = load_bindings(&arguments.root.join("../pseudolearn_core"))?;
    let report = serde_json::json!({
        "conformance": see_report::matrix(corpus, &conformance, &evidence),
        "ir_coverage": see_report::coverage::table(corpus),
        "states": see_report::coverage::states(corpus),
    });
    serde_json::to_string_pretty(&report).map_err(|error| error.to_string())
}

fn load_bindings(core: &std::path::Path) -> Result<Conformance, String> {
    let text = std::fs::read_to_string(core.join("conformance.yaml"))
        .map_err(|error| error.to_string())?;
    serde_saphyr::from_str(&text).map_err(|error| error.to_string())
}

fn select(arguments: &Arguments, corpus: &Corpus, subject: &str) -> Result<Corpus, String> {
    let selected: Corpus = corpus
        .iter()
        .filter(|specification| {
            specification
                .metadata
                .sujetos
                .iter()
                .any(|candidate| candidate == subject)
                && arguments
                    .options
                    .get("only")
                    .is_none_or(|id| &specification.metadata.id == id)
        })
        .cloned()
        .collect();
    if selected.is_empty() {
        return Err("No specifications selected".to_owned());
    }
    Ok(selected)
}

fn save(
    arguments: &Arguments,
    selected: &Corpus,
    conformance: &Conformance,
    evidence: &Evidence,
) -> Result<String, String> {
    let rows = see_report::matrix(selected, conformance, evidence);
    storage::artifact(
        &arguments.root.join("results/reference.json"),
        &serde_json::json!(evidence),
        false,
    )?;
    storage::artifact(
        &arguments.root.join("results/matrix.json"),
        &serde_json::json!(rows),
        false,
    )?;
    let regressions = see_report::regressions(&rows, conformance);
    if !regressions.is_empty() {
        return Err(regressions.join("\n"));
    }
    Ok(format!(
        "Executed {} observations; {} divergences; matrix saved",
        evidence.observations.len(),
        evidence
            .observations
            .iter()
            .filter(|observation| observation.verdict == "incumple")
            .count()
    ))
}

fn subject_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
) -> Result<(std::path::PathBuf, Conformance), String> {
    let core = arguments
        .root
        .join("../pseudolearn_core")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let conformance = load_bindings(&core)?;
    let errors = see_validation::bindings::check(corpus, &conformance);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    Ok((core, conformance))
}
