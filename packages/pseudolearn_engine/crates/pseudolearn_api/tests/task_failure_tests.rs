use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

fn execute(program: &str) -> pseudolearn_api::ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    })
}

#[test]
fn scope_failure_cancels_an_unstarted_sibling_and_exposes_the_first_error() {
    let response = execute(
        "SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nSubProceso Suspendible Unstarted()\nEscribir \"unexpected\";\nFinSubProceso\nAlgoritmo Main\nTareas failure\nLanzar Fail();\nLanzar Unstarted();\nFinTareas\nSegun failure Hacer\nNada: Escribir 0;\nAlgo(problem): Escribir problem.Primero, problem.Canceladas;\nFinSegun\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "problem1\n");
}

#[test]
fn successful_fallible_task_returns_payload_and_scope_binding_is_absent() {
    let response = execute(
        "SubProceso Suspendible Answer() Como Resultado<Entero, Cadena>\nRetornar Exito(81);\nFinSubProceso\nAlgoritmo Main\nTareas failure\nDefinir child Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar child;\nFinTareas\nSegun failure Hacer\nNada: Escribir 82;\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "81\n82\n");
}

#[test]
fn later_identity_failure_cancels_a_channel_wait_and_unwinds_body_cleanups() {
    let response = execute(
        "SubProceso Suspendible Wait(queue Como Canal<Entero>) Como Entero\nDiferir\nEscribir \"child-cleanup\";\nFinDiferir\nSegun Aguardar queue.Recibir() Hacer\nAlgo(value): Retornar value;\nNada: Retornar 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"later\");\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nTareas failure\nDiferir\nEscribir \"body-cleanup\";\nFinDiferir\nDefinir waiting Como Tarea<Entero> <- Lanzar Wait(queue);\nLanzar Fail();\nEscribir Aguardar waiting;\nEscribir \"unexpected\";\nFinTareas\nSegun failure Hacer\nNada: Escribir 0;\nAlgo(problem): Escribir problem.Primero, problem.Canceladas;\nFinSegun\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "child-cleanup\nbody-cleanup\nlater1\n");
}

#[test]
fn cancelled_cleanup_can_call_a_subprogram_and_continue_its_remaining_statements() {
    let response = execute(
        "SubProceso PrintCleanup()\nEscribir \"called\";\nFinSubProceso\nSubProceso Suspendible Wait(queue Como Canal<Entero>)\nDiferir\nPrintCleanup();\nEscribir \"continued\";\nFinDiferir\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nTareas failureReport\nLanzar Wait(queue);\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "called\ncontinued\n");
}

#[test]
fn an_outer_scope_failure_unwinds_an_inner_scope_without_leaving_live_children() {
    let response = execute(
        "SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nSubProceso Suspendible Wait(queue Como Canal<Entero>)\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nTareas failureReport\nLanzar Fail();\nTareas\nLanzar Wait(queue);\nFinTareas\nEscribir \"unexpected\";\nFinTareas\nSegun failureReport Hacer\nNada: Escribir 0;\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "problem\n");
}

#[test]
fn a_child_trap_ends_all_tasks_without_running_pending_cleanups() {
    let response = execute(
        "SubProceso Suspendible Crash()\nDiferir\nEscribir \"unexpected\";\nFinDiferir\nDefinir Mutable denominator Como Entero <- 1;\ndenominator <- denominator - 1;\nEscribir 1 div denominator;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Crash();\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("failed")),
        "{response:?}"
    );
    assert_eq!(
        response.termination.get("code"),
        Some(&json!("divisionByZero"))
    );
    assert!(response.output.is_empty());
}

#[test]
fn composite_success_payload_can_be_awaited_more_than_once() {
    let response = execute(
        "Registro Pair\nDefinir number Como Entero;\nDefinir name Como Cadena;\nFinRegistro\nSubProceso Suspendible Build() Como Resultado<Pair, Cadena>\nRetornar Exito(Pair(9, \"message\"));\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nDefinir child Como Tarea<Pair> <- Lanzar Build();\nDefinir first Como Pair <- Aguardar child;\nDefinir second Como Pair <- Aguardar child;\nEscribir first.number, first.name;\nEscribir second.number, second.name;\nFinTareas\nDescartar failureReport;\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "9message\n9message\n");
}

#[test]
fn english_profile_exposes_failure_fields_with_english_names() {
    let response = execute_program(&ExecuteRequest {
        program: "subroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm Main\ntasks report\nspawn Fail();\nendTasks\nswitch report do\nnone: write 0;\nsome(problem): write problem.first, problem.cancelled;\nendSwitch\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(), strictness: "strict".to_owned(), ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "problem0\n");
}
