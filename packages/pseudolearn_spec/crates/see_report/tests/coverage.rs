mod support;
use see_model::{
    Block,
    evidence::{Conformance, Evidence, Observation},
};
use serde_json::json;

fn coverage_block(fields: serde_json::Value) -> Result<Block, String> {
    Ok(Block {
        kind: "cobertura".to_owned(),
        fields: serde_json::from_value(fields).map_err(|error| error.to_string())?,
    })
}

#[test]
fn publishes_rule_to_instruction_rows_and_states_by_domain() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.blocks.push(coverage_block(
        json!({"id":"V1","regla":"LANG.TEST.SAMPLE#R1","instrucciones":["int.add"]}),
    )?);
    specification.blocks.push(coverage_block(
        json!({"id":"V2","regla":"LANG.TEST.SAMPLE#R2","sin_ri":"Solo análisis."}),
    )?);
    let corpus = vec![specification];
    let table = see_report::coverage::table(&corpus);
    assert_eq!(table.len(), 2);
    assert_eq!(
        table.first().and_then(|row| row.get("instructions")),
        Some(&json!(["int.add"]))
    );
    assert_eq!(
        table.get(1).and_then(|row| row.get("without_ir")),
        Some(&json!("Solo análisis."))
    );
    let states = see_report::coverage::states(&corpus);
    assert_eq!(
        states
            .get("LANG")
            .and_then(|states| states.get("experimental")),
        Some(&1)
    );
    Ok(())
}

#[test]
fn publishes_empty_tables_for_an_empty_corpus_and_reports_pending_rules() -> Result<(), String> {
    assert!(see_report::coverage::table(&vec![]).is_empty());
    assert!(see_report::coverage::states(&vec![]).is_empty());
    let corpus = vec![support::specification()?];
    let conformance = Conformance {
        sujeto: "reference".to_owned(),
        paquete: "core".to_owned(),
        activadas: vec![],
        fases_cerradas: vec![],
        vinculos: vec![],
    };
    let mut observation = Observation {
        specification: "LANG.TEST.SAMPLE".to_owned(),
        rule: "R1".to_owned(),
        case: "C1".to_owned(),
        profile: "es".to_owned(),
        strictness: "flexible".to_owned(),
        verdict: "pendiente".to_owned(),
        differences: vec![],
        expected: json!({}),
        actual: json!(null),
    };
    let mut evidence = Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject: "reference".to_owned(),
        subject_version: "0.1.0".to_owned(),
        properties: Vec::new(),
        corpus_hashes: Default::default(),
        observations: vec![observation.clone()],
        stderr: String::new(),
    };
    let measured = |evidence: &Evidence| {
        see_report::matrix(&corpus, &conformance, evidence)
            .first()
            .and_then(|row| row.get("measured").cloned())
    };
    assert_eq!(measured(&evidence), Some(json!("pendiente")));
    observation.verdict = "incumple".to_owned();
    evidence.observations.push(observation);
    assert_eq!(measured(&evidence), Some(json!("incumple")));
    Ok(())
}

#[test]
fn reports_rules_verified_only_by_measurements_as_not_applicable() -> Result<(), String> {
    let mut specification = support::specification()?;
    let rule = specification.blocks.first_mut().ok_or("Missing rule")?;
    rule.fields.insert("verificacion".to_owned(), json!(["M1"]));
    specification.blocks.push(Block {
        kind: "medicion".to_owned(),
        fields: serde_json::from_value(json!({"id":"M1","suite":"PERF.SUITE.AWFY-CORE","protocolo":"PERF.PROTOCOL#R1","provisional":true}))
            .map_err(|error| error.to_string())?,
    });
    let conformance = Conformance {
        sujeto: "reference".to_owned(),
        paquete: "core".to_owned(),
        activadas: vec![],
        fases_cerradas: vec![],
        vinculos: vec![],
    };
    let evidence = Evidence {
        protocol: "see-protocol/1".to_owned(),
        subject: "reference".to_owned(),
        subject_version: "0.1.0".to_owned(),
        properties: Vec::new(),
        corpus_hashes: Default::default(),
        observations: vec![],
        stderr: String::new(),
    };
    let rows = see_report::matrix(&vec![specification], &conformance, &evidence);
    let row = rows.first().ok_or("Missing row")?;
    assert_eq!(row.get("measured"), Some(&json!("no aplicable")));
    assert_eq!(
        row.pointer("/measurements/0/protocol"),
        Some(&json!("PERF.PROTOCOL#R1"))
    );
    let empty = see_report::matrix(&vec![support::specification()?], &conformance, &evidence);
    assert_eq!(
        empty.first().and_then(|row| row.get("measured")),
        Some(&json!("sin evidencia"))
    );
    Ok(())
}
