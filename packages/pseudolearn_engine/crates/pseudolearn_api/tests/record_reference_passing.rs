use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};
use serde_json::json;

const PLAYER: &str = "Registro Jugador\nDefinir puntos Como Entero;\nFinRegistro\nSubProceso GanarCopia(copia Como Jugador)\ncopia.puntos <- copia.puntos + 10;\nFinSubProceso\nSubProceso Ganar(jugador Como Jugador Por Referencia)\njugador.puntos <- jugador.puntos + 10;\nFinSubProceso\n";

fn run(body: &str) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: format!("{PLAYER}Algoritmo Partida\n{body}FinAlgoritmo\n"),
        profile: "es".to_owned(),
        ..Default::default()
    })
}

fn completed_output(body: &str) -> String {
    let response = run(body);
    assert!(
        response.diagnostics.is_empty(),
        "{:?}",
        response.diagnostics
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    response.output
}

#[test]
fn a_record_passed_by_value_and_then_by_reference_keeps_only_the_reference_change() {
    let output = completed_output(
        "Definir ana Como Jugador <- Jugador(0);\nGanarCopia(ana);\nEscribir ana.puntos;\nGanar(ana);\nEscribir ana.puntos;\n",
    );
    assert_eq!(output, "0\n10\n");
}

#[test]
fn a_record_passed_by_reference_and_then_by_value_copies_the_updated_fields() {
    let output = completed_output(
        "Definir ana Como Jugador <- Jugador(0);\nGanar(ana);\nGanarCopia(ana);\nEscribir ana.puntos;\n",
    );
    assert_eq!(output, "10\n");
}

#[test]
fn a_one_letter_record_passed_both_ways_inside_a_loop_accumulates_only_by_reference() {
    let output = completed_output(
        "Definir a Como Jugador <- Jugador(0);\nPara i <- 1 Hasta 3 Hacer\nGanarCopia(a);\nGanar(a);\nFinPara\nEscribir a.puntos;\n",
    );
    assert_eq!(output, "30\n");
}

#[test]
fn a_record_value_that_is_not_a_designator_is_still_rejected_with_its_diagnostic() {
    let response = run("Ganar(Jugador(0));\n");
    assert_eq!(
        response.termination,
        json!({"kind": "failed", "code": "analysisFailed"})
    );
    let codes: Vec<_> = response
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.as_str())
        .collect();
    assert_eq!(codes, ["byReferenceArgumentRequiresDesignator"]);
}
