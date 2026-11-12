use see_model::{Corpus, field};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub fn table(corpus: &Corpus) -> Vec<Value> {
    corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == "cobertura")
        .map(|entry| {
            json!({
                "rule": field(entry, "regla"),
                "instructions": entry.fields.get("instrucciones").cloned().unwrap_or(json!([])),
                "without_ir": entry.fields.get("sin_ri"),
            })
        })
        .collect()
}

pub fn states(corpus: &Corpus) -> BTreeMap<String, BTreeMap<String, usize>> {
    let mut states = BTreeMap::<String, BTreeMap<String, usize>>::new();
    for specification in corpus {
        let domain = specification
            .metadata
            .id
            .split('.')
            .next()
            .unwrap_or_default()
            .to_owned();
        let counter = states
            .entry(domain)
            .or_default()
            .entry(specification.metadata.estado.clone())
            .or_default();
        *counter = counter.saturating_add(1);
    }
    states
}

pub fn measurements(
    specification: &see_model::Specification,
    rule: &see_model::Block,
) -> Vec<Value> {
    let cited = see_model::strings(rule.fields.get("verificacion"));
    specification
        .blocks
        .iter()
        .filter(|block| block.kind == "medicion" && cited.contains(&field(block, "id")))
        .map(|measurement| {
            json!({
                "id": field(measurement, "id"),
                "suite": field(measurement, "suite"),
                "protocol": field(measurement, "protocolo"),
                "provisional": measurement.fields.get("provisional"),
            })
        })
        .collect()
}
