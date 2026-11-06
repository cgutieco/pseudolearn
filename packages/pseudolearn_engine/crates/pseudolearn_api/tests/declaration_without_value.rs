use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

fn run(program: &str, state_at: Option<usize>) -> (String, Option<serde_json::Value>) {
    let request = ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        state_at,
        ..Default::default()
    };
    let response = execute_program(&request);
    assert!(
        response.diagnostics.is_empty(),
        "{:?}",
        response.diagnostics
    );
    (response.output, response.termination.get("kind").cloned())
}

#[test]
fn a_local_without_value_assigned_in_both_branches_runs_on_both_paths() {
    let program = "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Verdadero;\nSi c Entonces\nx <- 1;\nSiNo\nx <- 2;\nFinSi\nEscribir x;\nc <- Falso;\nDefinir y2 Como Entero;\nSi c Entonces\ny2 <- 3;\nSiNo\ny2 <- 4;\nFinSi\nEscribir y2;\nFinAlgoritmo\n";
    for state_at in [None, Some(0)] {
        let (output, kind) = run(program, state_at);
        assert_eq!(output, "1\n4\n");
        assert_eq!(kind, Some(json!("completed")));
    }
}

#[test]
fn an_output_parameter_fills_a_local_that_is_passed_by_reference() {
    let program = "SubProceso Fijar(n Como Entero Por Referencia)\nn <- 7;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Entero;\nFijar(a);\nEscribir a + 1;\nFinAlgoritmo\n";
    assert_eq!(run(program, None).0, "8\n");
}

#[test]
fn a_two_step_dimension_and_a_return_variable_execute() {
    let program = "Funcion r <- Suma(v Como Real, w Como Real)\nDefinir r Como Real;\nr <- v + w;\nFinFuncion\nAlgoritmo P\nDefinir notas Como Real;\nDimension notas[2];\nnotas[0] <- 1.5;\nnotas[1] <- 2;\nEscribir Suma(notas[0], notas[1]);\nFinAlgoritmo\n";
    assert_eq!(run(program, None).0, "3.5\n");
}
