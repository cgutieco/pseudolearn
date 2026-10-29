use pseudolearn_api::{ExecuteRequest, ExecutionLimits, execute_program};
use serde_json::json;

fn run(
    program: &str,
    limits: ExecutionLimits,
    host: serde_json::Value,
) -> pseudolearn_api::ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        limits,
        host: Some(host),
        ..Default::default()
    })
}

fn read_body_program(limit: i64) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConLimiteRespuesta({limit})) Hacer\nExito(response): Retornar Exito(response.Cuerpo().Longitud());\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn host(body: &str) -> serde_json::Value {
    json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": {"GET https://fake.test/a": {"estado": 200, "cuerpo": body}}
    })
}

fn concurrent_requests() -> String {
    "SubProceso Suspendible Fetch(net Como RedCap, url Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(net, \"https://fake.test/one\");\nLanzar Fetch(net, \"https://fake.test/two\");\nFinTareas\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n".to_owned()
}

#[test]
fn clips_response_limit_to_the_host_and_accepts_the_inclusive_boundary() {
    let response = run(
        &read_body_program(8),
        ExecutionLimits {
            max_http_body_bytes: Some(4),
            ..Default::default()
        },
        host("1234"),
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "4\n");
}

#[test]
fn converts_an_oversized_host_response_to_a_limit_error() {
    let response = run(
        &read_body_program(8),
        ExecutionLimits {
            max_http_body_bytes: Some(4),
            ..Default::default()
        },
        host("12345"),
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "limite_excedido\n");
}

#[test]
fn rejects_nonpositive_execution_limits_as_usage_errors() {
    let response = execute_program(&ExecuteRequest {
        program: "Algoritmo Main\nFinAlgoritmo\n".to_owned(),
        limits: ExecutionLimits {
            max_json_depth: Some(0),
            ..Default::default()
        },
        ..Default::default()
    });
    assert_eq!(response.termination.get("code"), Some(&json!("usage")));
    assert_eq!(response.output, "");
}

#[test]
fn rejects_only_requests_above_the_pending_limit_without_calling_the_host() {
    let response = execute_program(&ExecuteRequest {
        program: concurrent_requests(),
        limits: ExecutionLimits {
            max_pending_network: Some(1),
            ..Default::default()
        },
        host: Some(json!({
            "permissions": ["red"],
            "requested_permissions": ["red"],
            "http": {
                "GET https://fake.test/one": {"estado": 200},
                "GET https://fake.test/two": {"estado": 201}
            }
        })),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "200\nlimite_excedido\n");
    assert_eq!(
        response
            .host_observation
            .as_ref()
            .and_then(|value| value.get("calls")),
        Some(&json!(2))
    );
}
