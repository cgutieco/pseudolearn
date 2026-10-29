use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

fn execute(program: &str) -> pseudolearn_api::ExecuteResponse {
    execute_with_gc(program, false)
}

fn execute_with_gc(program: &str, gc_stress: bool) -> pseudolearn_api::ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        gc_stress,
        ..Default::default()
    })
}

#[test]
fn joins_multiple_children_in_spawn_order() {
    let response = execute(
        "SubProceso Suspendible Print(value Como Entero)\nEscribir value;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Print(1);\nLanzar Print(2);\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "1\n2\n");
}

#[test]
fn awaits_a_completed_child_more_than_once() {
    let response = execute(
        "SubProceso Suspendible Answer() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar answer;\nEscribir Aguardar answer;\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "7\n7\n");
}

#[test]
fn joins_without_suspending_after_the_child_was_awaited() {
    let response = execute(
        "SubProceso Suspendible Answer() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar answer;\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "7\n");
}

#[test]
fn joins_nested_scopes_three_levels_deep() {
    let response = execute(
        "SubProceso Suspendible Leaf()\nEscribir \"leaf\";\nFinSubProceso\nSubProceso Suspendible Middle()\nTareas\nLanzar Leaf();\nFinTareas\nFinSubProceso\nSubProceso Suspendible Outer()\nTareas\nLanzar Middle();\nFinTareas\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Outer();\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "leaf\n");
}

#[test]
fn joins_an_empty_scope_without_suspending() {
    let response = execute("Algoritmo P\nTareas\nFinTareas\nEscribir 1;\nFinAlgoritmo\n");
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "1\n");
}

#[test]
fn keeps_suspended_task_references_alive_during_collection_in_another_task() {
    let response = execute_with_gc(
        "SubProceso Suspendible Allocate()\nDefinir value Como Cadena <- \"a\" + \"b\";\nEscribir value;\nFinSubProceso\nSubProceso Suspendible Preserve()\nDefinir kept Como Cadena <- \"re\" + \"tained\";\nTareas\nLanzar Allocate();\nFinTareas\nEscribir kept;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Preserve();\nFinTareas\nFinAlgoritmo\n",
        true,
    );
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
    assert_eq!(response.output, "ab\nretained\n");
}

#[test]
fn a_child_suspended_on_a_channel_runs_its_deferred_cleanups_when_a_sibling_fails() {
    let program = "SubProceso Suspendible Hold(stream Como Canal<Entero>)\nDiferir\nEscribir \"cleanup-first\";\nFinDiferir\nDiferir\nEscribir \"cleanup-second\";\nFinDiferir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir \"closed\";\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\nLanzar Hold(stream);\nLanzar Fail();\nFinTareas\nSegun problem Hacer\nNada: Escribir \"ok\";\nAlgo(report): Escribir report.Primero;\nFinSegun\nFinAlgoritmo\n";
    let response = pseudolearn_api::execute_program(&pseudolearn_api::ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.output, "cleanup-second\ncleanup-first\nfailed\n",
        "{response:?}"
    );
}
