use crate::lsp_framing::read_next_payload;
use crate::lsp_transport_state::{
    LspJob, LspSharedState, LspTransportState, handle_cancellation, is_cancelled, submit_message,
};
use serde_json::{Value, json};
use std::collections::HashMap;
use std::io::{BufReader, Cursor};
use std::sync::atomic::AtomicUsize;
use std::sync::mpsc::{Receiver, sync_channel};
use std::sync::{Arc, Mutex};

#[test]
fn queue_rejects_the_ninth_request_and_prioritizes_cancellation() -> Result<(), String> {
    let (transport, receiver) = transport();
    for identifier in 1..=9 {
        submit_message(
            &transport,
            &json!({"jsonrpc":"2.0","id":identifier,"method":"workspace/symbol","params":{"query":""}}),
        )
        .map_err(|error| error.to_string())?;
    }
    handle_cancellation(
        &json!({"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":1}}),
        &transport.shared_state,
    )
    .map_err(|error| error.to_string())?;
    let pending = transport
        .shared_state
        .active_requests
        .lock()
        .map_err(|error| error.to_string())?;
    assert!(pending.get("1").is_some_and(is_cancelled));
    drop(pending);
    let first = receiver.try_recv().map_err(|error| error.to_string())?;
    assert!(first.cancellation.as_ref().is_some_and(is_cancelled));
    assert_eq!(responses(&transport)?.len(), 2);
    assert!(responses(&transport)?.iter().any(|answer| {
        answer.get("id") == Some(&json!(9)) && answer.pointer("/error/code") == Some(&json!(-32802))
    }));
    assert!(responses(&transport)?.iter().any(|answer| {
        answer.get("id") == Some(&json!(1)) && answer.pointer("/error/code") == Some(&json!(-32800))
    }));
    Ok(())
}

#[test]
fn notifications_burst_beyond_the_query_limit_until_the_message_limit() -> Result<(), String> {
    let (transport, _receiver) = transport();
    let notification = json!({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{}});
    for _ in 0..crate::lsp_transport_state::MAXIMUM_QUEUED_MESSAGES {
        submit_message(&transport, &notification).map_err(|error| error.to_string())?;
    }
    assert!(submit_message(&transport, &notification).is_err());
    Ok(())
}

fn transport() -> (LspTransportState<Vec<u8>>, Receiver<LspJob>) {
    let (sender, receiver) = sync_channel(crate::lsp_transport_state::MAXIMUM_QUEUED_MESSAGES);
    let shared_state = Arc::new(LspSharedState {
        output: Arc::new(Mutex::new(Vec::new())),
        active_requests: Mutex::new(HashMap::new()),
        queued_queries: AtomicUsize::new(0),
    });
    (
        LspTransportState {
            sender,
            shared_state,
        },
        receiver,
    )
}

fn responses(transport: &LspTransportState<Vec<u8>>) -> Result<Vec<Value>, String> {
    let output = transport
        .shared_state
        .output
        .lock()
        .map_err(|error| error.to_string())?
        .clone();
    let mut reader = BufReader::new(Cursor::new(output));
    let mut messages = Vec::new();
    while let Some(payload) = read_next_payload(&mut reader).map_err(|error| error.to_string())? {
        messages.push(serde_json::from_slice(&payload).map_err(|error| error.to_string())?);
    }
    Ok(messages)
}
