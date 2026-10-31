use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn execution(session: &mut ApiSession) -> Result<u64, String> {
    let created = session.call("create_analysis", &json!({
        "program":"Algoritmo P\nDefinir Mutable amount Como Entero <- 7;\namount <- amount + 1;\nEscribir amount;\nFinAlgoritmo\n",
        "profile":"es","strictness":"strict"
    }));
    let analysis = created
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or("Missing analysis")?;
    let started = session.call("start", &json!({"resource":analysis,"observe":"events"}));
    let resource = started
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or("Missing execution")?;
    session.call("advance", &json!({"resource":resource,"batch_size":8}));
    Ok(resource)
}

#[test]
fn inspection_runs_shared_operators_without_advancing_the_live_execution() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(&mut session)?;
    let arguments = json!({"resource":resource,"event":2,"frame":0});
    let before = session.call("query_frame", &arguments);
    let result = session.call(
        "inspect_expression",
        &json!({"resource":resource,"event":2,"frame":0,"expression":"amount * 6"}),
    );
    assert_eq!(
        result.pointer("/value/value"),
        Some(&json!("42")),
        "{result}"
    );
    assert_eq!(result.pointer("/value/type"), Some(&json!("integer")));
    assert_eq!(session.call("query_frame", &arguments), before);
    Ok(())
}

#[test]
fn rejects_impure_invalid_and_oversized_inspection_without_mutation() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(&mut session)?;
    let arguments = json!({"resource":resource,"event":1,"frame":0});
    let before = session.call("query_frame", &arguments);
    for expression in ["Azar(10)", "amount <- 3", "1 / 0", "unknown", "", "1 2"] {
        let result = session.call(
            "inspect_expression",
            &json!({"resource":resource,"event":1,"frame":0,"expression":expression}),
        );
        assert_eq!(
            result.pointer("/failure/family"),
            Some(&json!("usage")),
            "{expression}: {result}"
        );
        assert_eq!(session.call("query_frame", &arguments), before);
    }
    let result = session.call(
        "inspect_expression",
        &json!({"resource":resource,"event":1,"frame":0,"expression":" ".repeat(8193)}),
    );
    assert!(result.get("failure").is_some());
    Ok(())
}

#[test]
fn preserves_integer_extremes_and_unicode_text() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(&mut session)?;
    for (expression, expected) in [
        ("9223372036854775807", "9223372036854775807"),
        ("\"é🧩\" + \"text\"", "é🧩text"),
    ] {
        let result = session.call(
            "inspect_expression",
            &json!({"resource":resource,"event":1,"frame":0,"expression":expression}),
        );
        assert_eq!(
            result.pointer("/value/value"),
            Some(&json!(expected)),
            "{result}"
        );
    }
    Ok(())
}

fn inspect_saved_program(program: &str, expression: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let created = session.call(
        "create_analysis",
        &json!({"program":program,"profile":"es","strictness":"strict"}),
    );
    let analysis = created
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or("Missing analysis")?;
    let started = session.call("start", &json!({"resource":analysis,"observe":"events"}));
    let resource = started
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("Missing execution: {started}"))?;
    let line = program
        .lines()
        .position(|line| line == "Escribir 0;")
        .and_then(|line| line.checked_add(1))
        .ok_or("Missing stop line")?;
    session.call("debug_configure", &json!({"resource":resource,"breakpoints":[{"source_id":0,"line":line}],"stop_on_entry":false}));
    session.call(
        "debug_control",
        &json!({"resource":resource,"command":"continue"}),
    );
    session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    let state = session.call("debug_state", &json!({"resource":resource}));
    let event = state
        .pointer("/value/event")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("Missing stop event: {state}"))?;
    Ok(session.call(
        "inspect_expression",
        &json!({"resource":resource,"event":event,"frame":0,"expression":expression}),
    ))
}

#[test]
fn inspects_record_results_and_collection_record_fields() -> Result<(), String> {
    let program = "Registro Pair\nDefinir left Como Entero;\nDefinir right Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir point Como Pair <- Pair(7, 9);\nDefinir values Como Vector<Pair> <- Vector();\nvalues.Agregar(point);\nEscribir 0;\nFinAlgoritmo\n";
    let result = inspect_saved_program(program, "point")?;
    assert_eq!(
        result.pointer("/value/type"),
        Some(&json!("record")),
        "{result}"
    );
    assert_eq!(
        result.pointer("/value/value"),
        Some(&json!("{\"left\":\"7\",\"right\":\"9\"}")),
        "{result}"
    );
    let result = inspect_saved_program(program, "values[0].right")?;
    assert_eq!(
        result.pointer("/value/value"),
        Some(&json!("9")),
        "{result}"
    );
    let result = inspect_saved_program(program, "values[1]")?;
    assert_eq!(result.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn preserves_references_for_array_and_object_results() -> Result<(), String> {
    let array = "Algoritmo P\nDimension values[2] Como Entero;\nvalues[0] <- 7;\nEscribir 0;\nFinAlgoritmo\n";
    let result = inspect_saved_program(array, "values")?;
    assert_eq!(
        result.pointer("/value/type"),
        Some(&json!("array")),
        "{result}"
    );
    assert_eq!(
        result.pointer("/value/reference"),
        Some(&json!(1)),
        "{result}"
    );
    let result = inspect_saved_program(array, "values[0]")?;
    assert_eq!(
        result.pointer("/value/value"),
        Some(&json!("7")),
        "{result}"
    );
    Ok(())
}
