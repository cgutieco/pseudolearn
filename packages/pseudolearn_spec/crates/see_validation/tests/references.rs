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
fn rejects_external_documentation_links_but_allows_internal_references() -> Result<(), String> {
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
