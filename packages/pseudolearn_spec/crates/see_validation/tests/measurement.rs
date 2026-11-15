mod support;

use serde_json::json;

fn corpus(subjects: serde_json::Value) -> Result<see_model::Corpus, String> {
    let mut specification = support::specification()?;
    specification.metadata.id = "PERF.PROTOCOL".to_owned();
    specification.metadata.dominio = "rendimiento".to_owned();
    specification.metadata.sujetos = vec!["engine".to_owned(), "app".to_owned()];
    specification.blocks = vec![
        see_model::Block {
            kind: "regla".to_owned(),
            fields: serde_json::from_value(json!({"id": "R1"}))
                .map_err(|error| error.to_string())?,
        },
        see_model::Block {
            kind: "medicion".to_owned(),
            fields: serde_json::from_value(json!({
                "id": "M1",
                "metrica": "latency",
                "unidad": "ms",
                "suite": "sample",
                "comparador": "<=",
                "umbral": 1,
                "provisional": true,
                "plataformas": ["sample"],
                "protocolo": "PERF.PROTOCOL#R1",
                "sujetos": subjects
            }))
            .map_err(|error| error.to_string())?,
        },
    ];
    Ok(vec![specification])
}

#[test]
fn validates_explicit_measurement_subjects_and_rejects_out_of_scope_subjects() -> Result<(), String>
{
    assert!(see_validation::measurement::check(&corpus(json!(["app"]))?).is_empty());
    let errors = see_validation::measurement::check(&corpus(json!(["wasm"]))?);
    assert!(
        errors
            .iter()
            .any(|error| error.starts_with("SEE-MEASUREMENT-SUBJECT"))
    );
    Ok(())
}

#[test]
fn accepts_unscoped_measurements_for_single_subject_specifications() -> Result<(), String> {
    let mut corpus = corpus(json!(["engine"]))?;
    corpus
        .first_mut()
        .ok_or("Missing specification")?
        .metadata
        .sujetos = vec!["engine".to_owned()];
    corpus
        .first_mut()
        .and_then(|specification| specification.blocks.last_mut())
        .ok_or("Missing measurement")?
        .fields
        .remove("sujetos");
    assert!(see_validation::measurement::check(&corpus).is_empty());
    Ok(())
}

#[test]
fn requires_measurement_scope_when_a_specification_has_multiple_subjects() -> Result<(), String> {
    let mut corpus = corpus(json!(["engine"]))?;
    corpus
        .first_mut()
        .and_then(|specification| specification.blocks.last_mut())
        .ok_or("Missing measurement")?
        .fields
        .remove("sujetos");
    let errors = see_validation::measurement::check(&corpus);
    assert!(
        errors
            .iter()
            .any(|error| error.starts_with("SEE-MEASUREMENT-SUBJECT"))
    );
    Ok(())
}

#[test]
fn rejects_unknown_measurement_protocol_rules() -> Result<(), String> {
    let mut corpus = corpus(json!(["engine"]))?;
    corpus
        .first_mut()
        .and_then(|specification| specification.blocks.last_mut())
        .ok_or("Missing measurement")?
        .fields
        .insert("protocolo".to_owned(), json!("PERF.PROTOCOL#R9"));
    let errors = see_validation::measurement::check(&corpus);
    assert!(
        errors
            .iter()
            .any(|error| error.starts_with("SEE-MEASUREMENT-PROTOCOL"))
    );
    Ok(())
}
