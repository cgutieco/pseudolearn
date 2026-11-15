use pseudolearn_api::{ExecuteRequest, ExecutionLimits, execute_program};
use serde_json::json;

fn terminate(program: &str, statements: u64) -> (String, serde_json::Value) {
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        limits: ExecutionLimits {
            statements: Some(statements),
            ..ExecutionLimits::default()
        },
        ..ExecuteRequest::default()
    });
    (response.output, response.termination)
}

fn reaches_statement_limit(program: &str, statements: u64) -> bool {
    let (_, termination) = terminate(program, statements);
    termination.get("kind") == Some(&json!("limit_reached"))
        && termination.get("limit") == Some(&json!("statements"))
}

#[test]
fn every_kind_of_empty_loop_exhausts_the_statement_budget() {
    for body in [
        "Mientras Verdadero Hacer\nFinMientras\n",
        "Repetir\nHasta Que Falso\n",
        "Para i <- 1 Hasta 1000000000 Hacer\nFinPara\n",
    ] {
        let program = format!("Algoritmo P\n{body}FinAlgoritmo\n");
        assert!(reaches_statement_limit(&program, 100), "{program}");
    }
}

#[test]
fn each_iteration_of_an_empty_for_each_counts_as_a_statement() {
    let program = "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(4);\nvalues.Agregar(7);\nPara Cada value En values Hacer\nFinPara\nFinAlgoritmo\n";
    assert!(reaches_statement_limit(program, 5));
    let (_, termination) = terminate(program, 6);
    assert_eq!(termination.get("kind"), Some(&json!("completed")));
}

#[test]
fn an_empty_loop_that_never_iterates_stays_within_the_budget() {
    let (_, termination) = terminate(
        "Algoritmo P\nMientras Falso Hacer\nFinMientras\nFinAlgoritmo\n",
        10,
    );
    assert_eq!(termination.get("kind"), Some(&json!("completed")));
}

#[test]
fn a_budget_of_one_step_stops_an_infinite_empty_loop() {
    assert!(reaches_statement_limit(
        "Algoritmo P\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n",
        1
    ));
}

#[test]
fn a_loop_with_a_body_counts_only_its_own_statements() {
    let (output, termination) = terminate(
        "Algoritmo P\nPara i <- 1 Hasta 2 Hacer\nEscribir i;\nFinPara\nFinAlgoritmo\n",
        3,
    );
    assert_eq!(output, "1\n2\n");
    assert_eq!(termination.get("kind"), Some(&json!("completed")));
}
