use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn historical_collection_state_contains_ordered_contents() -> Result<(), String> {
    let program = "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nvalues[0] <- 9;\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let analysis = session
        .call("create_analysis", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let execution = session
        .call("start", &json!({"analysis":analysis}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing execution")?;
    let result = session.call("advance", &json!({"resource":execution,"batch_size":4096}));
    assert_eq!(
        result.pointer("/value/termination/kind"),
        Some(&json!("completed"))
    );
    let horizon = session.call("horizon", &json!({"resource":execution}));
    let last = horizon
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or("missing horizon")?;
    let mut observed = false;
    for event in 0..=last {
        let state = session.call("query_state", &json!({"resource":execution,"event":event}));
        if state.pointer("/value/objetos").is_some_and(|objects| {
            objects.as_object().is_some_and(|map| {
                map.values().any(|object| {
                    object.pointer("/vector/elementos") == Some(&json!([{"valor":"9"}]))
                        && object.pointer("/vector/longitud") == Some(&json!(1))
                })
            })
        }) {
            observed = true;
        }
    }
    assert!(observed);
    Ok(())
}
