mod support;
use see_model::{
    contract::Manifest,
    evidence::{Binding, Conformance, Evidence, Observation},
};
use serde_json::json;

fn conformance() -> Conformance {
    Conformance {
        estado: "activo".to_owned(),
        sujeto: "reference".to_owned(),
        paquete: "core".to_owned(),
        activadas: vec!["LANG.TEST.SAMPLE".to_owned()],
        fases_cerradas: vec![],
        vinculos: vec![Binding {
            regla: "LANG.TEST.SAMPLE@0.1.0#R1".to_owned(),
            verificacion: "ejecutor".to_owned(),
            estado: "cumple".to_owned(),
            resuelve_en: None,
            justificacion: None,
        }],
    }
}

#[test]
fn matrix_exposes_failure_and_requires_real_evidence() -> Result<(), String> {
    let corpus = vec![support::specification()?];
    let mut conformance = conformance();
    let mut evidence = evidence();
    assert!(
        !see_report::regressions(
            &see_report::matrix(&corpus, &conformance, &evidence),
            &conformance
        )
        .is_empty()
    );
    fail(&mut evidence);
    let rows = see_report::matrix(&corpus, &conformance, &evidence);
    assert_eq!(
        rows.first()
            .and_then(|row| row.get("measured"))
            .and_then(|value| value.as_str()),
        Some("incumple")
    );
    assert!(!see_report::regressions(&rows, &conformance).is_empty());
    conformance
        .vinculos
        .first_mut()
        .ok_or("Missing binding")?
        .estado = "exento".to_owned();
    assert!(
        see_report::regressions(
            &see_report::matrix(&corpus, &conformance, &evidence),
            &conformance
        )
        .is_empty()
    );
    Ok(())
}

#[test]
fn feature_aggregates_states_and_rejects_missing_contracts() -> Result<(), String> {
    let corpus = vec![support::specification()?];
    let mut manifest = Manifest {
        caracteristica: "pilot".to_owned(),
        titulo: "Piloto".to_owned(),
        estado_agregado: "generado".to_owned(),
        edicion: "2026".to_owned(),
        especificaciones: vec!["LANG.TEST.SAMPLE".to_owned()],
        criterio_de_terminado: vec![],
    };
    assert_eq!(
        see_report::feature(&corpus, &manifest)?
            .get("state")
            .and_then(|value| value.as_str()),
        Some("experimental")
    );
    manifest
        .especificaciones
        .push("LANG.TEST.MISSING".to_owned());
    assert!(see_report::feature(&corpus, &manifest).is_err());
    manifest.especificaciones.clear();
    assert!(see_report::feature(&corpus, &manifest).is_err());
    Ok(())
}

fn evidence() -> Evidence {
    Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject: "reference".to_owned(),
        subject_version: "0.1.0".to_owned(),
        properties: Vec::new(),
        corpus_hashes: Default::default(),
        observations: vec![],
        stderr: String::new(),
    }
}

fn fail(evidence: &mut Evidence) {
    evidence.observations.push(Observation {
        specification: "LANG.TEST.SAMPLE".to_owned(),
        rule: "R1".to_owned(),
        case: "C1".to_owned(),
        profile: "es".to_owned(),
        strictness: "flexible".to_owned(),
        verdict: "incumple".to_owned(),
        differences: vec!["Mismatch".to_owned()],
        expected: json!({}),
        actual: json!({}),
    });
}

#[test]
fn retired_matrix_preserves_historical_failure_without_a_live_regression() -> Result<(), String> {
    let corpus = vec![support::specification()?];
    let mut manifest = conformance();
    manifest.estado = "retirado".to_owned();
    let mut historical = evidence();
    fail(&mut historical);
    let before = serde_json::to_value(&historical).map_err(|error| error.to_string())?;
    let rows = see_report::matrix(&corpus, &manifest, &historical);
    assert!(
        rows.iter()
            .all(|row| row.get("measured") == Some(&json!("no aplicable")))
    );
    assert!(see_report::regressions(&rows, &manifest).is_empty());
    assert_eq!(
        before,
        serde_json::to_value(&historical).map_err(|error| error.to_string())?
    );
    Ok(())
}
