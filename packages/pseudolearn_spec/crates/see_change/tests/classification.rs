mod support;

#[test]
fn distinguishes_editorial_expected_values_forces_and_removal() -> Result<(), String> {
    let original = support::specification()?;
    let mut modified = original.clone();
    modified.metadata.titulo = "Otro título".to_owned();
    assert_eq!(
        see_change::classification::classify(&original, &modified)?,
        vec!["editorial"]
    );
    modified
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("espera".to_owned(), serde_json::json!({"salida":"2"}));
    assert!(
        see_change::classification::classify(&original, &modified)?
            .contains(&"cambio_significado_candidato".to_owned())
    );
    modified = original.clone();
    modified.blocks.pop();
    assert!(
        see_change::classification::classify(&original, &modified)?
            .contains(&"retirada".to_owned())
    );
    modified = original.clone();
    modified
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Texto nuevo"));
    assert!(
        see_change::classification::classify(&original, &modified)?
            .contains(&"requiere_revision".to_owned())
    );
    Ok(())
}
