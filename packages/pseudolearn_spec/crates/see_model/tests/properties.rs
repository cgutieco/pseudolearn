use see_model::properties::{Counterexample, PropertyRun};
use serde_json::json;

#[test]
fn preserves_counterexample_and_reproduction_without_running_it() -> Result<(), String> {
    let record = PropertyRun {
        specification: "ENG.EXEC.MODEL".to_owned(),
        property: "P1".to_owned(),
        seed: 42,
        samples: 100,
        completed: 3,
        verdict: "incumple".to_owned(),
        counterexample: Some(Counterexample {
            sample: 2,
            profile: "es".to_owned(),
            strictness: "strict".to_owned(),
            program: "program".to_owned(),
            expected: json!({"output": "1"}),
            actual: json!({"output": "2"}),
            reproduction: vec!["cargo".to_owned(), "run".to_owned()],
        }),
    };
    let encoded = serde_json::to_string(&record).map_err(|error| error.to_string())?;
    let decoded: PropertyRun = serde_json::from_str(&encoded).map_err(|error| error.to_string())?;
    assert_eq!(decoded, record);
    let mut invalid = serde_json::to_value(record).map_err(|error| error.to_string())?;
    invalid
        .as_object_mut()
        .ok_or("Missing record")?
        .insert("unknown".to_owned(), json!(true));
    assert!(serde_json::from_value::<PropertyRun>(invalid).is_err());
    Ok(())
}

#[test]
fn reads_historical_evidence_without_property_runs() -> Result<(), String> {
    let evidence: see_model::evidence::Evidence = serde_json::from_value(json!({"protocol": "see-protocol/1", "subject": "reference", "subject_version": "1", "corpus_hashes": {}, "observations": [], "stderr": ""})).map_err(|error| error.to_string())?;
    assert!(evidence.properties.is_empty());
    assert!(
        serde_json::to_value(evidence)
            .map_err(|error| error.to_string())?
            .get("properties")
            .is_none()
    );
    Ok(())
}
