use pseudolearn_api::{ApiSession, ExecuteRequest, execute_program};
use serde_json::{Value, json};

const PRODUCER_CONSUMER: &str = "SubProceso Suspendible Consume(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Consume(stream);\nAguardar stream.Enviar(7);\nFinTareas\nFinAlgoritmo\n";

fn observed(program: &str) -> Vec<Value> {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "spanish_events".to_owned(),
        strictness: "strict".to_owned(),
        observe: "events".to_owned(),
        ..Default::default()
    })
    .events
}

fn task_classes(events: &[Value]) -> Vec<String> {
    events
        .iter()
        .filter_map(|event| event.get("class").and_then(Value::as_str))
        .filter(|class| {
            class.starts_with("task_")
                || class.starts_with("channel_")
                || class.starts_with("scope_")
                || *class == "effect_delivered"
        })
        .map(str::to_owned)
        .collect()
}

#[test]
fn producer_consumer_emits_the_expected_task_story() {
    let classes = task_classes(&observed(PRODUCER_CONSUMER));
    assert_eq!(
        classes,
        [
            "channel_created",
            "task_spawned",
            "task_ready",
            "channel_sent",
            "task_suspended",
            "task_resumed",
            "channel_received",
            "task_completed",
            "task_ready",
            "task_resumed",
            "scope_joined"
        ]
    );
}

#[test]
fn task_event_payloads_carry_identities_and_causes() {
    let events = observed(PRODUCER_CONSUMER);
    let find = |class: &str| {
        events
            .iter()
            .find(|event| event.get("class") == Some(&json!(class)))
    };
    assert_eq!(
        find("task_spawned").and_then(|event| event.get("data")),
        Some(&json!({"task": 1, "parent": 0, "scope": 0}))
    );
    assert_eq!(
        find("task_suspended").and_then(|event| event.get("data")),
        Some(&json!({"task": 0, "cause": "join", "target": 0}))
    );
    assert_eq!(
        find("channel_received").and_then(|event| event.get("data")),
        Some(&json!({"channel": 1, "present": true}))
    );
    assert_eq!(
        find("task_completed").and_then(|event| event.get("data")),
        Some(&json!({"task": 1, "outcome": "success"}))
    );
}

#[test]
fn programs_without_tasks_emit_no_task_events() {
    let events = observed("Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n");
    assert!(task_classes(&events).is_empty());
}

#[test]
fn sibling_failure_reports_the_cancellation_with_its_origin() {
    let program = "SubProceso Suspendible Idle(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\nLanzar Idle(stream);\nLanzar Fail();\nFinTareas\nDescartar problem;\nFinAlgoritmo\n";
    let events = observed(program);
    let cancel = events
        .iter()
        .find(|event| event.get("class") == Some(&json!("task_cancel_requested")));
    assert_eq!(
        cancel.and_then(|event| event.get("data")),
        Some(&json!({"task": 1, "reason": "sibling_failure", "origin": 2}))
    );
    let outcomes: Vec<&str> = events
        .iter()
        .filter(|event| event.get("class") == Some(&json!("task_completed")))
        .filter_map(|event| event.pointer("/data/outcome").and_then(Value::as_str))
        .collect();
    assert_eq!(outcomes, ["error", "cancelled"]);
}

#[test]
fn event_batches_with_task_classes_round_trip_through_both_encodings() {
    let events = observed(PRODUCER_CONSUMER);
    let mut session = ApiSession::default();
    for encoding in ["json", "binary"] {
        let encoded = session.call(
            "encode_events",
            &json!({"events": events, "encoding": encoding}),
        );
        let value = encoded.get("value").cloned().unwrap_or(Value::Null);
        let decoded = session.call(
            "decode_events",
            &json!({"encoded": value, "encoding": encoding}),
        );
        let restored = decoded
            .get("value")
            .and_then(Value::as_array)
            .map(|list| task_classes(list));
        assert_eq!(
            restored,
            Some(task_classes(&events)),
            "{encoding}: {decoded}"
        );
    }
}

#[test]
fn a_malformed_task_payload_is_rejected() {
    let mut session = ApiSession::default();
    let bad = json!([{"class": "task_spawned", "line": 1, "depth": 1, "data": {"task": "one"}}]);
    let response = session.call("encode_events", &json!({"events": bad, "encoding": "json"}));
    assert!(response.get("failure").is_some(), "{response}");
}

fn state_after(program: &str, class: &str, occurrence: usize) -> Value {
    let events = observed(program);
    let position = events
        .iter()
        .enumerate()
        .filter(|(_, event)| event.get("class") == Some(&json!(class)))
        .nth(occurrence)
        .map(|(position, _)| position)
        .unwrap_or(0);
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "spanish_events".to_owned(),
        strictness: "strict".to_owned(),
        observe: "events".to_owned(),
        state_at: Some(position),
        ..Default::default()
    });
    response.state_at.unwrap_or(Value::Null)
}

#[test]
fn state_lists_every_task_with_parent_state_cause_and_target() {
    let state = state_after(PRODUCER_CONSUMER, "task_suspended", 0);
    let summaries = state
        .pointer("/tareas")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    assert_eq!(summaries.len(), 2, "{state}");
    assert_eq!(
        summaries.first(),
        Some(
            &json!({"tarea": 0, "padre": null, "estado": "waiting", "causa": "join", "objetivo": 0})
        )
    );
    assert_eq!(
        summaries.get(1).and_then(|summary| summary.get("estado")),
        Some(&json!("running"))
    );
}

#[test]
fn state_without_child_tasks_omits_the_task_summary() {
    let state = state_after(
        "Algoritmo Main\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
        "output",
        0,
    );
    assert!(state.get("marcos").is_some(), "{state}");
    assert!(state.get("tareas").is_none(), "{state}");
}

fn compact(events: &[Value]) -> Vec<Value> {
    events
        .iter()
        .map(|event| json!({"clase": event["class"], "linea": event["line"], "datos": event.get("data")}))
        .collect()
}

fn observed_in(program: &str, profile: &str) -> Vec<Value> {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: profile.to_owned(),
        strictness: "strict".to_owned(),
        observe: "events".to_owned(),
        ..Default::default()
    })
    .events
}

#[test]
fn english_and_spanish_profiles_observe_identical_task_events() {
    let pairs = [
        (
            PRODUCER_CONSUMER,
            "subroutine suspendable Consume(stream as channel<integer>)\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Consume(stream);\nawait stream.send(7);\nendTasks\nendAlgorithm\n",
        ),
        (
            "SubProceso Suspendible Idle(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\nLanzar Idle(stream);\nLanzar Fail();\nFinTareas\nDescartar problem;\nFinAlgoritmo\n",
            "subroutine suspendable Idle(stream as channel<integer>)\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks problem\nspawn Idle(stream);\nspawn Fail();\nendTasks\ndiscard problem;\nendAlgorithm\n",
        ),
    ];
    for (spanish, english) in pairs {
        let spanish_events = compact(&observed_in(spanish, "spanish_events"));
        assert!(!spanish_events.is_empty());
        assert_eq!(spanish_events, compact(&observed_in(english, "en")));
    }
}
