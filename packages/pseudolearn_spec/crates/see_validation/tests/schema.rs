mod support;

#[test]
fn schema_rejects_wrong_types_unknown_observations_and_missing_programs() -> Result<(), String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields
        .insert("espera".to_owned(), serde_json::json!({"salida":7}));
    assert!(!see_validation::schema::check(&specification).is_empty());
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("espera".to_owned(), serde_json::json!({"unknown":true}));
    assert!(!see_validation::schema::check(&specification).is_empty());
    Ok(())
}

#[test]
fn rejects_wrong_case_origin_and_empty_profiles() -> Result<(), String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields
        .insert("origen".to_owned(), serde_json::json!("unknown"));
    case.fields
        .insert("perfiles".to_owned(), serde_json::json!([]));
    let errors = see_validation::schema::check(&specification);
    assert!(errors.iter().any(|error| error.starts_with("SEE-ORIGIN")));
    assert!(errors.iter().any(|error| error.starts_with("SEE-PROFILE")));
    Ok(())
}

#[test]
fn accepts_signed_seed_boundaries_and_rejects_non_integer_seeds() -> Result<(), String> {
    for seed in [
        serde_json::json!(0),
        serde_json::json!(-1),
        serde_json::json!(i64::MAX),
    ] {
        let mut specification = support::specification()?;
        specification
            .blocks
            .last_mut()
            .ok_or("Missing case")?
            .fields
            .insert("semilla".to_owned(), seed);
        assert!(see_validation::schema::check(&specification).is_empty());
    }
    for seed in [serde_json::json!("42"), serde_json::json!(u64::MAX)] {
        let mut specification = support::specification()?;
        specification
            .blocks
            .last_mut()
            .ok_or("Missing case")?
            .fields
            .insert("semilla".to_owned(), seed);
        assert!(!see_validation::schema::check(&specification).is_empty());
    }
    Ok(())
}

#[test]
fn validates_loop_poll_cancellation_ordinal() -> Result<(), String> {
    for (ordinal, valid) in [
        (serde_json::json!(0), true),
        (serde_json::json!(u64::MAX), true),
        (serde_json::json!(-1), false),
        (serde_json::json!(1.5), false),
        (serde_json::json!("2"), false),
    ] {
        let mut specification = support::specification()?;
        specification
            .blocks
            .last_mut()
            .ok_or("Missing case")?
            .fields
            .insert("cancelacion_prueba".to_owned(), ordinal);
        assert_eq!(
            see_validation::schema::check(&specification).is_empty(),
            valid
        );
    }
    Ok(())
}
