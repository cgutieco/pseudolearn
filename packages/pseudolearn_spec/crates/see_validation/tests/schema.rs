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

#[test]
fn validates_expected_token_identities_and_spans() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "espera".to_owned(),
            serde_json::json!({"tokens_include": [{
                "kind": "keyword",
                "keyword": "algorithm",
                "span": {
                    "start": {"line": 1, "column": 1},
                    "end": {"line": 1, "column": 10}
                }
            }]}),
        );
    assert!(see_validation::schema::check(&specification).is_empty());
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "espera".to_owned(),
            serde_json::json!({"tokens_include": [{
                "kind": "keyword",
                "span": {"start": {"line": 0, "column": 1}, "end": {"line": 1, "column": 2}}
            }]}),
        );
    assert!(!see_validation::schema::check(&specification).is_empty());
    Ok(())
}

#[test]
fn application_cases_require_a_known_scenario_and_input_object() -> Result<(), String> {
    let mut specification = support::specification()?;
    {
        let case = specification.blocks.last_mut().ok_or("Missing case")?;
        case.fields
            .insert("operacion".to_owned(), serde_json::json!("app"));
        case.fields.insert(
            "aplicacion".to_owned(),
            serde_json::json!({"scenario": "pace", "input": {"pace": "nextStatement"}}),
        );
    }
    assert!(see_validation::schema::check(&specification).is_empty());
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "aplicacion".to_owned(),
            serde_json::json!({"scenario": "unknown", "input": {}}),
        );
    assert!(!see_validation::schema::check(&specification).is_empty());
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "aplicacion".to_owned(),
            serde_json::json!({"scenario": "pace"}),
        );
    assert!(!see_validation::schema::check(&specification).is_empty());
    Ok(())
}

#[test]
fn application_inputs_are_rejected_on_non_application_cases() -> Result<(), String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields.insert(
        "aplicacion".to_owned(),
        serde_json::json!({"scenario": "pace", "input": {}}),
    );
    let errors = see_validation::schema::check(&specification);
    assert!(errors.iter().any(|error| error.starts_with("SEE-APP-CASE")));
    Ok(())
}

#[test]
fn paginated_state_cases_reject_invalid_cursor_types_and_page_sizes() -> Result<(), String> {
    for pagination in [
        serde_json::json!({"query": "array_cells", "event": 0, "page_size": 0, "cursor": null}),
        serde_json::json!({"query": "array_cells", "event": 0, "page_size": 2, "cursor": 4}),
        serde_json::json!({"query": "array_cells", "event": -1, "page_size": 2, "cursor": null}),
    ] {
        let mut specification = support::specification()?;
        specification
            .blocks
            .last_mut()
            .ok_or("Missing case")?
            .fields
            .insert("paginacion".to_owned(), pagination);
        assert!(!see_validation::schema::check(&specification).is_empty());
    }
    Ok(())
}

#[test]
fn paginated_queries_accept_object_targets_and_reject_malformed_targets() -> Result<(), String> {
    for (target, valid) in [
        (serde_json::json!(0), true),
        (serde_json::json!(1), true),
        (serde_json::json!(-1), false),
        (serde_json::json!("1"), false),
    ] {
        let mut specification = support::specification()?;
        let case = specification.blocks.last_mut().ok_or("missing case")?;
        case.fields.insert("paginacion".to_owned(), serde_json::json!({"query":"array_cells","target":target,"event":1,"page_size":2,"cursor":null}));
        assert_eq!(
            see_validation::schema::check(&specification).is_empty(),
            valid
        );
    }
    Ok(())
}
