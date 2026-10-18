use crate::{arguments::Arguments, storage, structural_evidence};
use see_model::{
    Corpus,
    evidence::{Binding, Conformance, Evidence},
    field,
};
use std::collections::BTreeMap;

fn arguments() -> Arguments {
    Arguments {
        command: "conform".to_owned(),
        positional: Vec::new(),
        options: BTreeMap::new(),
        root: std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../.."),
    }
}

fn evidence() -> Evidence {
    Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject: "aot".to_owned(),
        subject_version: "test".to_owned(),
        corpus_hashes: BTreeMap::new(),
        observations: Vec::new(),
        properties: Vec::new(),
        stderr: String::new(),
    }
}

fn bindings(corpus: &Corpus, structural: bool) -> Result<Conformance, String> {
    let reference = corpus
        .iter()
        .find_map(|specification| {
            specification
                .blocks
                .iter()
                .find(|block| {
                    block.kind == "regla"
                        && see_model::strings(block.fields.get("verificacion"))
                            .contains(&"estructural")
                            == structural
                })
                .map(|rule| {
                    format!(
                        "{}@{}#{}",
                        specification.metadata.id,
                        specification.metadata.version,
                        field(rule, "id")
                    )
                })
        })
        .ok_or("Missing verification fixture")?;
    Ok(Conformance {
        sujeto: "aot".to_owned(),
        paquete: "test".to_owned(),
        activadas: Vec::new(),
        fases_cerradas: Vec::new(),
        vinculos: vec![Binding {
            regla: reference,
            verificacion: "estructural".to_owned(),
            estado: "cumple".to_owned(),
            resuelve_en: None,
            justificacion: None,
        }],
    })
}

#[test]
fn successful_validation_is_recorded_with_the_corpus_hash() -> Result<(), String> {
    let arguments = arguments();
    let corpus = storage::corpus(&arguments.root)?;
    let mut evidence = evidence();
    structural_evidence::append(
        &arguments,
        &corpus,
        &bindings(&corpus, true)?,
        &mut evidence,
    )?;
    assert_eq!(evidence.observations.len(), 1);
    let observation = evidence.observations.first().ok_or("Missing observation")?;
    assert_eq!(observation.verdict, "cumple");
    assert_eq!(
        observation
            .actual
            .get("validator")
            .and_then(serde_json::Value::as_str),
        Some("see validate")
    );
    assert!(
        observation
            .actual
            .get("corpus_hash")
            .and_then(serde_json::Value::as_str)
            .is_some_and(|hash| !hash.is_empty())
    );
    Ok(())
}

#[test]
fn invalid_corpus_and_nonstructural_rules_cannot_receive_structural_proof() -> Result<(), String> {
    let mut arguments = arguments();
    let corpus = storage::corpus(&arguments.root)?;
    let mut evidence = evidence();
    assert!(
        structural_evidence::append(
            &arguments,
            &corpus,
            &bindings(&corpus, false)?,
            &mut evidence
        )
        .is_err()
    );
    assert!(evidence.observations.is_empty());
    arguments.root = arguments.root.join("missing-structural-corpus");
    assert!(
        structural_evidence::append(
            &arguments,
            &corpus,
            &bindings(&corpus, true)?,
            &mut evidence
        )
        .is_err()
    );
    assert!(evidence.observations.is_empty());
    Ok(())
}
