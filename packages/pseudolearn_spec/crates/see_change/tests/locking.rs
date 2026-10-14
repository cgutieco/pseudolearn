mod support;
use see_model::contract::Lock;

#[test]
fn anchor_preserves_history_and_detects_silent_mutations() -> Result<(), String> {
    let original = support::specification()?;
    let lock = see_change::locking::generate(&vec![original.clone()], &Lock::default())?;
    assert!(see_change::locking::check(&vec![original.clone()], &lock)?.is_empty());
    let mut modified = original;
    modified
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Otro contrato"));
    assert!(
        see_change::locking::check(&vec![modified.clone()], &lock)?
            .iter()
            .any(|error| error.starts_with("SEE-HASH"))
    );
    assert!(see_change::locking::generate(&vec![modified.clone()], &lock).is_err());
    modified.metadata.version = "0.2.0".to_owned();
    let next = see_change::locking::generate(&vec![modified], &lock)?;
    assert_eq!(next.history.len(), 2);
    assert_eq!(next.specifications.len(), 1);
    Ok(())
}

#[test]
fn hashes_normative_content_and_ignores_editorial_fields() -> Result<(), String> {
    let mut specification = support::specification()?;
    let original = see_change::hash(&specification)?;
    specification.metadata.titulo = "Otro título".to_owned();
    specification.metadata.resumen = "Otra motivación".to_owned();
    assert_eq!(original, see_change::hash(&specification)?);
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("espera".to_owned(), serde_json::json!({"salida":"2\n"}));
    assert_ne!(original, see_change::hash(&specification)?);
    Ok(())
}

#[test]
fn removed_active_identity_requires_tombstone() -> Result<(), String> {
    let specification = support::specification()?;
    let lock = see_change::locking::generate(&vec![specification], &Lock::default())?;
    assert!(
        see_change::locking::check(&vec![], &lock)?
            .iter()
            .any(|error| error.starts_with("SEE-IDENTITY"))
    );
    Ok(())
}
