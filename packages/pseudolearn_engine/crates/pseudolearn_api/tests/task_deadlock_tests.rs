use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

#[test]
fn pending_effect_keeps_blocked_channel_receivers_awaiting_the_host() {
    let response = execute_program(&ExecuteRequest {
        program: "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nTareas\nLanzar Wait();\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinTareas\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(), strictness: "strict".to_owned(),
        host: Some(json!({"permissions": ["temporizador"], "requested_permissions": ["temporizador"], "detached": true})),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("awaiting_effect")),
        "{response:?}"
    );
}

#[test]
fn deadlock_reports_wait_locations_in_task_order() {
    let response = execute_program(&ExecuteRequest {
        program: "SubProceso Suspendible Wait(queue Como Canal<Entero>)\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nTareas\nLanzar Wait(queue);\nFinTareas\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(), strictness: "strict".to_owned(), ..Default::default()
    });
    assert_eq!(
        response.termination.get("code"),
        Some(&json!("taskDeadlock")),
        "{response:?}"
    );
    let diagnostic = response
        .diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == "taskDeadlock");
    assert!(
        diagnostic.is_some_and(|diagnostic| diagnostic.related.len() == 2),
        "{response:?}"
    );
}

#[test]
fn an_abandoned_effect_does_not_keep_a_later_channel_wait_pending() {
    let response = execute_program(&ExecuteRequest {
        program: "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(3);\nTareas failureReport\nLanzar Wait();\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(), strictness: "strict".to_owned(),
        host: Some(json!({"permissions": ["temporizador"], "requested_permissions": ["temporizador"], "detached": true})),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("code"),
        Some(&json!("taskDeadlock")),
        "{response:?}"
    );
}
