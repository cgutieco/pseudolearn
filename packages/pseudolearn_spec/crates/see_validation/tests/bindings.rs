mod support;
use see_model::evidence::{Binding, Conformance};

#[test]
fn exemptions_need_reason_and_pending_needs_open_phase() -> Result<(), String> {
    let corpus = vec![support::specification()?];
    let mut conformance = Conformance {
        sujeto: "reference".to_owned(),
        paquete: "core".to_owned(),
        activadas: vec![],
        fases_cerradas: vec!["R1".to_owned()],
        vinculos: vec![Binding {
            regla: "LANG.TEST.SAMPLE@0.1.0#R1".to_owned(),
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
