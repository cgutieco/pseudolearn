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
    let (mut command, _) =
        crate::subject_adapters::subject_configuration(arguments, corpus, subject)?;
    let registry: PropertyRegistry =
        storage::read_json(&arguments.root.join("property-conformance.json"))?;
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let mut session = Session::start(&mut command, Duration::from_secs(300))?;
    let context = PropertyContext {
        corpus,
        vocabulary: &vocabulary,
        subject,
        first_sample: number(arguments, "sample")?.unwrap_or(0),
        exhaustive: !arguments.options.contains_key("sample"),
    };
    let bindings = selected(arguments, corpus, registry.entries)?;
    let status = crate::rule_status::RuleStatus::load(&arguments.root, subject)?;
    let reports = run_bindings(&bindings, &context, (&mut session, arguments), &status)?;
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
    let path = arguments.options.get("output").map_or_else(
        || {
            arguments
                .root
                .join(format!("results/properties-{}.json", evidence.subject))
        },
        |output| arguments.root.join(output),
    );
    storage::artifact(&path, &serde_json::json!(evidence), false)?;
    let count = |verdict: &str| {
        evidence
            .properties
            .iter()
            .filter(|report| report.verdict == verdict)
            .count()
    };
    let (completed, pending, failed) = (count("cumple"), count("pendiente"), count("incumple"));
    if failed > 0 {
        return Err(format!(
            "SEE-PROPERTY: {failed}/{} properties fail; evidence saved",
            evidence.properties.len()
        ));
    }
    Ok(format!(
        "Executed {completed} properties; {pending} pending for unavailable capabilities; evidence saved"
    ))
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

fn run_bindings(
    bindings: &[see_model::properties::PropertyBinding],
    context: &PropertyContext<'_>,
    input: (&mut Session, &Arguments),
    status: &crate::rule_status::RuleStatus,
) -> Result<Vec<see_model::properties::PropertyRun>, String> {
    let (session, arguments) = input;
    let mut reports = Vec::new();
    for binding in bindings {
        let report = if status.property_is_pending(context.corpus, &binding.reference) {
            crate::native_properties::pending_report(binding)?
        } else if crate::native_properties::supports(binding.executor) {
            crate::native_properties::run(binding, arguments, context.corpus, session)?
        } else {
            properties::run(binding, context, session)?
        };
        let unavailable = report.verdict == "pendiente";
        if !(unavailable && status.property_is_exempt(context.corpus, &binding.reference)) {
            reports.push(report);
        }
    }
    Ok(reports)
}
