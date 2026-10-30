use crate::editor_protocol::{
    CommandError, FinishStatus, MAXIMUM_COMMAND_BYTES, MAXIMUM_OUTPUT_BYTES, diagnostics, finished,
    hello, parse_command,
};
use crate::editor_session::{Inbound, Running, drive, emit};
use crate::error::CliError;
use crate::options::CliOptions;
use crate::project_session::prepare;
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::io::{BufRead, Read};
use std::sync::mpsc::{Receiver, Sender, channel};
use std::thread;

struct Started {
    session: ApiSession,
    resource: Value,
    sources: Value,
}

enum Launch {
    Started(Started),
    Rejected(Value),
}

pub fn execute_editor(options: &CliOptions) -> Result<i32, CliError> {
    let launch = if options.project.directory.is_some() {
        launch_project(options)?
    } else {
        launch_file(options)?
    };
    let mut sink = std::io::stdout().lock();
    emit(&mut sink, &hello()).map_err(operational)?;
    match launch {
        Launch::Rejected(rejection) => {
            emit(&mut sink, &rejection).map_err(operational)?;
            emit(&mut sink, &finished(FinishStatus::Failed, None)).map_err(operational)?;
            Ok(FinishStatus::Failed.exit_code())
        }
        Launch::Started(mut started) => {
            let inbound = spawn_reader(Box::new(std::io::stdin()));
            let running = Running {
                session: &mut started.session,
                resource: &started.resource,
                sources: &started.sources,
                output_limit: MAXIMUM_OUTPUT_BYTES,
            };
            let status = drive(running, &inbound, &mut sink).map_err(operational)?;
            Ok(status.exit_code())
        }
    }
}

fn launch_project(options: &CliOptions) -> Result<Launch, CliError> {
    let prepared = prepare(options, true)?;
    let sources: Vec<Value> = prepared
        .snapshot
        .sources
        .iter()
        .map(|source| json!({"source_id": source.source_id, "path": source.display}))
        .collect();
    let mut session = ApiSession::default();
    let outcome = session.call("start_project", &prepared.arguments);
    let value = outcome
        .get("value")
        .cloned()
        .ok_or_else(|| operational(outcome))?;
    match value.get("resource") {
        Some(resource) => Ok(Launch::Started(Started {
            resource: resource.clone(),
            session,
            sources: Value::Array(sources),
        })),
        None => Ok(Launch::Rejected(diagnostics(
            value.get("diagnostics").unwrap_or(&json!([])),
            value.get("project_errors").unwrap_or(&json!([])),
            &Value::Array(sources),
        ))),
    }
}

fn launch_file(options: &CliOptions) -> Result<Launch, CliError> {
    let locale = &options.interface_language;
    let path = options
        .positional_arguments
        .first()
        .ok_or_else(|| CliError::Usage(crate::messages::missing_input(locale).to_owned()))?;
    let source = std::fs::read_to_string(path)
        .map_err(|_| CliError::Operational(crate::messages::unreadable_input(locale, path)))?;
    let request = crate::run_command::build_request(options, source)?;
    let sources = json!([{"source_id": 0, "path": path}]);
    let mut session = ApiSession::default();
    let analysis = call_value(&mut session, "create_analysis", &json!(request))?;
    let mut start = json!(request);
    if let Some(fields) = start.as_object_mut() {
        fields.insert(
            "analysis".to_owned(),
            analysis.get("resource").cloned().unwrap_or(Value::Null),
        );
    }
    let outcome = session.call("start", &start);
    if let Some(resource) = outcome.pointer("/value/resource") {
        return Ok(Launch::Started(Started {
            resource: resource.clone(),
            session,
            sources,
        }));
    }
    let rejected = pseudolearn_api::execute_program(&request);
    Ok(Launch::Rejected(diagnostics(
        &json!(rejected.diagnostics),
        &json!([]),
        &sources,
    )))
}

fn call_value(
    session: &mut ApiSession,
    operation: &str,
    arguments: &Value,
) -> Result<Value, CliError> {
    let outcome = session.call(operation, arguments);
    outcome
        .get("value")
        .cloned()
        .ok_or_else(|| operational(outcome))
}

fn operational(error: impl std::fmt::Display) -> CliError {
    CliError::Operational(error.to_string())
}

pub(crate) fn spawn_reader(source: Box<dyn Read + Send>) -> Receiver<Inbound> {
    let (sender, receiver) = channel();
    thread::spawn(move || forward_commands(std::io::BufReader::new(source), &sender));
    receiver
}

pub(crate) fn forward_commands<Reader: BufRead>(mut reader: Reader, sender: &Sender<Inbound>) {
    let limit = u64::try_from(MAXIMUM_COMMAND_BYTES.saturating_add(1)).unwrap_or(u64::MAX);
    loop {
        let mut line = Vec::new();
        let read = reader.by_ref().take(limit).read_until(b'\n', &mut line);
        if !matches!(read, Ok(count) if count > 0) {
            let _ = sender.send(Inbound::Closed);
            return;
        }
        let complete = line.last() == Some(&b'\n');
        let text = String::from_utf8_lossy(&line);
        let trimmed = text.trim_end_matches(['\r', '\n']);
        let message = if !complete && line.len() > MAXIMUM_COMMAND_BYTES {
            Inbound::Invalid(CommandError::TooLong)
        } else {
            match parse_command(trimmed) {
                Ok(command) => Inbound::Command(command),
                Err(error) => Inbound::Invalid(error),
            }
        };
        let stop = matches!(message, Inbound::Invalid(_));
        if sender.send(message).is_err() || stop {
            return;
        }
    }
}
