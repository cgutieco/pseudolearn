use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const THREE_TIMERS: &str = "SubProceso Suspendible Pause(label Como Entero)\nDescartar Aguardar SolicitarTemporizador();\nEscribir label;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Pause(1);\nLanzar Pause(2);\nLanzar Pause(3);\nFinTareas\nFinAlgoritmo\n";

fn host(order: Value) -> Value {
    json!({"permissions": ["temporizador"], "requested_permissions": ["temporizador"], "orden_entrega": order})
}

fn record(request: Value) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": request, "options": {"capture_states": false, "batch_size": 1000}}),
    )
}

fn request(order: Value) -> Value {
    json!({"program": THREE_TIMERS, "profile": "es", "strictness": "strict", "host": host(order)})
}

fn replay(tape: &Value, mutate: impl FnOnce(&mut Value)) -> Value {
    let mut replay_request = request(json!([]));
    let fields = replay_request.as_object_mut();
    let Some(fields) = fields else {
        return Value::Null;
    };
    fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
    let mut tape = tape.clone();
    mutate(&mut tape);
    fields.insert("effect_tape".to_owned(), tape);
    record(replay_request)
}

#[test]
fn programs_without_concurrent_effects_record_no_delivery_sequence() {
    let recorded = record(json!({
        "program": "Algoritmo Main\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
        "profile": "es", "strictness": "strict"
    }));
    let entries = recorded
        .pointer("/value/effect_tape/entries")
        .and_then(Value::as_array);
    assert!(
        entries.is_some_and(|entries| !entries.is_empty()
            && entries
                .iter()
                .all(|entry| entry.get("delivery_seq").is_none()
                    && entry.get("task_id") == Some(&json!(0)))),
        "{}",
        recorded.get("value").map_or(String::new(), |value| value
            .to_string()
            .chars()
            .take(300)
            .collect())
    );
}

#[test]
fn in_order_delivery_of_concurrent_effects_prints_in_request_order() {
    let recorded = record(request(json!([])));
    assert_eq!(recorded.pointer("/value/output"), Some(&json!("1\n2\n3\n")));
    let tasks: Vec<_> = recorded
        .pointer("/value/effect_tape/entries")
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter_map(|entry| entry.get("task_id").and_then(Value::as_u64))
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(tasks, vec![1, 1, 2, 2, 3, 3]);
}

#[test]
fn reversed_delivery_records_delivery_sequence_and_replays_identically() {
    let recorded = record(request(json!([3, 2, 1])));
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("3\n2\n1\n")),
        "{recorded}"
    );
    let tape = recorded
        .pointer("/value/effect_tape")
        .cloned()
        .unwrap_or(Value::Null);
    let marked = tape
        .get("entries")
        .and_then(Value::as_array)
        .is_some_and(|entries| {
            entries
                .iter()
                .any(|entry| entry.get("delivery_seq").is_some())
        });
    assert!(marked, "{tape}");
    let replayed = replay(&tape, |_| {});
    assert_eq!(
        replayed.pointer("/value/output"),
        Some(&json!("3\n2\n1\n")),
        "{replayed}"
    );
    assert_eq!(
        replayed.pointer("/value/host_observation/calls"),
        Some(&json!(0)),
        "{replayed}"
    );
}

#[test]
fn replay_with_an_altered_delivery_order_is_rejected() {
    let recorded = record(request(json!([3, 2, 1])));
    let tape = recorded
        .pointer("/value/effect_tape")
        .cloned()
        .unwrap_or(Value::Null);
    let altered = replay(&tape, |tape| {
        if let Some(entries) = tape.get_mut("entries").and_then(Value::as_array_mut) {
            entries.reverse();
        }
    });
    assert!(
        altered.get("value").is_none()
            || altered.pointer("/value/termination/kind") != Some(&json!("completed")),
        "{altered}"
    );
}

const ABANDONED: &str = "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nLanzar Wait();\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nEscribir \"done\";\nFinAlgoritmo\n";

#[test]
fn a_cancelled_task_leaves_an_abandoned_entry_that_replays() {
    let base = json!({"program": ABANDONED, "profile": "es", "strictness": "strict", "host": host(json!([]))});
    let recorded = record(base.clone());
    assert_eq!(recorded.pointer("/value/output"), Some(&json!("done\n")));
    let tape = recorded
        .pointer("/value/effect_tape")
        .cloned()
        .unwrap_or(Value::Null);
    let outcomes: Vec<_> = tape
        .get("entries")
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter_map(|entry| {
                    entry
                        .get("outcome")
                        .and_then(Value::as_str)
                        .map(str::to_owned)
                })
                .collect()
        })
        .unwrap_or_default();
    assert!(outcomes.contains(&"abandoned".to_owned()), "{outcomes:?}");
    assert_eq!(tape.get("status"), Some(&json!("reproducible")));
    let mut replay_request = base;
    if let Some(fields) = replay_request.as_object_mut() {
        fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
        fields.insert("effect_tape".to_owned(), tape);
    }
    let replayed = record(replay_request);
    assert_eq!(replayed.pointer("/value/output"), Some(&json!("done\n")));
    assert_eq!(
        replayed.pointer("/value/termination/kind"),
        Some(&json!("completed"))
    );
}

