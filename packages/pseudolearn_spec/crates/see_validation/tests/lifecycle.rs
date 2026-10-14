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
fn enforces_transitions_classification_and_tombstones() -> Result<(), String> {
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
    let mut specification = support::specification()?;
    let lock = see_change::locking::generate(&vec![specification.clone()], &Lock::default())?;
    specification.metadata.version = "0.2.0".to_owned();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error.starts_with("SEE-CLASSIFICATION"))
    );
    specification.blocks.pop();
    assert!(
        see_validation::lifecycle::check(&specification, &lock)
            .iter()
            .any(|error| error.starts_with("SEE-IDENTITY"))
    );
    Ok(())
}
