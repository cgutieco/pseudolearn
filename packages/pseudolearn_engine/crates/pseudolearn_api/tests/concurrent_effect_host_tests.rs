use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const CONCURRENT_HTTP: &str = "SubProceso Suspendible Fetch(label Como Entero, net Como RedCap, url Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir label;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(1, net, \"https://fake.test/one\");\nLanzar Fetch(2, net, \"https://fake.test/two\");\nFinTareas\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

struct Execution {
    session: ApiSession,
    resource: Value,
}

fn start() -> Result<Execution, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CONCURRENT_HTTP}));
    let started = session.call(
        "start",
        &json!({
            "analysis":analysis.pointer("/value/resource"),
            "program":CONCURRENT_HTTP,
            "host":{"permissions":["red"],"requested_permissions":["red"],"detached":true,
                "http":{"GET https://fake.test/one":{"estado":200},
                    "GET https://fake.test/two":{"estado":200}}}
        }),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    Ok(Execution { session, resource })
}

fn advance(execution: &mut Execution) -> Value {
    execution.session.call(
        "advance",
        &json!({"resource":execution.resource,"batch_size":1000}),
    )
}

fn deliver(execution: &mut Execution, effect: &Value) -> Value {
    let sequence = effect.get("effect_seq").cloned().unwrap_or(Value::Null);
    let url = effect
        .pointer("/arguments/0/value/url")
        .and_then(Value::as_str)
        .unwrap_or("");
    execution.session.call(
        "effect_result",
        &json!({
            "resource":execution.resource,
            "effect_seq":sequence,
            "result":{"outcome":"committed","value":{"kind":"http_response","value":{
                "status":200,"headers":[],"body":[],"final_url":url
            }}}
        }),
    )
}

fn grant_network(execution: &mut Execution) -> Result<(), String> {
    let request = advance(execution);
    let effect = request
        .pointer("/value/pending_effect")
        .ok_or_else(|| format!("missing network grant request: {request}"))?;
    let sequence = effect
        .get("effect_seq")
        .cloned()
        .ok_or_else(|| format!("missing grant sequence: {request}"))?;
    let capability = effect
        .get("result_capability")
        .cloned()
        .ok_or_else(|| format!("missing network capability: {request}"))?;
    let result = execution.session.call(
        "effect_result",
        &json!({
            "resource":execution.resource,
            "effect_seq":sequence,
            "result":{"outcome":"committed","value":{"kind":"capability","value":capability}}
        }),
    );
    if result.get("value").is_none() {
        return Err(format!("network grant was rejected: {result}"));
    }
    Ok(())
}

#[test]
fn accepts_and_records_concurrent_effect_results_in_completion_order() -> Result<(), String> {
    let mut execution = start()?;
    grant_network(&mut execution)?;
    let awaiting = advance(&mut execution);
    let effects = awaiting
        .pointer("/value/pending_effects")
        .and_then(Value::as_array)
        .ok_or_else(|| format!("missing effects: {awaiting}"))?;
    assert_eq!(effects.len(), 2, "{awaiting}");
    let second = effects
        .iter()
        .find(|effect| {
            effect.pointer("/arguments/0/value/url") == Some(&json!("https://fake.test/two"))
        })
        .ok_or("missing second request")?;
    let first = effects
        .iter()
        .find(|effect| {
            effect.pointer("/arguments/0/value/url") == Some(&json!("https://fake.test/one"))
        })
        .ok_or("missing first request")?;
    assert!(deliver(&mut execution, second).get("value").is_some());
    assert!(deliver(&mut execution, first).get("value").is_some());

    let mut completed = Value::Null;
    for _ in 0..8 {
        completed = advance(&mut execution);
        if completed.pointer("/value/termination/kind") == Some(&json!("completed")) {
            break;
        }
    }
    assert_eq!(
        completed.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{completed}"
    );
    assert_eq!(completed.pointer("/value/output"), Some(&json!("2\n1\n")));
    let network_entries: Vec<&Value> = completed
        .pointer("/value/effect_tape/entries")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|entry| entry.get("operation") == Some(&json!("network_send")))
        .collect();
    let delivered_effects: Vec<u64> = network_entries
        .iter()
        .filter_map(|entry| entry.get("effect_seq").and_then(Value::as_u64))
        .collect();
    let delivery_order: Vec<u64> = network_entries
        .iter()
        .filter_map(|entry| entry.get("delivery_seq").and_then(Value::as_u64))
        .collect();
    assert_eq!(delivered_effects, [3, 2]);
    assert_eq!(delivery_order, [2, 3]);
    Ok(())
}
