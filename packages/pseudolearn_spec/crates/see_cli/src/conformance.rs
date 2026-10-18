use crate::{arguments::Arguments, storage};
use see_model::{
    Corpus,
    contract::Vocabulary,
    evidence::{Conformance, Evidence},
};
use std::time::Duration;

pub fn execute(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    if arguments.options.get("operation").map(String::as_str) == Some("properties") {
        return crate::property_execution::execute(arguments, corpus);
    }
    let subject = arguments
        .options
        .get("subject")
        .ok_or("Missing --subject")?;
    let (mut command, conformance) =
        crate::subject_adapters::subject_configuration(arguments, corpus, subject)?;
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
    crate::structural_evidence::append(arguments, &selected, &conformance, &mut evidence)?;
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
    let evidence = with_properties(arguments, subject, evidence)?;
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
    let manifest = crate::bindings::manifest_path(&arguments.root, subject)
        .ok_or("SEE-BINDING: unknown subject")?;
    let conformance = crate::subject_adapters::load_bindings(&manifest)?;
    let selected = select(arguments, corpus, subject)?;
    let report = serde_json::json!({
        "conformance": see_report::matrix(&selected, &conformance, &evidence),
        "ir_coverage": see_report::coverage::table(corpus),
        "states": see_report::coverage::states(corpus),
    });
    serde_json::to_string_pretty(&report).map_err(|error| error.to_string())
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

fn with_properties(
    arguments: &Arguments,
    subject: &str,
    mut evidence: Evidence,
) -> Result<Evidence, String> {
    let path = arguments
        .root
        .join(format!("results/properties-{subject}.json"));
    if path.exists() {
        let recorded: Evidence = storage::read_json(&path)?;
        evidence.properties.extend(recorded.properties);
    }
    Ok(evidence)
}

fn save(
    arguments: &Arguments,
    selected: &Corpus,
    conformance: &Conformance,
    evidence: &Evidence,
) -> Result<String, String> {
    let subject = arguments
        .options
        .get("subject")
        .map_or("reference", String::as_str);
    let combined = with_properties(arguments, subject, evidence.clone())?;
    let rows = see_report::matrix(selected, conformance, &combined);
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
