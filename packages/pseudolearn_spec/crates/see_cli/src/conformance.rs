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
    let (mut command, conformance) = subject_configuration(arguments, corpus, subject)?;
    let selected = select(arguments, corpus, subject)?;
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
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
    let operation_filter = arguments.options.get("operation").map(String::as_str);
    let mut evidence = see_conformance::execution::execute(
        &selected,
        &vocabulary,
        &mut session,
        operation_filter,
    )?;
    for specification in &selected {
        evidence.corpus_hashes.insert(
            specification.metadata.id.clone(),
            see_change::hash(specification)?,
        );
    }
    save(arguments, &selected, &conformance, &evidence)
}

pub fn matrix(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let subject = arguments
        .options
        .get("subject")
        .map_or("reference", String::as_str);
    let result_path = if subject == "reference" {
        "results/reference.json".to_owned()
    } else {
        format!("results/{subject}.json")
    };
    let evidence: Evidence = storage::read_json(&arguments.root.join(&result_path))?;
    if evidence.subject != subject {
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
    let bindings_root = match subject {
        "engine" => arguments.root.join("../pseudolearn_engine"),
        "cli" => arguments.root.join("../../apps/pseudolearn_cli"),
        _ => arguments.root.join("../pseudolearn_core"),
    };
    let conformance = load_bindings(&bindings_root)?;
    let selected = select(arguments, corpus, subject)?;
    let report = serde_json::json!({
        "conformance": see_report::matrix(&selected, &conformance, &evidence),
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
    let operation_filter = arguments.options.get("operation").map(String::as_str);
    let selected: Corpus = corpus
        .iter()
        .filter(|specification| {
            let matches_subject = specification
                .metadata
                .sujetos
                .iter()
                .any(|candidate| candidate == subject);
            let matches_only = arguments
                .options
                .get("only")
                .is_none_or(|id| &specification.metadata.id == id);
            let matches_operation = operation_filter.is_none_or(|target_operation| {
                specification.blocks.iter().any(|block| {
                    block.kind == "caso"
                        && see_conformance::requests::operation(block) == target_operation
                })
            });
            matches_subject && matches_only && matches_operation
        })
        .cloned()
        .collect();
    if selected.is_empty() {
        return Err("No specifications selected".to_owned());
    }
    Ok(selected)
}

fn artifact_paths(subject: &str) -> (String, String) {
    if subject == "reference" {
        (
            "results/reference.json".to_owned(),
            "results/matrix.json".to_owned(),
        )
    } else {
        (
            format!("results/{subject}.json"),
            format!("results/matrix-{subject}.json"),
        )
    }
}

fn save(
    arguments: &Arguments,
    selected: &Corpus,
    conformance: &Conformance,
    evidence: &Evidence,
) -> Result<String, String> {
    let rows = see_report::matrix(selected, conformance, evidence);
    let subject = arguments
        .options
        .get("subject")
        .map_or("reference", String::as_str);
    let (result_file, matrix_file) = artifact_paths(subject);
    storage::artifact(
        &arguments.root.join(result_file),
        &serde_json::json!(evidence),
        false,
    )?;
    storage::artifact(
        &arguments.root.join(matrix_file),
        &serde_json::json!(rows),
        false,
    )?;
    let regressions = see_report::regressions(&rows, conformance);
    if !regressions.is_empty() {
        return Err(regressions.join("\n"));
    }
    let divergence_count = evidence
        .observations
        .iter()
        .filter(|observation| observation.verdict == "incumple")
        .count();
    Ok(format!(
        "Executed {} observations; {} divergences; matrix saved",
        evidence.observations.len(),
        divergence_count,
    ))
}

fn subject_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
    subject: &str,
) -> Result<(Command, Conformance), String> {
    match subject {
        "reference" => reference_configuration(arguments, corpus),
        "engine" => engine_configuration(arguments, corpus),
        "cli" => cli_configuration(arguments, corpus),
        _ => Err("Unknown subject".to_owned()),
    }
}

fn reference_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
) -> Result<(Command, Conformance), String> {
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
    let mut command = Command::new("dart");
    command
        .current_dir(core)
        .args(["run", "tool/conformance_adapter.dart"]);
    Ok((command, conformance))
}

fn engine_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
) -> Result<(Command, Conformance), String> {
    let engine = arguments
        .root
        .join("../pseudolearn_engine")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let conformance = load_bindings(&engine)?;
    let errors = see_validation::bindings::check(corpus, &conformance);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    let mut command = Command::new("cargo");
    command.current_dir(&engine).args([
        "run",
        "-p",
        "pseudolearn_conformance",
        "--bin",
        "conformance_adapter",
        "--quiet",
    ]);
    Ok((command, conformance))
}

fn cli_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
) -> Result<(Command, Conformance), String> {
    let cli_dir = arguments
        .root
        .join("../../apps/pseudolearn_cli")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let conformance = load_bindings(&cli_dir)?;
    let errors = see_validation::bindings::check(corpus, &conformance);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    let mut command = Command::new("cargo");
    command.current_dir(&cli_dir).args([
        "run",
        "--bin",
        "pseudo",
        "--quiet",
        "--",
        "--see-adapter",
    ]);
    Ok((command, conformance))
}
