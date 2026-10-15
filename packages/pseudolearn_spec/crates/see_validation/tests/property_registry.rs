mod support;
use see_model::properties::{PropertyBinding, PropertyExecutor, PropertyRegistry};

fn fixture() -> Result<(see_model::Corpus, PropertyRegistry), String> {
    let mut specification = support::specification()?;
    specification.blocks.push(see_model::Block {kind: "propiedad".to_owned(), fields: serde_json::from_value(serde_json::json!({"id": "P1", "regla": "R1", "generador": {}, "propiedad": "same", "oraculo": "independent"})).map_err(|error| error.to_string())?});
    let registry = PropertyRegistry {
        format: "see-properties/1".to_owned(),
        subjects: vec!["reference".to_owned()],
        entries: vec![PropertyBinding {
            reference: "LANG.TEST.SAMPLE@0.1.0#P1".to_owned(),
            executor: PropertyExecutor::Determinism,
            seed: 42,
            samples: 100,
        }],
    };
    Ok((vec![specification], registry))
}

#[test]
fn validates_property_identity_version_and_nonzero_samples() -> Result<(), String> {
    let (corpus, registry) = fixture()?;
    assert!(see_validation::property_registry::check(&corpus, &registry).is_empty());
    for choice in ["duplicate", "stale", "zero", "format", "missing"] {
        let mut invalid = registry.clone();
        match choice {
            "duplicate" => invalid.entries.extend(registry.entries.clone()),
            "stale" => {
                invalid
                    .entries
                    .first_mut()
                    .ok_or("Missing entry")?
                    .reference = "LANG.TEST.SAMPLE@0.2.0#P1".to_owned()
            }
            "zero" => invalid.entries.first_mut().ok_or("Missing entry")?.samples = 0,
            "missing" => invalid.entries.clear(),
            _ => invalid.format = "unknown".to_owned(),
        }
        assert!(
            see_validation::property_registry::check(&corpus, &invalid)
                .iter()
                .all(|error| error.starts_with("SEE-PROPERTY"))
        );
        assert!(!see_validation::property_registry::check(&corpus, &invalid).is_empty());
    }
    Ok(())
}

#[test]
fn rejects_unknown_algorithms_and_wrong_registry_types() -> Result<(), String> {
    let (_, registry) = fixture()?;
    let mut value = serde_json::to_value(registry).map_err(|error| error.to_string())?;
    *value
        .pointer_mut("/entries/0/executor")
        .ok_or("Missing executor")? = serde_json::json!("unimplemented");
    assert!(serde_json::from_value::<PropertyRegistry>(value.clone()).is_err());
    let schema: serde_json::Value =
        serde_json::from_str(include_str!("../../../schemas/properties-1.schema.json"))
            .map_err(|error| error.to_string())?;
    assert!(see_validation::schema_engine::check(&value, &schema, &schema, 0).is_err());
    assert!(
        serde_json::from_value::<PropertyRegistry>(
            serde_json::json!({"format": "see-properties/1", "entries": "invalid"})
        )
        .is_err()
    );
    Ok(())
}
