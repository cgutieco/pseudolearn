mod support;
use see_model::contract::Lock;

#[test]
fn stable_requires_independent_review_and_two_language_subjects() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.revisado_por.clear();
    specification.metadata.sujetos.truncate(1);
    let errors = see_validation::lifecycle::check(&specification, &Lock::default());
    assert!(errors.iter().any(|error| error.contains("review")));
    assert!(errors.iter().any(|error| error.contains("two subjects")));
    specification
        .metadata
        .revisado_por
        .push("independent-reviewer".to_owned());
    specification.metadata.sujetos.push("aot".to_owned());
    assert!(see_validation::lifecycle::check(&specification, &Lock::default()).is_empty());
    Ok(())
}

#[test]
fn lifecycle_transitions_are_ordered() {
    assert!(see_validation::lifecycle::transition(
        "borrador",
        "propuesta"
    ));
    assert!(!see_validation::lifecycle::transition(
        "borrador", "estable"
    ));
    assert!(!see_validation::lifecycle::transition(
        "retirada",
        "propuesta"
    ));
}

#[test]
fn new_specifications_start_at_the_stable_baseline_without_change() -> Result<(), String> {
    let specification = support::specification()?;
    assert!(see_validation::lifecycle::check(&specification, &Lock::default()).is_empty());
    let mut specification = specification;
    specification.metadata.estado = "borrador".to_owned();
    expect_lifecycle_error(
        &specification,
        "SEE-STATE: new specification must start stable",
    )?;
    specification.metadata.estado = "experimental".to_owned();
    expect_lifecycle_error(
        &specification,
        "SEE-STATE: new specification must start stable",
    )?;
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.version = "0.9.0".to_owned();
    expect_lifecycle_error(
        &specification,
        "SEE-VERSION: new specification must start at 1.0.0",
    )?;
    specification.metadata.version = "1.1.0".to_owned();
    expect_lifecycle_error(
        &specification,
        "SEE-VERSION: new specification must start at 1.0.0",
    )?;
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = Some(see_model::Change {
        clase: "editorial".to_owned(),
        impacto_usuarios: "ninguno".to_owned(),
        impacto_implementaciones: "ninguno".to_owned(),
        justificacion: "No permitido durante el congelamiento".to_owned(),
        revisado_por: "independent-reviewer".to_owned(),
    });
    expect_lifecycle_error(
        &specification,
        "SEE-CLASSIFICATION: change field is forbidden while versioning is frozen",
    )?;
    Ok(())
}

fn expect_lifecycle_error(
    specification: &see_model::Specification,
    expected: &str,
) -> Result<(), String> {
    let errors = see_validation::lifecycle::check(specification, &Lock::default());
    assert!(errors.iter().any(|error| error == expected), "{errors:?}");
    Ok(())
}

#[test]
fn frozen_contracts_allow_official_text_edits_at_the_same_anchor() -> Result<(), String> {
    let mut specification = support::specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification
        .blocks
        .first_mut()
        .ok_or("Missing rule")?
        .fields
        .insert(
            "texto".to_owned(),
            serde_json::json!("Contrato oficial editado"),
        );
    assert!(see_validation::lifecycle::check(&specification, &lock).is_empty());
    Ok(())
}

#[test]
fn frozen_contracts_reject_state_version_and_change_updates() -> Result<(), String> {
    let mut specification = support::specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.estado = "obsoleta".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-STATE: lifecycle state is frozen")
    );
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.version = "1.0.1".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-VERSION: version is frozen")
    );
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = Some(see_model::Change {
        clase: "editorial".to_owned(),
        impacto_usuarios: "ninguno".to_owned(),
        impacto_implementaciones: "ninguno".to_owned(),
        justificacion: "No permitido durante el congelamiento".to_owned(),
        revisado_por: "independent-reviewer".to_owned(),
    });
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error
                == "SEE-CLASSIFICATION: change field is forbidden while versioning is frozen")
    );
    Ok(())
}

#[test]
fn frozen_contracts_require_retired_identities_to_keep_their_tombstones() -> Result<(), String> {
    let mut specification = support::specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.blocks.pop();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error.starts_with("SEE-IDENTITY"))
    );
    Ok(())
}

#[test]
fn frozen_contracts_reject_transitions_from_terminal_states() -> Result<(), String> {
    let mut specification = support::specification()?;
    let mut lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    lock.specifications
        .values_mut()
        .for_each(|anchor| anchor.state = "retirada".to_owned());
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-STATE: invalid lifecycle transition")
    );
    specification.metadata.estado = "rechazada".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-STATE: lifecycle state is frozen")
    );
    Ok(())
}
