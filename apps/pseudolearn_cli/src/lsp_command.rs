use crate::lsp_framing::{parse_lsp_message, read_next_payload};
use crate::lsp_transport_state::{
    LspJob, LspSharedState, LspTransportState, cancel_pending_requests, handle_cancellation,
    is_cancelled, mark_completed, remove_active_request, send_shared_response, submit_message,
};
use crate::lsp_workspace_loader::WorkspaceLoader;
use crate::options::CliOptions;
use pseudolearn_api::service::LspServer;
use serde_json::Value;
use std::collections::HashMap;
use std::io::{self, BufRead, BufReader, Write};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc::{Receiver, sync_channel};
use std::sync::{Arc, Mutex};
use std::thread;

pub fn execute_lsp(options: &CliOptions) -> i32 {
    let standard_input = std::io::stdin();
    let mut reader = BufReader::new(standard_input.lock());
    run_lsp_transport(
        &mut reader,
        Arc::new(Mutex::new(std::io::stdout())),
        &options.interface_language,
    )
}

fn run_lsp_transport<Reader: BufRead, Writer: Write + Send + 'static>(
    reader: &mut Reader,
    standard_output: Arc<Mutex<Writer>>,
    locale: &str,
) -> i32 {
    let (sender, receiver) = sync_channel(crate::lsp_transport_state::MAXIMUM_QUEUED_MESSAGES);
    let shared_state = Arc::new(LspSharedState {
        output: standard_output,
        active_requests: Mutex::new(HashMap::new()),
        queued_queries: AtomicUsize::new(0),
    });
    let transport_state = LspTransportState {
        sender,
        shared_state: shared_state.clone(),
    };
    let language = locale.to_owned();
    let worker = thread::spawn(move || run_lsp_worker(receiver, &shared_state, language));
    let received_exit = read_lsp_messages(reader, &transport_state).unwrap_or(false);
    if !received_exit {
        cancel_pending_requests(&transport_state.shared_state);
    }
    drop(transport_state);
    let worker_code = worker.join().unwrap_or(1);
    if received_exit { worker_code } else { 1 }
}

fn read_lsp_messages<Reader: BufRead, Writer: Write>(
    reader: &mut Reader,
    transport: &LspTransportState<Writer>,
) -> io::Result<bool> {
    loop {
        let Some(payload) = read_next_payload(reader)? else {
            return Ok(false);
        };
        let message = parse_lsp_message(&payload).map_err(invalid_json)?;
        if message.get("method").and_then(Value::as_str) == Some("$/cancelRequest") {
            handle_cancellation(&message, &transport.shared_state)?;
            continue;
        }
        let received_exit = message.get("method").and_then(Value::as_str) == Some("exit");
        submit_message(transport, &message)?;
        if received_exit {
            return Ok(true);
        }
    }
}

fn run_lsp_worker<Writer: Write + Send + 'static>(
    receiver: Receiver<LspJob>,
    shared_state: &LspSharedState<Writer>,
    locale: String,
) -> i32 {
    let mut server = LspServer::new();
    let mut loader = WorkspaceLoader::new(&locale);
    server.locale = locale;
    for job in receiver {
        loader.observe(&job.message);
        if process_lsp_job(&job, shared_state, &mut server).is_err()
            || resync_workspace(&job, shared_state, &mut server, &mut loader).is_err()
        {
            return 1;
        }
        if server.is_finished() {
            break;
        }
    }
    server.exit_code.unwrap_or(1)
}

fn resync_workspace<Writer: Write>(
    job: &LspJob,
    shared_state: &LspSharedState<Writer>,
    server: &mut LspServer,
    loader: &mut WorkspaceLoader,
) -> io::Result<()> {
    let Some(snapshot) = loader.resync(&job.message) else {
        return Ok(());
    };
    send_job_responses(shared_state, &server.handle_message(&snapshot))
}

fn process_lsp_job<Writer: Write>(
    job: &LspJob,
    shared_state: &LspSharedState<Writer>,
    server: &mut LspServer,
) -> io::Result<()> {
    if job.request_key.is_some() {
        shared_state.queued_queries.fetch_sub(1, Ordering::Relaxed);
    }
    if job.cancellation.as_ref().is_some_and(is_cancelled) {
        remove_active_request(shared_state, job.request_key.as_deref());
        return Ok(());
    }
    let responses = handle_job_message(server, job);
    if job.cancellation.as_ref().is_none_or(mark_completed) {
        send_job_responses(shared_state, &responses)?;
    }
    remove_active_request(shared_state, job.request_key.as_deref());
    Ok(())
}

fn handle_job_message(server: &mut LspServer, job: &LspJob) -> Vec<Value> {
    match &job.cancellation {
        Some(active) => server.handle_cancellable_message(&job.message, active.token.clone()),
        None => server.handle_message(&job.message),
    }
}

fn send_job_responses<Writer: Write>(
    shared_state: &LspSharedState<Writer>,
    responses: &[Value],
) -> io::Result<()> {
    for response in responses {
        send_shared_response(shared_state, response)?;
    }
    Ok(())
}

fn invalid_json(error: serde_json::Error) -> io::Error {
    io::Error::new(io::ErrorKind::InvalidData, error)
}
