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
