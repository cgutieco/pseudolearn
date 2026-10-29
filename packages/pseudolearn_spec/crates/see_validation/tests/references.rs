mod support;

#[test]
fn justified_exclusion_and_human_review_are_valid() -> Result<(), String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    case.fields
        .insert("perfiles".to_owned(), serde_json::json!(["es"]));
    case.fields.insert(
        "exclusiones".to_owned(),
        serde_json::json!({"en":"Identificador reservado en destino"}),
    );
    assert!(see_validation::references::check(&specification).is_empty());
    let rule = specification.blocks.first_mut().ok_or("Missing rule")?;
    rule.fields.insert(
        "verificacion".to_owned(),
        serde_json::json!(["revision_humana"]),
    );
    assert!(!see_validation::references::check(&specification).is_empty());
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert(
            "justificacion".to_owned(),
            serde_json::json!("Revisión contractual"),
        );
    assert!(see_validation::references::check(&specification).is_empty());
    Ok(())
}

#[test]
fn rejects_external_documentation_links_in_rule_prose() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("referencias".to_owned(), serde_json::json!(["C1"]));
    assert!(see_validation::references::check(&specification).is_empty());
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert(
            "texto".to_owned(),
            serde_json::json!("See www.example.com/language-reference"),
        );
    assert!(
        see_validation::references::check(&specification)
            .iter()
            .any(|error| error == "SEE-REFERENCE: external documentation link forbidden")
    );
    Ok(())
}

#[test]
fn allows_http_urls_in_case_contracts() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "anfitrion".to_owned(),
            serde_json::json!({"http":{"GET https://fake.test/a":{"estado":200}}}),
        );
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Caso de prueba"));
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Regla de prueba"));
    assert!(
        see_validation::references::check(&specification)
            .iter()
            .all(|error| error != "SEE-REFERENCE: external documentation link forbidden")
    );
    Ok(())
}

#[test]
fn rejects_external_markdown_links_in_case_prose() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert(
            "texto".to_owned(),
            serde_json::json!("[manual](https://example.invalid/spec)"),
        );
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Regla de prueba"));
    assert!(
        see_validation::references::check(&specification)
            .iter()
            .any(|error| error == "SEE-REFERENCE: external documentation link forbidden")
    );
    Ok(())
}
