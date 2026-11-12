use crate::dap_session::DapSession;
use crate::lsp_framing::{parse_lsp_message, read_next_payload, send_lsp_response};
use crate::options::CliOptions;
use serde_json::Value;
use std::io::{BufReader, Write};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc::{Receiver, RecvTimeoutError, sync_channel};
use std::time::Duration;

pub(crate) fn execute(options: &CliOptions) -> i32 {
    let overflow = Arc::new(AtomicBool::new(false));
    let messages = reader(overflow.clone());
    let mut session = DapSession::new(Some(options.clone()));
    let mut output = std::io::stdout().lock();
    let mut sequence = 0_u64;
    let result = drive(
        &mut session,
        &messages,
        (&mut output, &mut sequence),
        &overflow,
    );
    session.close();
    i32::from(result.is_err())
}

fn reader(overflow: Arc<AtomicBool>) -> Receiver<Result<Value, String>> {
    let (sender, receiver) = sync_channel(8);
    std::thread::spawn(move || {
        let mut input = BufReader::new(std::io::stdin());
        loop {
            let message = match read_next_payload(&mut input) {
                Ok(Some(payload)) => parse_lsp_message(&payload).map_err(|error| error.to_string()),
                Ok(None) => return,
                Err(error) => Err(error.to_string()),
            };
            let invalid = message.is_err();
            if sender.try_send(message).is_err() {
                overflow.store(true, Ordering::SeqCst);
                return;
            }
            if invalid {
                return;
            }
        }
    });
    receiver
}

fn drive<Writer: Write>(
    session: &mut DapSession,
    messages: &Receiver<Result<Value, String>>,
    output_and_sequence: (&mut Writer, &mut u64),
    overflow: &AtomicBool,
) -> Result<(), String> {
    let (output, sequence) = output_and_sequence;
    loop {
        if overflow.load(Ordering::SeqCst) {
            return Err("debug request queue exceeded eight requests".to_owned());
        }
        let delay = if session.can_advance() { 0 } else { 10 };
        match messages.recv_timeout(Duration::from_millis(delay)) {
            Ok(Ok(request)) => write(output, sequence, session.handle(&request))?,
            Ok(Err(error)) => return Err(error),
            Err(RecvTimeoutError::Disconnected) => return Err("unexpected debug EOF".to_owned()),
            Err(RecvTimeoutError::Timeout) => {}
        }
        if session.is_finished() {
            return Ok(());
        }
        write(output, sequence, session.pump())?;
    }
}

fn write<Writer: Write>(
    output: &mut Writer,
    sequence: &mut u64,
    messages: Vec<Value>,
) -> Result<(), String> {
    for mut message in messages {
        *sequence = sequence.checked_add(1).ok_or("debug sequence exhausted")?;
        message["seq"] = Value::from(*sequence);
        send_lsp_response(output, &message).map_err(|()| "debug output closed".to_owned())?;
    }
    Ok(())
}
