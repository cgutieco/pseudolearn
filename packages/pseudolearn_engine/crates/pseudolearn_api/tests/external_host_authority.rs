use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir root Como RedCap <- Propagar SolicitarRed();\nDefinir bounded Como RedCap <- Propagar root.Limitar(\"https://allowed.test\");\nDefinir response Como RespuestaHttp <- Propagar bounded.Enviar(PeticionHttp(MetodoHttp.GET, \"http://127.0.0.1:9/\"));\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn value(response: Value) -> Result<Value, String> {
    response
        .get("value")
        .cloned()
        .ok_or_else(|| response.to_string())
}

#[test]
fn voluntary_network_rejection_never_reaches_the_external_transport() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = value(session.call("create_analysis", &json!({"program":PROGRAM})))?;
    let started = value(session.call(
        "start",
        &json!({"analysis":analysis.get("resource"),
        "host":{"detached":true},"observe":"events"}),
    ))?;
    let resource = started.get("resource").ok_or("missing execution")?;
    let mut operations = Vec::new();
    for _attempt in 0..50 {
        let batch =
            value(session.call("advance", &json!({"resource":resource,"batch_size":1000})))?;
        if batch.pointer("/termination/kind").and_then(Value::as_str) == Some("completed") {
            assert_eq!(batch.get("output"), Some(&json!("destino_denegado\n")));
            assert_eq!(operations, ["request_network", "network_restrict"]);
            return Ok(());
        }
        let effect = batch
            .get("pending_effect")
            .ok_or_else(|| batch.to_string())?;
        let operation = effect
            .get("operation")
            .and_then(Value::as_str)
            .ok_or("missing operation")?;
        assert_ne!(operation, "network_send");
        operations.push(operation.to_owned());
        let capability = effect
            .get("result_capability")
            .ok_or("missing capability")?;
        value(session.call(
            "effect_result",
            &json!({"resource":resource,
            "effect_seq":effect.get("effect_seq"),"result":{"outcome":"committed",
                "value":{"kind":"capability","value":capability}}}),
        ))?;
    }
    Err("external execution did not terminate".to_owned())
}
