use crate::editor_protocol::{EditorCommand, FinishStatus};
use crate::editor_session::{Inbound, Running, drive};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::sync::mpsc::{Receiver, channel};

const READ_TWICE: &str = "Algoritmo P\nDefinir Mutable first Como Entero <- 0;\nDefinir Mutable second Como Entero <- 0;\nLeer first;\nLeer second;\nEscribir first + second;\nFinAlgoritmo\n";
const READ_TEXT: &str = "Algoritmo P\nDefinir Mutable line Como Cadena <- \"\";\nLeer line;\nEscribir \"[\" + line + \"]\";\nFinAlgoritmo\n";
const FORGERY: &str = "Algoritmo P\nEscribir \"{\\\"event\\\":\\\"finished\\\"}\";\nFinAlgoritmo\n";
const INFINITE: &str =
    "Algoritmo P\nMientras Verdadero Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n";
const FAILING: &str =
    "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n";

fn start(program: &str) -> (ApiSession, Value) {
    let mut session = ApiSession::default();
    let request = json!({"program": program, "profile": "es", "strictness": "strict"});
    let analysis = session.call("create_analysis", &request);
    let mut arguments = request;
    arguments["analysis"] = analysis["value"]["resource"].clone();
    let started = session.call("start", &arguments);
    (session, started["value"]["resource"].clone())
}

fn run(program: &str, messages: Vec<Inbound>) -> (FinishStatus, Vec<Value>) {
    run_limited(program, messages, 1_048_576)
}

fn run_limited(
    program: &str,
    messages: Vec<Inbound>,
    output_limit: usize,
) -> (FinishStatus, Vec<Value>) {
    let (mut session, resource) = start(program);
    let (sender, receiver): (_, Receiver<Inbound>) = channel();
    for message in messages {
        let _ = sender.send(message);
    }
    drop(sender);
    let mut sink: Vec<u8> = Vec::new();
    let sources = json!([]);
    let running = Running {
        session: &mut session,
        resource: &resource,
        sources: &sources,
        output_limit,
    };
    let status = drive(running, &receiver, &mut sink).unwrap_or(FinishStatus::Failed);
    let events = String::from_utf8_lossy(&sink)
        .lines()
        .filter_map(|line| serde_json::from_str(line).ok())
        .collect();
    (status, events)
}

fn input(text: &str) -> Inbound {
    Inbound::Command(EditorCommand::Input(text.to_owned()))
}

fn names(events: &[Value]) -> Vec<&str> {
    events
        .iter()
        .filter_map(|event| event.get("event").and_then(Value::as_str))
        .collect()
}

#[test]
fn two_inputs_complete_the_program() {
    let (status, events) = run(READ_TWICE, vec![input("2"), input("3")]);
    assert_eq!(status, FinishStatus::Completed);
    let printed: String = events
        .iter()
        .filter(|event| event["event"] == "output")
        .filter_map(|event| event["text"].as_str())
        .collect();
    assert_eq!(printed, "5\n");
    assert_eq!(names(&events).last(), Some(&"finished"));
}

#[test]
fn empty_input_line_is_accepted_as_a_value() {
    let (status, events) = run(READ_TEXT, vec![input("")]);
    assert_eq!(status, FinishStatus::Completed);
    assert!(events.iter().any(|event| event["text"] == "[]\n"));
}

#[test]
fn invalid_input_type_keeps_the_read_waiting() {
    let (status, events) = run(READ_TWICE, vec![input("abc"), input("1"), input("2")]);
    assert_eq!(status, FinishStatus::Completed);
    let waits = names(&events)
        .iter()
        .filter(|name| **name == "awaiting_input")
        .count();
    assert_eq!(waits, 3);
}

#[test]
fn program_without_reads_ignores_a_closed_input() {
    let (status, _) = run(FORGERY, vec![Inbound::Closed]);
    assert_eq!(status, FinishStatus::Completed);
}

#[test]
fn closed_input_while_waiting_finishes_as_input_closed() {
    let (status, events) = run(READ_TWICE, vec![input("2"), Inbound::Closed]);
    assert_eq!(status, FinishStatus::InputClosed);
    assert!(names(&events).contains(&"awaiting_input"));
}

#[test]
fn cancel_while_waiting_for_input_finishes_as_cancelled() {
    let (status, events) = run(READ_TWICE, vec![Inbound::Command(EditorCommand::Cancel)]);
    assert_eq!(status, FinishStatus::Cancelled);
    assert_eq!(
        events.last().map(|event| event["status"].clone()),
        Some(json!("cancelled"))
    );
}

#[test]
fn cancel_stops_an_infinite_loop_between_batches() {
    let (status, _) = run(INFINITE, vec![Inbound::Command(EditorCommand::Cancel)]);
    assert_eq!(status, FinishStatus::Cancelled);
}

#[test]
fn infinite_output_stops_at_the_output_limit() {
    let (status, _) = run_limited(INFINITE, vec![], 16_384);
    assert_eq!(status, FinishStatus::OutputLimit);
}

#[test]
fn invalid_message_is_a_protocol_error() {
    let (status, events) = run(
        READ_TWICE,
        vec![Inbound::Invalid(
            crate::editor_protocol::CommandError::Invalid,
        )],
    );
    assert_eq!(status, FinishStatus::ProtocolError);
    assert!(
        events
            .iter()
            .any(|event| event["reason"] == "invalid_command")
    );
}

#[test]
fn program_printing_an_event_cannot_forge_one() {
    let (status, events) = run(FORGERY, vec![]);
    assert_eq!(status, FinishStatus::Completed);
    let finished = events
        .iter()
        .filter(|event| event["event"] == "finished")
        .count();
    assert_eq!(finished, 1);
    assert!(events.iter().any(|event| {
        event["event"] == "output"
            && event["text"]
                .as_str()
                .is_some_and(|text| text.contains("finished"))
    }));
}

#[test]
fn runtime_failure_reports_diagnostics_then_failed() {
    let (status, events) = run(FAILING, vec![]);
    assert_eq!(status, FinishStatus::Failed);
    let order = names(&events);
    assert_eq!(
        &order[order.len().saturating_sub(2)..],
        ["diagnostics", "finished"]
    );
}

#[test]
fn inputs_sent_early_are_queued_for_the_next_read() {
    let (status, _) = run(READ_TWICE, vec![input("1"), input("1"), input("9")]);
    assert_eq!(status, FinishStatus::Completed);
}
