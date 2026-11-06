use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir values Como Argumentos <- Propagar SolicitarArgumentos();\nDefinir list Como Vector<Cadena> <- Propagar values.Valores();\nDefinir joined Como Cadena <- \"\";\nDefinir index Como Entero <- 0;\nMientras index < list.Longitud() Hacer\njoined <- joined + \"[\" + list[index] + \"]\";\nindex <- index + 1;\nFinMientras\nRetornar Exito(joined);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir list_size(value);\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn run(arguments: Value) -> Value {
    let program = PROGRAM.replace("Escribir list_size(value);", "Escribir value;");
    ApiSession::default().call(
        "record",
        &json!({"request": {"program": program, "profile": "es",
            "host": {"args": arguments}},
            "options": {"capture_states": false, "batch_size": 1000}}),
    )
}

fn output(response: &Value) -> Option<&str> {
    response.pointer("/value/output").and_then(Value::as_str)
}

#[test]
fn no_arguments_yield_an_empty_list() {
    let response = run(json!([]));
    assert_eq!(output(&response), Some("\n"), "{response}");
}

#[test]
fn one_argument_is_delivered_verbatim() {
    let response = run(json!(["hola"]));
    assert_eq!(output(&response), Some("[hola]\n"), "{response}");
}

#[test]
fn several_arguments_keep_order_spaces_unicode_and_empty_values() {
    let response = run(json!(["uno dos", "ñandú ✓", "", "último"]));
    assert_eq!(
        output(&response),
        Some("[uno dos][ñandú ✓][][último]\n"),
        "{response}"
    );
}

#[test]
fn a_non_text_argument_is_rejected_as_a_usage_error() {
    let response = run(json!([1]));
    assert!(response.get("failure").is_some(), "{response}");
}
