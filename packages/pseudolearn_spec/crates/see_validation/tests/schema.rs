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
