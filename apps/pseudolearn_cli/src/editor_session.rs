use crate::editor_protocol::{
    CommandError, EditorCommand, FinishStatus, MAXIMUM_PENDING_INPUTS, awaiting_input, diagnostics,
    finished, output, protocol_error,
};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::collections::VecDeque;
use std::io::{self, Write};
use std::sync::mpsc::{Receiver, TryRecvError};

pub(crate) enum Inbound {
    Command(EditorCommand),
    Closed,
    Invalid(crate::editor_protocol::CommandError),
}

pub(crate) struct Running<'run> {
    pub session: &'run mut ApiSession,
    pub resource: &'run Value,
    pub sources: &'run Value,
    pub output_limit: usize,
}

struct Pump<'pump, Sink: Write> {
    running: Running<'pump>,
    inbound: &'pump Receiver<Inbound>,
    sink: &'pump mut Sink,
    printed: usize,
    pending: VecDeque<String>,
    input_closed: bool,
    fault: Option<CommandError>,
}

pub(crate) fn emit<Sink: Write>(sink: &mut Sink, event: &Value) -> io::Result<()> {
    writeln!(sink, "{event}")?;
    sink.flush()
}

pub(crate) fn drive<Sink: Write>(
    running: Running<'_>,
    inbound: &Receiver<Inbound>,
    sink: &mut Sink,
) -> io::Result<FinishStatus> {
    let mut pump = Pump {
        running,
        inbound,
        sink,
        printed: 0,
        pending: VecDeque::new(),
        input_closed: false,
        fault: None,
    };
    pump.run()
}

impl<Sink: Write> Pump<'_, Sink> {
    fn run(&mut self) -> io::Result<FinishStatus> {
        loop {
            if let Some(status) = self.drain_inbound()? {
                return self.abandon(status);
            }
            let response = self.advance();
            self.present_output(&response)?;
            if self.printed > self.running.output_limit {
                return self.abandon(FinishStatus::OutputLimit);
            }
            let kind = termination_kind(&response);
            match kind.as_deref() {
                Some("running") => {}
                Some("awaiting_input") => {
                    if let Some(status) = self.provide_input()? {
                        return self.abandon(status);
                    }
                }
                _ => return self.conclude(&response, kind.as_deref()),
            }
        }
    }

    fn advance(&mut self) -> Value {
        let outcome = self.running.session.call(
            "advance",
            &json!({"resource": self.running.resource, "batch_size": 4096}),
        );
        outcome.get("value").cloned().unwrap_or(Value::Null)
    }

    fn present_output(&mut self, response: &Value) -> io::Result<()> {
        let text = response.get("output").and_then(Value::as_str).unwrap_or("");
        let fresh = text.get(self.printed..).unwrap_or("");
        if !fresh.is_empty() {
            emit(self.sink, &output(fresh))?;
        }
        self.printed = text.len();
        Ok(())
    }

    fn drain_inbound(&mut self) -> io::Result<Option<FinishStatus>> {
        loop {
            match self.inbound.try_recv() {
                Ok(message) => {
                    if let Some(status) = self.accept(message) {
                        return Ok(Some(status));
                    }
                }
                Err(TryRecvError::Empty | TryRecvError::Disconnected) => return Ok(None),
            }
        }
    }

    fn accept(&mut self, message: Inbound) -> Option<FinishStatus> {
        match message {
            Inbound::Command(EditorCommand::Input(text)) => {
                if self.pending.len() >= MAXIMUM_PENDING_INPUTS {
                    return Some(FinishStatus::ProtocolError);
                }
                self.pending.push_back(text);
                None
            }
            Inbound::Command(EditorCommand::Cancel | EditorCommand::Close) => {
                Some(FinishStatus::Cancelled)
            }
            Inbound::Closed => {
                self.input_closed = true;
                None
            }
            Inbound::Invalid(error) => {
                self.fault = Some(error);
                Some(FinishStatus::ProtocolError)
            }
        }
    }

    fn provide_input(&mut self) -> io::Result<Option<FinishStatus>> {
        emit(self.sink, &awaiting_input())?;
        loop {
            if let Some(text) = self.pending.pop_front() {
                let accepted = self.submit(&text);
                return Ok((!accepted).then_some(FinishStatus::Failed));
            }
            if self.input_closed {
                return Ok(Some(FinishStatus::InputClosed));
            }
            let Ok(message) = self.inbound.recv() else {
                return Ok(Some(FinishStatus::InputClosed));
            };
            if let Some(status) = self.accept(message) {
                return Ok(Some(status));
            }
        }
    }

    fn submit(&mut self, text: &str) -> bool {
        self.running
            .session
            .call(
                "input",
                &json!({"resource": self.running.resource, "text": text}),
            )
            .get("value")
            .is_some()
    }

    fn abandon(&mut self, status: FinishStatus) -> io::Result<FinishStatus> {
        self.running
            .session
            .call("cancel", &json!({"resource": self.running.resource}));
        self.running
            .session
            .call("release", &json!({"resource": self.running.resource}));
        if let Some(error) = self.fault {
            emit(self.sink, &protocol_error(error))?;
        }
        emit(self.sink, &finished(status, None))?;
        Ok(status)
    }

    fn conclude(&mut self, response: &Value, kind: Option<&str>) -> io::Result<FinishStatus> {
        let reported = response.get("diagnostics").cloned().unwrap_or(json!([]));
        if reported.as_array().is_some_and(|items| !items.is_empty()) {
            emit(
                self.sink,
                &diagnostics(&reported, &json!([]), self.running.sources),
            )?;
        }
        let status = match kind {
            Some("completed") => FinishStatus::Completed,
            Some("cancelled") => FinishStatus::Cancelled,
            _ => FinishStatus::Failed,
        };
        self.running
            .session
            .call("release", &json!({"resource": self.running.resource}));
        emit(self.sink, &finished(status, kind))?;
        Ok(status)
    }
}

fn termination_kind(response: &Value) -> Option<String> {
    response
        .pointer("/termination/kind")
        .and_then(Value::as_str)
        .map(str::to_owned)
}
