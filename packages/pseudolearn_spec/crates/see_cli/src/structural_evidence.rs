use crate::{arguments::Arguments, storage};
use see_model::{
    Corpus,
    evidence::{Conformance, Evidence, Observation},
    field,
};
use serde_json::json;

pub fn append(
    arguments: &Arguments,
    corpus: &Corpus,
    bindings: &Conformance,
    evidence: &mut Evidence,
) -> Result<(), String> {
    storage::valid(&arguments.root)?;
    for specification in corpus {
        for rule in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "regla")
        {
            let reference = format!(
                "{}@{}#{}",
                specification.metadata.id,
                specification.metadata.version,
                field(rule, "id")
            );
            if !is_structurally_bound(bindings, &reference) {
                continue;
            }
            if !see_model::strings(rule.fields.get("verificacion")).contains(&"estructural") {
                return Err(format!(
                    "SEE-STRUCTURAL: incompatible verification {reference}"
                ));
            }
            evidence
                .observations
                .push(structural_observation(specification, field(rule, "id"))?);
        }
    }
    Ok(())
}

fn is_structurally_bound(bindings: &Conformance, reference: &str) -> bool {
    bindings
        .vinculos
        .iter()
        .any(|binding| binding.regla == reference && binding.verificacion == "estructural")
}

fn structural_observation(
    specification: &see_model::Specification,
    rule: &str,
) -> Result<Observation, String> {
    let proof = json!({"validator":"see validate","passed":true,"corpus_hash":see_change::hash(specification)?});
    Ok(Observation {
        specification: specification.metadata.id.clone(),
        rule: rule.to_owned(),
        case: "estructural".to_owned(),
        profile: "independent".to_owned(),
        strictness: "independent".to_owned(),
        verdict: "cumple".to_owned(),
        differences: Vec::new(),
        expected: proof.clone(),
        actual: proof,
    })
}
