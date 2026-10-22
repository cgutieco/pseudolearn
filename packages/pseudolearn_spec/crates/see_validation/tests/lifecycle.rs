mod support;
use see_model::contract::Lock;

#[test]
fn stable_requires_independent_review_and_two_language_subjects() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.estado = "estable".to_owned();
    let errors = see_validation::lifecycle::check(&specification, &Lock::default());
    assert!(errors.iter().any(|error| error.contains("review")));
    assert!(errors.iter().any(|error| error.contains("two subjects")));
    specification
        .metadata
        .revisado_por
        .push("independent-reviewer".to_owned());
    specification.metadata.sujetos.push("engine".to_owned());
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

fn stable_specification() -> Result<see_model::Specification, String> {
    let mut specification = support::specification()?;
    specification.metadata.estado = "estable".to_owned();
    specification
        .metadata
        .revisado_por
        .push("independent-reviewer".to_owned());
    specification.metadata.sujetos.push("engine".to_owned());
    Ok(specification)
}

#[test]
fn permits_initial_baseline_and_freezes_later_version_changes() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = None;
    assert!(see_validation::lifecycle::check(&specification, &lock).is_empty());
    let baseline_lock = see_change::locking::generate(&vec![specification.clone()], &lock)?;
    specification.metadata.version = "1.0.1".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &baseline_lock)
            .iter()
            .any(|error| error == "SEE-VERSION: version is frozen")
    );
    Ok(())
}

#[test]
fn frozen_version_accepts_official_text_edits() -> Result<(), String> {
    let mut specification = stable_specification()?;
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
fn frozen_version_requires_tombstones_for_removed_elements() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.blocks.pop();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error.starts_with("SEE-IDENTITY"))
    );
    Ok(())
}

fn experimental_lock_for(specification: &mut see_model::Specification) -> Result<Lock, String> {
    let reviewers = std::mem::take(&mut specification.metadata.revisado_por);
    specification.metadata.estado = "experimental".to_owned();
    specification.metadata.version = "0.2.0".to_owned();
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.revisado_por = reviewers;
    Ok(lock)
}

#[test]
fn permits_promotion_from_experimental_to_stable_baseline() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = experimental_lock_for(&mut specification)?;
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = None;
    assert!(see_validation::lifecycle::check(&specification, &lock).is_empty());
    Ok(())
}

#[test]
fn rejects_promotion_to_a_version_other_than_the_baseline() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = experimental_lock_for(&mut specification)?;
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.version = "1.1.0".to_owned();
    specification.metadata.cambio = None;
    let errors = see_validation::lifecycle::check(&specification, &lock);
    assert!(
        errors
            .iter()
            .any(|error| error == "SEE-STATE: lifecycle state is frozen")
    );
    assert!(
        errors
            .iter()
            .any(|error| error == "SEE-VERSION: version is frozen")
    );
    Ok(())
}

#[test]
fn rejects_experimental_state_change_other_than_stable_baseline() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = experimental_lock_for(&mut specification)?;
    specification.metadata.estado = "obsoleta".to_owned();
    let errors = see_validation::lifecycle::check(&specification, &lock);
    assert!(
        errors
            .iter()
            .any(|error| error == "SEE-STATE: lifecycle state is frozen")
    );
    Ok(())
}

#[test]
fn permits_advancing_draft_toward_experimental_without_version_change() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.estado = "borrador".to_owned();
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.estado = "propuesta".to_owned();
    assert!(see_validation::lifecycle::check(&specification, &lock).is_empty());
    Ok(())
}

#[test]
fn rejects_advancing_draft_straight_to_experimental_or_changing_its_version() -> Result<(), String>
{
    let mut specification = support::specification()?;
    specification.metadata.estado = "borrador".to_owned();
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.estado = "experimental".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-STATE: invalid lifecycle transition")
    );
    specification.metadata.estado = "propuesta".to_owned();
    specification.metadata.version = "0.9.0".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-VERSION: version is frozen")
    );
    Ok(())
}

#[test]
fn permits_experimental_contract_above_baseline_to_reach_stable_baseline() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let lock = experimental_lock_for(&mut specification)?;
    let mut anchored = lock.clone();
    anchored
        .specifications
        .values_mut()
        .for_each(|anchor| anchor.version = "2.0.0".to_owned());
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = None;
    assert!(see_validation::lifecycle::check(&specification, &anchored).is_empty());
    Ok(())
}

#[test]
fn rejects_lowering_the_version_of_an_already_stable_contract() -> Result<(), String> {
    let mut specification = stable_specification()?;
    let mut lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    lock.specifications
        .values_mut()
        .for_each(|anchor| anchor.version = "2.0.0".to_owned());
    specification.metadata.version = "1.0.0".to_owned();
    specification.metadata.cambio = None;
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error == "SEE-VERSION: version is frozen")
    );
    Ok(())
}
