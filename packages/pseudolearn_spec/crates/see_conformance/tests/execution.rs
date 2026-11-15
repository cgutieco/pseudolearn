mod adapter;
mod support;
use see_conformance::protocol::Session;
use std::time::Duration;

#[test]
fn executes_bilingual_cases_and_marks_unsupported_operations_inapplicable() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("programas".to_owned(), serde_json::json!({"es":"","en":""}));
    for (mode, expected) in [("normal", "cumple"), ("unsupported", "no aplicable")] {
        let mut session = Session::start(&mut adapter.command(mode), Duration::from_secs(2))?;
        let evidence = see_conformance::execution::execute(
            &vec![specification.clone()],
            &Default::default(),
            &mut session,
            None,
        )?;
        assert_eq!(evidence.observations.len(), 2);
        assert!(
            evidence
                .observations
                .iter()
                .all(|observation| observation.verdict == expected)
        );
        assert!(evidence.stderr.contains("fixture stderr"));
    }
    Ok(())
}

#[test]
fn forwards_explicit_seed_and_preserves_default_seed() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    for (seed, output) in [(None, "42\n"), (Some(7), "7\n")] {
        let mut specification = support::specification()?;
        let case = specification.blocks.last_mut().ok_or("Missing case")?;
        case.fields
            .insert("programas".to_owned(), serde_json::json!({"es":"","en":""}));
        case.fields
            .insert("espera".to_owned(), serde_json::json!({"salida":output}));
        if let Some(seed) = seed {
            case.fields
                .insert("semilla".to_owned(), serde_json::json!(seed));
        }
        let mut session = Session::start(&mut adapter.command("seed"), Duration::from_secs(2))?;
        let evidence = see_conformance::execution::execute(
            &vec![specification],
            &Default::default(),
            &mut session,
            None,
        )?;
        assert!(
            evidence
                .observations
                .iter()
                .all(|observation| observation.verdict == "cumple")
        );
    }
    Ok(())
}

fn case_with(fields: serde_json::Value) -> Result<see_model::Specification, String> {
    let mut specification = support::specification()?;
    let case = specification.blocks.last_mut().ok_or("Missing case")?;
    for (name, value) in fields.as_object().ok_or("Invalid fields")? {
        case.fields.insert(name.clone(), value.clone());
    }
    Ok(specification)
}

fn verdicts(mode: &str, specification: see_model::Specification) -> Result<Vec<String>, String> {
    let adapter = adapter::Adapter::create()?;
    let mut session = Session::start(&mut adapter.command(mode), Duration::from_secs(2))?;
    let evidence = see_conformance::execution::execute(
        &vec![specification],
        &Default::default(),
        &mut session,
        None,
    )?;
    Ok(evidence
        .observations
        .into_iter()
        .map(|observation| observation.verdict)
        .collect())
}

#[test]
fn compares_trace_cases_only_with_the_observe_capability() -> Result<(), String> {
    let traced = serde_json::json!({
        "programas": {"es": "", "en": ""},
        "operacion": "trace",
        "espera": {"eventos": [{"clase": "output", "linea": 2, "datos": {"texto": "1\n"}}], "terminacion": "limit_reached", "limite": "sentencias", "estado_en": {"evento": 1, "estado": {"marcos": []}}}
    });
    assert!(
        verdicts("observe", case_with(traced.clone())?)?
            .iter()
            .all(|verdict| verdict == "cumple")
    );
    assert!(
        verdicts("normal", case_with(traced)?)?
            .iter()
            .all(|verdict| verdict == "pendiente")
    );
    Ok(())
}

#[test]
fn rejects_events_from_a_subject_that_did_not_announce_observation() -> Result<(), String> {
    let specification = case_with(serde_json::json!({"programas": {"es": "", "en": ""}}))?;
    let result = verdicts("silent-events", specification);
    assert!(result.is_err_and(|error| error.contains("observe capability")));
    Ok(())
}

#[test]
fn compares_intermediate_representation_and_command_line_cases() -> Result<(), String> {
    let cases = [
        (
            serde_json::json!({"operacion": "ir", "programa_ri": "module {}\n", "espera": {"ri": {"aceptada": false, "regla": "IR.WELL-FORMEDNESS#R2"}}}),
            "cumple",
        ),
        (
            serde_json::json!({"operacion": "ir", "programa_ri": "module {}\n", "espera": {"ri": {"reimpresion": "other\n"}}}),
            "incumple",
        ),
        (
            serde_json::json!({"operacion": "cli", "cli": {"argumentos": ["comprobar"]}, "espera": {"codigo_salida": 2, "salida_error": "uso\n"}}),
            "cumple",
        ),
        (
            serde_json::json!({"operacion": "cli", "cli": {"argumentos": []}, "espera": {"codigo_salida": 0}}),
            "incumple",
        ),
    ];
    for (fields, expected) in cases {
        assert!(
            verdicts("observe", case_with(fields.clone())?)?
                .iter()
                .all(|verdict| verdict == expected),
            "{fields}"
        );
        assert!(
            verdicts("normal", case_with(fields)?)?
                .iter()
                .all(|verdict| verdict == "no aplicable")
        );
    }
    Ok(())
}