#[test]
fn a_detached_host_sees_every_concurrent_pending_effect() {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program": THREE_TIMERS}));
    let started = session.call(
        "start",
        &json!({"analysis": analysis.pointer("/value/resource"), "program": THREE_TIMERS,
            "host": {"permissions": ["temporizador"], "detached": true}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .unwrap_or(Value::Null);
    let advanced = session.call(
        "advance",
        &json!({"resource": resource, "batch_size": 1000}),
    );
    let pending = advanced
        .pointer("/value/pending_effects")
        .and_then(Value::as_array);
    let tasks: Vec<u64> = pending
        .map(|list| {
            list.iter()
                .filter_map(|entry| entry.get("task_id").and_then(Value::as_u64))
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(tasks, vec![1, 2, 3]);
    let sequences: Vec<u64> = pending
        .map(|list| {
            list.iter()
                .filter_map(|entry| entry.get("effect_seq").and_then(Value::as_u64))
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(sequences, vec![1, 2, 3]);
    let primary = advanced
        .pointer("/value/termination/effect_seq")
        .and_then(Value::as_u64);
    assert_eq!(primary, sequences.first().copied());
    assert_eq!(
        advanced.pointer("/value/termination/kind"),
        Some(&json!("awaiting_effect"))
    );
}

fn timer_entries(recorded: &Value) -> Vec<(u64, u64, Option<u64>, String)> {
    recorded
        .pointer("/value/effect_tape/entries")
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter(|entry| entry.get("capability_kind") == Some(&json!("timer")))
                .map(|entry| {
                    (
                        entry.get("effect_seq").and_then(Value::as_u64).unwrap_or(0),
                        entry.get("task_id").and_then(Value::as_u64).unwrap_or(0),
                        entry.get("delivery_seq").and_then(Value::as_u64),
                        entry
                            .get("outcome")
                            .and_then(Value::as_str)
                            .unwrap_or("")
                            .to_owned(),
                    )
                })
                .collect()
        })
        .unwrap_or_default()
}

#[test]
fn recorded_numbers_match_the_published_cases() {
    let reversed = timer_entries(&record(request(json!([3, 2, 1]))));
    let committed = |sequence, task, delivery| (sequence, task, delivery, "committed".to_owned());
    assert_eq!(
        reversed,
        vec![
            committed(3, 3, Some(1)),
            committed(2, 2, Some(3)),
            committed(1, 1, Some(5))
        ]
    );
    let mixed = timer_entries(&record(request(json!([2, 1, 3]))));
    assert_eq!(
        mixed,
        vec![
            committed(2, 2, Some(1)),
            committed(1, 1, Some(3)),
            committed(3, 3, Some(5))
        ]
    );
    let plain = timer_entries(&record(request(json!([]))));
    assert_eq!(
        plain,
        vec![
            committed(1, 1, None),
            committed(2, 2, Some(3)),
            committed(3, 3, Some(5))
        ]
    );
    let base = json!({"program": ABANDONED, "profile": "es", "strictness": "strict", "host": host(json!([]))});
    assert_eq!(
        timer_entries(&record(base)),
        vec![(1, 1, Some(2), "abandoned".to_owned())]
    );
}

#[test]
fn history_seek_reconstructs_states_of_a_reversed_delivery_without_consulting_the_host() {
    let mut session = ApiSession::default();
    let recorded = session.call(
        "record",
        &json!({"request": request(json!([3, 2, 1])), "options": {"capture_states": true, "seek_every_event": true, "batch_size": 1000}}),
    );
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("3\n2\n1\n")),
        "{recorded}"
    );
    assert_eq!(
        recorded.pointer("/value/termination/kind"),
        Some(&json!("completed"))
    );
    assert!(
        recorded
            .pointer("/value/states")
            .and_then(Value::as_array)
            .is_some_and(|states| !states.is_empty())
    );
}

#[test]
fn a_reordered_but_consistently_hashed_tape_diverges_from_the_program() {
    use pseudolearn_api::tape_wire::{tape_from_value, tape_to_value};
    use pseudolearn_timeline::EffectTape;
    let recorded = record(request(json!([3, 2, 1])));
    let original = tape_from_value(
        recorded
            .pointer("/value/effect_tape")
            .unwrap_or(&Value::Null),
    );
    let Ok(original) = original else {
        return;
    };
    let mut entries = original.entries().to_vec();
    entries.swap(1, 3);
    let mut forged = EffectTape::new(original.identity.clone());
    for mut entry in entries {
        entry.delivery_seq = None;
        forged.append(entry);
    }
    let mut replay_request = request(json!([]));
    if let Some(fields) = replay_request.as_object_mut() {
        fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
        fields.insert("effect_tape".to_owned(), tape_to_value(&forged));
    }
    let replayed = record(replay_request);
    let code = replayed
        .pointer("/value/termination/code")
        .or_else(|| replayed.pointer("/failure/detail"));
    assert!(
        code.and_then(Value::as_str)
            .is_some_and(|code| code.contains("replay_divergence")),
        "{}",
        replayed.to_string().chars().take(400).collect::<String>()
    );
}
