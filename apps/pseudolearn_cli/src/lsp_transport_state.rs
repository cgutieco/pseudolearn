use crate::lsp_framing::send_lsp_response;
use pseudolearn_api::service::RequestCancellation;
use serde_json::{Value, json};
use std::collections::HashMap;
use std::io::{self, Write};
use std::sync::atomic::{AtomicU8, AtomicUsize, Ordering};
use std::sync::mpsc::{SyncSender, TrySendError};
use std::sync::{Arc, Mutex};

pub(super) const MAXIMUM_QUEUED_QUERIES: usize = 8;
pub(super) const MAXIMUM_QUEUED_MESSAGES: usize = 256;

pub(super) struct LspJob {
    pub(super) message: Value,
    pub(super) request_key: Option<String>,
    pub(super) cancellation: Option<Arc<ActiveRequest>>,
}

pub(super) struct ActiveRequest {
    status: AtomicU8,
    pub(super) token: RequestCancellation,
}

pub(super) struct LspSharedState<Writer: Write> {
    pub(super) output: Arc<Mutex<Writer>>,
    pub(super) active_requests: Mutex<HashMap<String, Arc<ActiveRequest>>>,
    pub(super) queued_queries: AtomicUsize,
}

pub(super) struct LspTransportState<Writer: Write> {
    pub(super) sender: SyncSender<LspJob>,
    pub(super) shared_state: Arc<LspSharedState<Writer>>,
}

pub(super) fn submit_message<Writer: Write>(
    transport: &LspTransportState<Writer>,
    message: &Value,
) -> io::Result<()> {
    let request_key = message.get("id").map(request_key);
    let cancellation = if let Some(key) = request_key.as_ref() {
        let Some(request) = reserve_request(transport, message, key)? else {
            return Ok(());
        };
        Some(request)
    } else {
        None
    };
    let job = LspJob {
        message: message.clone(),
        request_key,
        cancellation,
    };
    match transport.sender.try_send(job) {
        Ok(()) => Ok(()),
        Err(TrySendError::Full(job)) => reject_full_queue(transport, &job),
        Err(TrySendError::Disconnected(_)) => Err(io::Error::new(
            io::ErrorKind::BrokenPipe,
            "language server worker stopped",
        )),
    }
}

fn reserve_request<Writer: Write>(
    transport: &LspTransportState<Writer>,
    message: &Value,
    key: &str,
) -> io::Result<Option<Arc<ActiveRequest>>> {
    if transport
        .shared_state
        .queued_queries
        .fetch_add(1, Ordering::Relaxed)
        >= MAXIMUM_QUEUED_QUERIES
    {
        transport
            .shared_state
            .queued_queries
            .fetch_sub(1, Ordering::Relaxed);
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        send_shared_response(
            &transport.shared_state,
            &request_error(&identifier, -32802, "server query queue is full"),
        )?;
        return Ok(None);
    }
    let request = Arc::new(ActiveRequest {
        status: AtomicU8::new(0),
        token: RequestCancellation::new(),
    });
    transport
        .shared_state
        .active_requests
        .lock()
        .map_err(lock_error)?
        .insert(key.to_owned(), request.clone());
    Ok(Some(request))
}

fn reject_full_queue<Writer: Write>(
    transport: &LspTransportState<Writer>,
    job: &LspJob,
) -> io::Result<()> {
    if let Some(key) = job.request_key.as_deref() {
        transport
            .shared_state
            .queued_queries
            .fetch_sub(1, Ordering::Relaxed);
        remove_active_request(&transport.shared_state, Some(key));
        let identifier = job.message.get("id").cloned().unwrap_or(Value::Null);
        return send_shared_response(
            &transport.shared_state,
            &request_error(&identifier, -32802, "server query queue is full"),
        );
    }
    Err(io::Error::new(
        io::ErrorKind::WouldBlock,
        "language server notification queue is full",
    ))
}

pub(super) fn handle_cancellation<Writer: Write>(
    message: &Value,
    shared_state: &LspSharedState<Writer>,
) -> io::Result<()> {
    let Some(identifier) = message.pointer("/params/id").cloned() else {
        return Ok(());
    };
    let key = request_key(&identifier);
    let cancellation = shared_state
        .active_requests
        .lock()
        .map_err(lock_error)?
        .get(&key)
        .cloned();
    if let Some(cancellation) = cancellation
        && cancellation
            .status
            .compare_exchange(0, 1, Ordering::Relaxed, Ordering::Relaxed)
            .is_ok()
    {
        cancellation.token.cancel();
        send_shared_response(
            shared_state,
            &request_error(&identifier, -32800, "request cancelled"),
        )?;
    }
    Ok(())
}

pub(super) fn cancel_pending_requests<Writer: Write>(shared_state: &LspSharedState<Writer>) {
    if let Ok(requests) = shared_state.active_requests.lock() {
        for cancellation in requests.values() {
            let _ =
                cancellation
                    .status
                    .compare_exchange(0, 1, Ordering::Relaxed, Ordering::Relaxed);
            cancellation.token.cancel();
        }
    }
}

pub(super) fn remove_active_request<Writer: Write>(
    shared_state: &LspSharedState<Writer>,
    key: Option<&str>,
) {
    if let Some(key) = key
        && let Ok(mut requests) = shared_state.active_requests.lock()
    {
        requests.remove(key);
    }
}

pub(super) fn is_cancelled(request: &Arc<ActiveRequest>) -> bool {
    request.status.load(Ordering::Relaxed) == 1
}

pub(super) fn mark_completed(request: &Arc<ActiveRequest>) -> bool {
    request
        .status
        .compare_exchange(0, 2, Ordering::Relaxed, Ordering::Relaxed)
        .is_ok()
}

pub(super) fn send_shared_response<Writer: Write>(
    shared_state: &LspSharedState<Writer>,
    response: &Value,
) -> io::Result<()> {
    let mut output = shared_state.output.lock().map_err(lock_error)?;
    send_lsp_response(&mut *output, response)
        .map_err(|()| io::Error::new(io::ErrorKind::BrokenPipe, "language server output failed"))
}

fn request_key(identifier: &Value) -> String {
    serde_json::to_string(identifier).unwrap_or_default()
}

fn request_error(identifier: &Value, code: i64, message: &str) -> Value {
    json!({"jsonrpc":"2.0","id":identifier,"error":{"code":code,"message":message}})
}

fn lock_error<Failure>(_failure: std::sync::PoisonError<Failure>) -> io::Error {
    io::Error::other("language server transport lock failed")
}
