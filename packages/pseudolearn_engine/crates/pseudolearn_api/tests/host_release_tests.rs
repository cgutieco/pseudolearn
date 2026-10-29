use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const OPEN_THEN_LOOP: &str = "SubProceso Probe(directory Como DirectorioCap) Como Resultado<Entero, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir Mutable n Como Entero <- 0;\nMientras Verdadero Hacer\nn <- n + 1;\nFinMientras\nRetornar Exito(n);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Probe(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const OPEN_THEN_TRAP: &str = "SubProceso Probe(directory Como DirectorioCap) Como Resultado<Entero, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir Mutable zero Como Entero <- 0;\nRetornar Exito(10 div zero);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Probe(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const OPEN_THEN_FINISH: &str = "Algoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Escribir \"abierto\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn run(program: &str, extra: Value) -> Value {
    let mut request = json!({
        "program": program,
        "profile": "es",
        "strictness": "strict",
        "host": {
            "permissions": ["archivos_lectura"],
            "requested_permissions": ["archivos_lectura"],
            "files": {"a": "hola"}
        }
    });
    if let (Some(target), Some(fields)) = (request.as_object_mut(), extra.as_object()) {
        target.extend(fields.clone());
    }
    ApiSession::default().call("record", &json!({"request": request}))
}

fn observed(response: &Value, pointer: &str) -> Option<Value> {
    response.pointer(pointer).cloned()
}

fn assert_released_and_sealed(response: &Value, kind: &str) {
    assert_eq!(
        observed(response, "/value/termination/kind"),
        Some(json!(kind)),
        "{response}"
    );
    assert_eq!(
        observed(response, "/value/host_observation/open_resources"),
        Some(json!(0)),
        "{response}"
    );
    assert_eq!(
        observed(response, "/value/host_observation/calls"),
        Some(json!(2)),
        "{response}"
    );
    assert_eq!(
        observed(response, "/value/effect_tape/status"),
        Some(json!("incomplete")),
        "{response}"
    );
}

#[test]
fn statement_limit_releases_the_open_capability_without_running_deferred_effects() {
    let response = run(OPEN_THEN_LOOP, json!({"limits": {"statements": 40}}));
    assert_released_and_sealed(&response, "limit_reached");
}

#[test]
fn host_cancellation_releases_the_open_capability_without_running_deferred_effects() {
    let response = run(OPEN_THEN_LOOP, json!({"cancel_at_statement": 40}));
    assert_released_and_sealed(&response, "cancelled");
}

#[test]
fn program_trap_releases_the_open_capability() {
    let response = run(OPEN_THEN_TRAP, json!({}));
    assert_eq!(
        observed(&response, "/value/termination/kind"),
        Some(json!("failed")),
        "{response}"
    );
    assert_eq!(
        observed(&response, "/value/host_observation/open_resources"),
        Some(json!(0)),
        "{response}"
    );
    assert_eq!(
        observed(&response, "/value/effect_tape/status"),
        Some(json!("incomplete")),
        "{response}"
    );
}

#[test]
fn completed_run_keeps_the_tape_reproducible_and_leaves_no_open_resource() {
    let response = run(OPEN_THEN_FINISH, json!({}));
    assert_eq!(
        observed(&response, "/value/termination/kind"),
        Some(json!("completed")),
        "{response}"
    );
    assert_eq!(
        observed(&response, "/value/host_observation/open_resources"),
        Some(json!(0)),
        "{response}"
    );
    assert_eq!(
        observed(&response, "/value/effect_tape/status"),
        Some(json!("reproducible")),
        "{response}"
    );
}
