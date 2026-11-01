use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "Algoritmo P\nDefinir Mutable amount Como Entero <- 7;\namount <- amount + 1;\nEscribir amount;\nEscribir amount * 2;\nFinAlgoritmo\n";

fn start(session: &mut ApiSession) -> Result<Value, String> {
    let analysis = session.call(
        "create_analysis",
        &json!({"program":PROGRAM,"profile":"es","strictness":"strict"}),
    );
    let started = session.call(
        "start",
        &json!({"resource":analysis.pointer("/value/resource"),"observe":"events","seed":42}),
    );
    started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))
}

fn finish(session: &mut ApiSession, resource: &Value) -> Value {
    session.call("advance", &json!({"resource":resource,"batch_size":1000}))
}

fn nested(depth: usize) -> String {
    format!("{}amount{}", "(".repeat(depth), ")".repeat(depth))
}

fn long_sum(terms: usize) -> String {
    vec!["amount"; terms].join(" + ")
}

#[test]
fn evaluating_accepted_rejected_and_exhausted_expressions_leaves_the_run_unchanged()
-> Result<(), String> {
    let mut control_session = ApiSession::default();
    let control = start(&mut control_session)?;
    control_session.call("advance", &json!({"resource":control,"batch_size":3}));
    let expected = finish(&mut control_session, &control);

    let mut session = ApiSession::default();
    let resource = start(&mut session)?;
    session.call("advance", &json!({"resource":resource,"batch_size":3}));
    let frame = json!({"resource":resource,"event":1,"frame":0});
    let before = session.call("query_frame", &frame);
    let expressions = [
        "amount * 6".to_owned(),
        "Azar(10)".to_owned(),
        "unknown".to_owned(),
        nested(4000),
        long_sum(1500),
    ];
    for expression in expressions {
        session.call(
            "inspect_expression",
            &json!({"resource":resource,"event":1,"frame":0,"expression":expression}),
        );
        assert_eq!(session.call("query_frame", &frame), before);
    }
    let actual = finish(&mut session, &resource);
    for field in ["output", "termination", "effect_tape", "host_observation"] {
        assert_eq!(
            actual.pointer(&format!("/value/{field}")),
            expected.pointer(&format!("/value/{field}")),
            "{field}"
        );
    }
    Ok(())
}

#[test]
fn exhausted_expressions_are_reported_as_failures() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = start(&mut session)?;
    session.call("advance", &json!({"resource":resource,"batch_size":3}));
    for expression in [nested(4000), long_sum(1500)] {
        let result = session.call(
            "inspect_expression",
            &json!({"resource":resource,"event":1,"frame":0,"expression":expression}),
        );
        assert!(result.get("failure").is_some(), "{result}");
    }
    Ok(())
}
