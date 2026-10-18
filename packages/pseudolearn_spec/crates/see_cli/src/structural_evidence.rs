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
            if !bindings
                .vinculos
                .iter()
                .any(|binding| binding.regla == reference && binding.verificacion == "estructural")
            {
                continue;
            }
            if !see_model::strings(rule.fields.get("verificacion")).contains(&"estructural") {
                return Err(format!(
                    "SEE-STRUCTURAL: incompatible verification {reference}"
                ));
            }
            let proof = json!({"validator":"see validate","passed":true,"corpus_hash":see_change::hash(specification)?});
            evidence.observations.push(Observation {
                specification: specification.metadata.id.clone(),
                rule: field(rule, "id").to_owned(),
                case: "estructural".to_owned(),
                profile: "independent".to_owned(),
                strictness: "independent".to_owned(),
                verdict: "cumple".to_owned(),
                differences: Vec::new(),
                expected: proof.clone(),
                actual: proof,
            });
        }
    }
    Ok(())
}
