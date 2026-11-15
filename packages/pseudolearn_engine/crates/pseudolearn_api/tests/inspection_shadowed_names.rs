use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "Algoritmo P\nDefinir numeros Como Vector<Entero> <- Vector();\nnumeros.Agregar(4);\nDefinir textos Como Vector<Cadena> <- Vector();\ntextos.Agregar(\"hola\");\nPara Cada v En numeros Hacer\nEscribir v;\nFinPara\nPara Cada v En textos Hacer\nEscribir v;\nFinPara\nFinAlgoritmo\n";

fn started(session: &mut ApiSession) -> Result<(u64, Vec<Value>), String> {
    let created = session.call(
        "create_analysis",
        &json!({"program":PROGRAM,"profile":"es"}),
    );
    let analysis = created
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| created.to_string())?;
    let started = session.call("start", &json!({"resource":analysis,"observe":"events"}));
    let resource = started
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| started.to_string())?;
    let advanced = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    let events = advanced
        .pointer("/value/events")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| advanced.to_string())?;
    Ok((resource, events))
}

fn statement_at(events: &[Value], line: u64) -> Option<usize> {
    events.iter().position(|event| {
        event.get("class") == Some(&json!("statement_entered"))
            && event.get("line").and_then(Value::as_u64) == Some(line)
    })
}

fn inspect(session: &mut ApiSession, resource: u64, event: usize, expression: &str) -> Value {
    session.call(
        "inspect_expression",
        &json!({"resource":resource,"event":event,"frame":0,"expression":expression}),
    )
}

#[test]
fn a_reused_name_takes_the_type_of_the_binding_in_scope() -> Result<(), String> {
    let mut session = ApiSession::default();
    let (resource, events) = started(&mut session)?;
    let first = statement_at(&events, 7).ok_or("missing first loop body")?;
    let second = statement_at(&events, 10).ok_or("missing second loop body")?;
    let number = inspect(&mut session, resource, first, "v");
    assert_eq!(
        number.pointer("/value/type"),
        Some(&json!("integer")),
        "{number}"
    );
    assert_eq!(
        number.pointer("/value/value"),
        Some(&json!("4")),
        "{number}"
    );
    let text = inspect(&mut session, resource, second, "v");
    assert_eq!(
        text.pointer("/value/type"),
        Some(&json!("string")),
        "{text}"
    );
    assert_eq!(text.pointer("/value/value"), Some(&json!("hola")), "{text}");
    Ok(())
}

#[test]
fn a_reused_name_rejects_operators_of_the_other_binding() -> Result<(), String> {
    let mut session = ApiSession::default();
    let (resource, events) = started(&mut session)?;
    let second = statement_at(&events, 10).ok_or("missing second loop body")?;
    let result = inspect(&mut session, resource, second, "v * 2");
    assert_eq!(
        result.pointer("/failure/family"),
        Some(&json!("usage")),
        "{result}"
    );
    Ok(())
}
