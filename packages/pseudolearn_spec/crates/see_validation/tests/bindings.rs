mod support;
use see_model::evidence::{Binding, Conformance};

#[test]
fn exemptions_need_reason_and_pending_needs_open_phase() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.estado = "experimental".to_owned();
    let corpus = vec![specification];
    let mut conformance = Conformance {
        estado: "activo".to_owned(),
        sujeto: "reference".to_owned(),
        paquete: "core".to_owned(),
        activadas: vec![],
        fases_cerradas: vec!["R1".to_owned()],
        vinculos: vec![Binding {
            regla: "LANG.TEST.SAMPLE@1.0.0#R1".to_owned(),
            verificacion: "ejecutor".to_owned(),
            estado: "exento".to_owned(),
            resuelve_en: None,
            justificacion: None,
        }],
    };
    assert!(!see_validation::bindings::check(&corpus, &conformance).is_empty());
    let binding = conformance.vinculos.first_mut().ok_or("Missing binding")?;
    binding.justificacion = Some("Sujeto congelado".to_owned());
    assert!(see_validation::bindings::check(&corpus, &conformance).is_empty());
    let binding = conformance.vinculos.first_mut().ok_or("Missing binding")?;
    binding.estado = "pendiente".to_owned();
    binding.resuelve_en = Some("R1".to_owned());
    assert!(!see_validation::bindings::check(&corpus, &conformance).is_empty());
    conformance
        .vinculos
        .first_mut()
        .ok_or("Missing binding")?
        .resuelve_en = Some("R4".to_owned());
    assert!(see_validation::bindings::check(&corpus, &conformance).is_empty());
    Ok(())
}

#[test]
fn subject_state_defaults_to_active_and_rejects_unknown_states() -> Result<(), String> {
    let source = r#"{"sujeto":"archived","paquete":"historical","activadas":[],"fases_cerradas":[],"vinculos":[]}"#;
    let mut manifest: Conformance =
        serde_json::from_str(source).map_err(|error| error.to_string())?;
    assert_eq!(manifest.estado, "activo");
    manifest.estado = "retirado".to_owned();
    assert!(see_validation::bindings::check(&Vec::new(), &manifest).is_empty());
    manifest.estado = "unknown".to_owned();
    assert!(!see_validation::bindings::check(&Vec::new(), &manifest).is_empty());
    Ok(())
}

#[test]
fn retired_subject_cannot_count_towards_language_stability() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.estado = "estable".to_owned();
    specification.metadata.sujetos = vec!["engine".to_owned(), "reference".to_owned()];
    let corpus = vec![specification];
    assert!(
        !see_validation::lifecycle::active_subjects(&corpus, &["engine".to_owned()]).is_empty()
    );
    assert!(
        see_validation::lifecycle::active_subjects(
            &corpus,
            &["engine".to_owned(), "reference".to_owned()]
        )
        .is_empty()
    );
    Ok(())
}
