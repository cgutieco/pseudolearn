use crate::property_selection::{number, selected};
use crate::{arguments::Arguments, storage};
use see_conformance::{
    properties::{self, PropertyContext},
    protocol::Session,
};
use see_model::{Corpus, contract::Vocabulary, evidence::Evidence, properties::PropertyRegistry};
use std::time::Duration;

pub fn execute(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let subject = arguments
        .options
        .get("subject")
        .ok_or("Missing --subject")?;
    let (mut command, _) = crate::conformance::subject_configuration(arguments, corpus, subject)?;
    let registry: PropertyRegistry =
        storage::read_json(&arguments.root.join("property-conformance.json"))?;
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let mut session = Session::start(&mut command, Duration::from_secs(30))?;
    let context = PropertyContext {
        corpus,
        vocabulary: &vocabulary,
        subject,
        first_sample: number(arguments, "sample")?.unwrap_or(0),
        exhaustive: !arguments.options.contains_key("sample"),
    };
    let bindings = selected(arguments, corpus, registry.entries)?;
    let mut reports = Vec::new();
    for binding in &bindings {
        reports.push(properties::run(binding, &context, &mut session)?);
    }
    let evidence = Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject: subject.clone(),
        subject_version: session
            .hello
            .get("subject_version")
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing subject version")?
            .to_owned(),
        corpus_hashes: hashes(corpus)?,
        observations: Vec::new(),
        properties: reports,
        stderr: session.finish()?,
    };
    save(arguments, &evidence)
}

fn save(arguments: &Arguments, evidence: &Evidence) -> Result<String, String> {
    storage::artifact(
        &arguments
            .root
            .join(format!("results/properties-{}.json", evidence.subject)),
        &serde_json::json!(evidence),
        false,
    )?;
    let completed = evidence
        .properties
        .iter()
        .filter(|report| report.verdict == "cumple")
        .count();
    if completed != evidence.properties.len() {
        return Err(format!(
            "SEE-PROPERTY: {completed}/{} properties pass; evidence saved",
            evidence.properties.len()
        ));
    }
    Ok(format!("Executed {completed} properties; evidence saved"))
}

fn hashes(corpus: &Corpus) -> Result<std::collections::BTreeMap<String, String>, String> {
    corpus
        .iter()
        .map(|specification| {
            Ok((
                specification.metadata.id.clone(),
                see_change::hash(specification)?,
            ))
        })
        .collect()
}
