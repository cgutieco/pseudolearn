mod support;
use see_model::contract::Lock;

#[test]
fn anchor_preserves_history_and_reanchors_frozen_edits_explicitly() -> Result<(), String> {
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
    assert!(see_change::locking::check(&vec![modified.clone()], &lock)?.is_empty());
    assert!(see_change::locking::generate(&vec![modified.clone()], &lock).is_err());
    let refreshed = see_change::locking::refresh(
        &vec![modified.clone()],
        &lock,
        &[modified.metadata.id.clone()],
    )?;
    assert!(see_change::locking::check(&vec![modified.clone()], &refreshed)?.is_empty());
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
fn removed_candidate_identity_is_allowed_but_stable_identity_requires_tombstone()
-> Result<(), String> {
    let mut candidate = support::specification()?;
    candidate.metadata.estado = "experimental".to_owned();
    let candidate_lock = see_change::locking::generate(&vec![candidate], &Lock::default())?;
    assert!(see_change::locking::check(&vec![], &candidate_lock)?.is_empty());
    let mut stable = support::specification()?;
    stable.metadata.estado = "estable".to_owned();
    let stable_lock = see_change::locking::generate(&vec![stable], &Lock::default())?;
    assert!(
        see_change::locking::check(&vec![], &stable_lock)?
            .iter()
            .any(|error| error.starts_with("SEE-IDENTITY"))
    );
    Ok(())
}

#[test]
fn refresh_requires_explicit_identity_and_rejects_terminal_contracts() -> Result<(), String> {
    let original = support::specification()?;
    let lock = see_change::locking::generate(&vec![original.clone()], &Lock::default())?;
    let mut modified = original;
    modified
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert("texto".to_owned(), serde_json::json!("Contrato corregido"));
    let authorized = vec![modified.metadata.id.clone()];
    let corpus = vec![modified.clone()];
    assert!(see_change::locking::refresh(&corpus, &lock, &[]).is_err());
    assert!(
        see_change::locking::refresh(&corpus, &lock, &["UNKNOWN.IDENTITY".to_owned()]).is_err()
    );
    let refreshed = see_change::locking::refresh(&corpus, &lock, &authorized)?;
    assert!(see_change::locking::check(&corpus, &refreshed)?.is_empty());
    modified.metadata.estado = "retirada".to_owned();
    assert!(see_change::locking::refresh(&vec![modified], &lock, &authorized).is_err());
    Ok(())
}
