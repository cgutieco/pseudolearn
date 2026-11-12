#![forbid(unsafe_code)]

pub mod coverage;

use see_model::{
    Corpus,
    contract::Manifest,
    evidence::{Conformance, Evidence},
    field,
};
use serde_json::{Value, json};

pub fn matrix(corpus: &Corpus, conformance: &Conformance, evidence: &Evidence) -> Vec<Value> {
    let mut rows = Vec::new();
    for specification in corpus
        .iter()
        .filter(|specification| specification.metadata.sujetos.contains(&conformance.sujeto))
    {
        for rule in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "regla")
        {
            rows.push(row(specification, rule, conformance, evidence));
        }
    }
    rows
}

fn row(
    specification: &see_model::Specification,
    rule: &see_model::Block,
    conformance: &Conformance,
    evidence: &Evidence,
) -> Value {
    if conformance.estado == "retirado" {
        return retired_row(specification, rule, conformance);
    }
    let reference = format!(
        "{}@{}#{}",
        specification.metadata.id,
        specification.metadata.version,
        field(rule, "id")
    );
    let binding = conformance.vinculos.iter().find(|binding| {
        binding.regla == reference
            || binding.regla
                == format!(
                    "{}@{}",
                    specification.metadata.id, specification.metadata.version
                )
    });
    let observations: Vec<_> = evidence
        .observations
        .iter()
        .filter(|observation| {
            observation.specification == specification.metadata.id
                && observation.rule == field(rule, "id")
        })
        .collect();
    let measurements = coverage::measurements(specification, rule);
    let verdicts = collect_verdicts(&observations, specification, rule, evidence);
    let measured = if verdicts.is_empty() && !measurements.is_empty() {
        "no aplicable"
    } else {
        measurement(&verdicts)
    };
    json!({"rule": reference, "subject": conformance.sujeto, "binding": binding.map_or("sin vinculo", |binding| binding.estado.as_str()), "measured": measured, "reason": binding.and_then(|binding| binding.justificacion.as_ref()), "cases": verdicts.len(), "measurements": measurements, "state": specification.metadata.estado})
}

fn retired_row(
    specification: &see_model::Specification,
    rule: &see_model::Block,
    conformance: &Conformance,
) -> Value {
    json!({"rule": format!("{}@{}#{}", specification.metadata.id,
            specification.metadata.version, field(rule, "id")),
            "subject": conformance.sujeto, "binding": "no aplicable",
            "measured": "no aplicable", "reason": "retired subject",
            "cases": 0, "measurements": [], "state": specification.metadata.estado})
}

pub fn regressions(rows: &[Value], conformance: &Conformance) -> Vec<String> {
    if conformance.estado == "retirado" {
        return Vec::new();
    }
    rows.iter()
        .filter(|row| {
            let state = row.get("state").and_then(Value::as_str).unwrap_or("");
            let active = state == "estable"
                || (state == "experimental"
                    && row
                        .get("rule")
                        .and_then(Value::as_str)
                        .is_some_and(|reference| {
                            conformance
                                .activadas
                                .iter()
                                .any(|id| reference.starts_with(&format!("{id}@")))
                        }));
            active
                && row.get("binding").and_then(Value::as_str) == Some("cumple")
                && row.get("measured").and_then(Value::as_str) != Some("cumple")
        })
        .map(|row| format!("SEE-REGRESSION: {row}"))
        .collect()
}

pub fn feature(corpus: &Corpus, manifest: &Manifest) -> Result<Value, String> {
    let mut states = Vec::new();
    for id in &manifest.especificaciones {
        let specification = corpus
            .iter()
            .find(|specification| &specification.metadata.id == id)
            .ok_or(format!("SEE-FEATURE: unknown specification {id}"))?;
        states.push(specification.metadata.estado.as_str());
    }
    let order = [
        "rechazada",
        "retirada",
        "borrador",
        "propuesta",
        "experimental",
        "obsoleta",
        "estable",
    ];
    let state = order
        .iter()
        .find(|state| states.contains(state))
        .ok_or("SEE-FEATURE: empty manifest")?;
    Ok(
        json!({"feature":manifest.caracteristica, "state":state, "specifications":manifest.especificaciones, "criteria":manifest.criterio_de_terminado}),
    )
}

fn collect_verdicts<'evidence>(
    observations: &[&'evidence see_model::evidence::Observation],
    specification: &see_model::Specification,
    rule: &see_model::Block,
    evidence: &'evidence Evidence,
) -> Vec<&'evidence str> {
    let mut verdicts: Vec<&str> = observations
        .iter()
        .map(|observation| observation.verdict.as_str())
        .collect();
    verdicts.extend(property_verdicts(specification, rule, evidence));
    verdicts
}

fn property_verdicts<'evidence>(
    specification: &see_model::Specification,
    rule: &see_model::Block,
    evidence: &'evidence Evidence,
) -> Vec<&'evidence str> {
    let verifying = see_model::strings(rule.fields.get("verificacion"));
    let identity = format!(
        "{}@{}",
        specification.metadata.id, specification.metadata.version
    );
    evidence
        .properties
        .iter()
        .filter(|run| run.specification == identity && verifying.contains(&run.property.as_str()))
        .map(|run| run.verdict.as_str())
        .collect()
}

fn measurement(verdicts: &[&str]) -> &'static str {
    if verdicts.is_empty() {
        return "sin evidencia";
    }
    ["incumple", "pendiente", "no aplicable"]
        .into_iter()
        .find(|verdict| verdicts.contains(verdict))
        .unwrap_or("cumple")
}
