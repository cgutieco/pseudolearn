mod support;
use see_conformance::properties::{PropertyContext, PropertySubject, run};
use see_model::properties::{PropertyBinding, PropertyExecutor, PropertyRun};
use serde_json::{Value, json};

type Answer = fn(&Value) -> Value;

struct Scripted {
    hello: Value,
    answer: Answer,
}

impl PropertySubject for Scripted {
    fn declaration(&self) -> &Value {
        &self.hello
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        Ok((self.answer)(request))
    }
}

fn verdict(
    executor: PropertyExecutor,
    capabilities: Value,
    answer: Answer,
) -> Result<PropertyRun, String> {
    let corpus = vec![support::specification()?];
    let vocabulary = Default::default();
    let context = PropertyContext {
        corpus: &corpus,
        vocabulary: &vocabulary,
        subject: "service",
        first_sample: 0,
        exhaustive: false,
    };
    let mut subject = Scripted {
        hello: json!({ "capabilities": capabilities }),
        answer,
    };
    let binding = PropertyBinding {
        reference: "TEST.MODEL@0.1.0#P1".to_owned(),
        executor,
        seed: 42,
        samples: 1,
    };
    run(&binding, &context, &mut subject)
}

fn service(outcome: Value) -> Value {
    json!({ "kind": "service", "service": outcome })
}

fn echo_format(request: &Value) -> Value {
    match request.get("kind").and_then(Value::as_str) {
        Some("analyze") => json!({ "diagnostics": [] }),
        _ => service(
            json!({ "formateado": request.get("documento").cloned().unwrap_or(Value::Null) }),
        ),
    }
}

fn growing_format(request: &Value) -> Value {
    let text = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    service(json!({ "formateado": format!("{text}!") }))
}

fn diagnostics_diverge(request: &Value) -> Value {
    match request.get("kind").and_then(Value::as_str) {
        Some("analyze") => {
            let program = request.get("program").and_then(Value::as_str).unwrap_or("");
            json!({ "diagnostics": if program.contains("Escribir") { vec![json!({"code":"x","severity":"error"})] } else { vec![] } })
        }
        _ => service(json!({ "formateado": "Algoritmo A\nFinAlgoritmo\n" })),
    }
}

#[test]
fn format_property_accepts_stable_output_and_rejects_drift() -> Result<(), String> {
    let service_capability = json!(["service"]);
    let good = verdict(
        PropertyExecutor::ServiceFormat,
        service_capability.clone(),
        echo_format,
    )?;
    assert_eq!(good.verdict, "cumple");
    let drifting = verdict(
        PropertyExecutor::ServiceFormat,
        service_capability.clone(),
        growing_format,
    )?;
    assert_eq!(drifting.verdict, "incumple");
    let changed = verdict(
        PropertyExecutor::ServiceFormat,
        service_capability,
        diagnostics_diverge,
    )?;
    assert_eq!(changed.verdict, "incumple");
    Ok(())
}

fn faithful_translation(request: &Value) -> Value {
    match request.get("suboperacion").and_then(Value::as_str) {
        Some("translate_roundtrip") => {
            let text = request.get("documento").cloned().unwrap_or(Value::Null);
            service(json!({ "traducido": text.clone(), "vuelta": text }))
        }
        _ => echo_format(request),
    }
}

fn lossy_translation(request: &Value) -> Value {
    match request.get("suboperacion").and_then(Value::as_str) {
        Some("translate_roundtrip") => service(json!({ "traducido": "a", "vuelta": "b" })),
        _ => echo_format(request),
    }
}

fn colliding_translation(request: &Value) -> Value {
    match request.get("suboperacion").and_then(Value::as_str) {
        Some("translate_roundtrip") => service(json!({ "colision": "reservedLexemeUsedAsName" })),
        _ => echo_format(request),
    }
}

#[test]
fn translation_property_requires_identity_and_skips_collisions() -> Result<(), String> {
    let capabilities = json!(["service"]);
    let scenarios: [(Answer, &str); 3] = [
        (faithful_translation, "cumple"),
        (lossy_translation, "incumple"),
        (colliding_translation, "cumple"),
    ];
    for (answer, expected) in scenarios {
        let report = verdict(
            PropertyExecutor::ServiceTranslate,
            capabilities.clone(),
            answer,
        )?;
        assert_eq!(report.verdict, expected);
    }
    Ok(())
}

fn probe_ok(_: &Value) -> Value {
    service(json!({ "coincide_con_frio": true, "conservados": true }))
}

fn probe_broken(_: &Value) -> Value {
    service(json!({ "coincide_con_frio": false, "conservados": false }))
}

fn probe_not_applicable(_: &Value) -> Value {
    service(json!({ "aplicable": false }))
}

#[test]
fn incremental_and_identity_properties_follow_the_probe_answer() -> Result<(), String> {
    let capabilities = json!(["service"]);
    for executor in [
        PropertyExecutor::ServiceIncremental,
        PropertyExecutor::ServiceNodeIdentity,
    ] {
        assert_eq!(
            verdict(executor, capabilities.clone(), probe_ok)?.verdict,
            "cumple"
        );
        assert_eq!(
            verdict(executor, capabilities.clone(), probe_broken)?.verdict,
            "incumple"
        );
    }
    let skipped = verdict(
        PropertyExecutor::ServiceNodeIdentity,
        capabilities,
        probe_not_applicable,
    )?;
    assert_eq!(skipped.verdict, "cumple");
    Ok(())
}

fn templates_valid(_: &Value) -> Value {
    service(json!({ "valida": true }))
}

fn templates_invalid(_: &Value) -> Value {
    service(json!({ "valida": false }))
}

#[test]
fn template_property_fails_on_a_single_invalid_template() -> Result<(), String> {
    let capabilities = json!(["service"]);
    let good = verdict(
        PropertyExecutor::ServiceCompletionTemplates,
        capabilities.clone(),
        templates_valid,
    )?;
    assert_eq!(good.verdict, "cumple");
    let bad = verdict(
        PropertyExecutor::ServiceCompletionTemplates,
        capabilities,
        templates_invalid,
    )?;
    assert_eq!(bad.verdict, "incumple");
    Ok(())
}

#[test]
fn service_properties_stay_pending_without_the_service_capability() -> Result<(), String> {
    for executor in [
        PropertyExecutor::ServiceFormat,
        PropertyExecutor::ServiceTranslate,
        PropertyExecutor::ServiceIncremental,
        PropertyExecutor::ServiceNodeIdentity,
        PropertyExecutor::ServiceCompletionTemplates,
    ] {
        let report = verdict(executor, json!(["api", "execute"]), probe_ok)?;
        assert_eq!(report.verdict, "pendiente");
    }
    Ok(())
}

#[test]
fn syntax_properties_run_on_service_subjects_through_the_shared_probe() -> Result<(), String> {
    let report = verdict(
        PropertyExecutor::LosslessReprint,
        json!(["service"]),
        |request| match request.get("kind").and_then(Value::as_str) {
            Some("probe") => {
                json!({ "reprint": request.get("program").cloned().unwrap_or(Value::Null) })
            }
            _ => json!({}),
        },
    )?;
    assert_eq!(report.verdict, "cumple");
    Ok(())
}
