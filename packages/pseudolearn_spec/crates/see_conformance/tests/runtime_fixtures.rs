mod support;
use see_conformance::runtime_fixtures::cases;
use serde_json::json;

#[test]
fn fixture_generation_reuses_requests_and_resolved_expectations() -> Result<(), String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields.insert("operacion".to_owned(), json!("execute"));
    case.fields.insert("perfiles".to_owned(), json!(["es"]));
    let fixtures = cases(&vec![specification.clone()], &Default::default())?;
    assert_eq!(fixtures.len(), 1);
    assert_eq!(
        fixtures
            .first()
            .and_then(|fixture| fixture.pointer("/request/kind")),
        Some(&json!("execute"))
    );
    assert!(
        fixtures
            .first()
            .is_some_and(|fixture| fixture.pointer("/request/strictness").is_none())
    );
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields.remove("espera");
    case.fields.remove("esperas");
    assert!(cases(&vec![specification], &Default::default()).is_err());
    Ok(())
}

#[test]
fn non_execution_cases_are_not_materialized() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("operacion".to_owned(), json!("analyze"));
    assert!(cases(&vec![specification], &Default::default())?.is_empty());
    assert!(cases(&Vec::new(), &Default::default())?.is_empty());
    Ok(())
}
