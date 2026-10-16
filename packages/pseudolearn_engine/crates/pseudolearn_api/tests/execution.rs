use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

#[test]
fn cell_backed_accumulators_survive_loop_joins() {
    let program = "SubProceso Change(value Como Entero Por Referencia)\nvalue <- value + 7;\nFinSubProceso\nAlgoritmo Cells\nDefinir index, sum Como Entero;\nsum <- 0;\nPara index <- 1 Hasta 4 Con Paso 1 Hacer\nsum <- sum + index;\nFinPara\nChange(sum);\nEscribir sum;\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "17\n");
}
