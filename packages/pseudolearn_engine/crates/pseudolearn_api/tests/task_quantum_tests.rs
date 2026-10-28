use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

#[test]
fn cpu_bound_tasks_yield_before_their_loops_complete() {
    let program = "SubProceso Suspendible Work(marker Como Entero)\nEscribir marker;\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 5000 Hacer\ncounter <- counter + 1;\nFinMientras\nEscribir marker + 10;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nLanzar Work(2);\nFinTareas\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "1\n2\n11\n12\n");
}

#[test]
fn exact_quantum_preserves_fifo_turns() {
    let program = "SubProceso Suspendible Work(marker Como Entero)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 1024 Hacer\nEscribir marker;\ncounter <- counter + 1;\nFinMientras\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nLanzar Work(2);\nFinTareas\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    let expected =
        "1\n".repeat(511) + &"2\n".repeat(511) + &"1\n".repeat(512) + &"2\n".repeat(512) + "1\n2\n";
    assert_eq!(response.output, expected);
}
