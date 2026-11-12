use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn program(code: i64) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir con Como Consola <- Propagar SolicitarConsola();\nDefinir n Como Entero <- Propagar con.EstablecerCodigoSalida({code});\nRetornar Exito(n);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn run(source: &str) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": {"program": source, "profile": "es", "host": {}},
            "options": {"capture_states": false, "batch_size": 1000}}),
    )
}

#[test]
fn the_established_code_is_reported_with_the_final_response() {
    let response = run(&program(7));
    assert_eq!(
        response.pointer("/value/output").and_then(Value::as_str),
        Some("7\n"),
        "{response}"
    );
    assert_eq!(
        response.pointer("/value/exit_code").and_then(Value::as_u64),
        Some(7),
        "{response}"
    );
}

#[test]
fn an_out_of_range_code_is_rejected_and_the_default_stays() {
    let response = run(&program(256));
    assert_eq!(
        response.pointer("/value/output").and_then(Value::as_str),
        Some("peticion_invalida\n"),
        "{response}"
    );
    assert_eq!(
        response.pointer("/value/exit_code").and_then(Value::as_u64),
        Some(0),
        "{response}"
    );
}

#[test]
fn error_text_is_merged_in_order_and_its_byte_range_is_reported() {
    let source = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir con Como Consola <- Propagar SolicitarConsola();\nEscribir \"a\";\nDefinir n Como Entero <- Propagar con.EscribirError(\"xy\\n\");\nEscribir \"b\";\nRetornar Exito(n);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";
    let response = run(source);
    assert_eq!(
        response.pointer("/value/output").and_then(Value::as_str),
        Some("a\nxy\nb\n3\n"),
        "{response}"
    );
    assert_eq!(
        response.pointer("/value/error_ranges"),
        Some(&json!([[2, 5]])),
        "{response}"
    );
}
