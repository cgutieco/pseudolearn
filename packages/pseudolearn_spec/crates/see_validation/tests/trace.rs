mod contracts;
use serde_json::json;

fn alphabet() -> serde_json::Value {
    json!({"kind":"definicion","fields":{"id":"D1","termino":"traceEvents","texto":"Alfabeto.","valor":{"output":{"datos":["texto"]},"statement_entered":{"datos":[]}}}})
}

fn trace_case(events: serde_json::Value) -> serde_json::Value {
    json!({"kind":"caso","fields":{"id":"C1","regla":"R1","operacion":"trace","espera":{"eventos":events}}})
}

#[test]
fn accepts_known_classes_and_declared_payloads() -> Result<(), String> {
    let corpus = contracts::corpus(
        "ENG.TRACE.EVENTS",
        json!([
            alphabet(),
            trace_case(json!([{"clase":"output","linea":2,"datos":{"texto":"1\n"}}]))
        ]),
    )?;
    assert!(see_validation::trace::check(&corpus).is_empty());
    assert!(see_validation::trace::catalog(&json!({"output":{"datos":[]}})).is_ok());
    Ok(())
}

#[test]
fn rejects_unknown_classes_undeclared_payloads_and_missing_alphabet() -> Result<(), String> {
    let unknown = trace_case(json!([{"clase":"teleport","linea":1}]));
    let undeclared =
        trace_case(json!([{"clase":"statement_entered","linea":1,"datos":{"texto":""}}]));
    for (blocks, expected) in [
        (json!([alphabet(), unknown.clone()]), "SEE-TRACE-CLASS"),
        (json!([alphabet(), undeclared]), "SEE-TRACE-CLASS"),
        (json!([unknown]), "SEE-TRACE-CLASS"),
        (json!([alphabet(), trace_case(json!(null))]), "SEE-SCHEMA"),
    ] {
        let errors = see_validation::trace::check(&contracts::corpus("ENG.TRACE.EVENTS", blocks)?);
        assert!(
            errors.iter().any(|error| error.starts_with(expected)),
            "{errors:?}"
        );
    }
    for invalid in [
        json!({}),
        json!([]),
        json!({"output":{}}),
        json!({"output":{"datos":[""]}}),
    ] {
        assert!(see_validation::trace::catalog(&invalid).is_err());
    }
    Ok(())
}

#[test]
fn rejects_events_outside_trace_cases_and_unknown_instruction_observations() -> Result<(), String> {
    let execute = json!({"kind":"caso","fields":{"id":"C1","regla":"R1","operacion":"execute","espera":{"eventos":[]}}});
    let instruction = |observation: serde_json::Value| json!({"kind":"instruccion","fields":{"id":"O1","nombre":"out","observacion":observation}});
    let corpus = contracts::corpus(
        "ENG.TRACE.EVENTS",
        json!([
            alphabet(),
            execute,
            instruction(json!(["output", "teleport"]))
        ]),
    )?;
    assert_eq!(see_validation::trace::check(&corpus).len(), 2);
    for observation in [json!([]), json!(["output"])] {
        let corpus = contracts::corpus(
            "IR.INSTRUCTIONS",
            json!([alphabet(), instruction(observation)]),
        )?;
        assert!(see_validation::trace::check(&corpus).is_empty());
    }
    Ok(())
}
