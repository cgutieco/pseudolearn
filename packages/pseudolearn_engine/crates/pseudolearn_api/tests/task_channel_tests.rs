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
fn channels_transport_values_through_the_public_pipeline() {
    let response = execute(
        "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nDefinir accepted Como Logico <- Aguardar queue.Enviar(81);\nSi accepted Entonces\nSegun Aguardar queue.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSi\nqueue.Cerrar();\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "81\n");
}

#[test]
fn select_dispatches_closed_channels_in_textual_order() {
    let response = execute(
        "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nqueue.Cerrar();\nElegir\nRecibir first Desde queue:\nSegun first Hacer\nNada: Escribir 81;\nAlgo(value): Escribir value;\nFinSegun\nRecibir second Desde queue:\nSegun second Hacer\nNada: Escribir 82;\nAlgo(other): Escribir other;\nFinSegun\nFinElegir\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "81\n");
}

#[test]
fn a_root_waiting_without_senders_reports_task_deadlock() {
    let response = execute(
        "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("failed")),
        "{response:?}"
    );
    assert!(format!("{:?}", response.diagnostics).contains("taskDeadlock"));
}

#[test]
fn a_suspended_producer_resumes_after_a_consumer_releases_capacity() {
    let response = execute(
        "SubProceso Suspendible Produce(queue Como Canal<Entero>)\nDefinir first Como Logico <- Aguardar queue.Enviar(81);\nDefinir second Como Logico <- Aguardar queue.Enviar(82);\nSi first Y second Entonces\nqueue.Cerrar();\nFinSi\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Produce(queue);\nPara index <- 1 Hasta 2 Con Paso 1 Hacer\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinPara\nFinTareas\nFinAlgoritmo\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "81\n82\n");
}

#[test]
fn select_emits_one_decision_without_extra_binding_statements() {
    let response = execute_program(&ExecuteRequest {
        program: "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(3);\nqueue.Cerrar();\nElegir\nRecibir first Desde queue:\nRecibir second Desde queue:\nFinElegir\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(), strictness: "strict".to_owned(), observe: "events".to_owned(), ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    let decisions = response
        .events
        .iter()
        .filter(|event| event.get("class") == Some(&json!("decision")))
        .collect::<Vec<_>>();
    assert_eq!(decisions.len(), 1);
    assert_eq!(
        decisions
            .first()
            .and_then(|event| event.pointer("/data/indice")),
        Some(&json!(0)),
        "{decisions:?}"
    );
    assert_eq!(response.events.len(), 7, "{response:?}");
}
