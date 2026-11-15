use serde_json::{Value, json};

pub(crate) const SCHEMA_VERSION: u64 = 1;
pub(crate) const MAXIMUM_COMMAND_BYTES: usize = 65_536;
pub(crate) const MAXIMUM_OUTPUT_BYTES: usize = 1_048_576;
pub(crate) const MAXIMUM_PENDING_INPUTS: usize = 1_024;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum EditorCommand {
    Input(String),
    Cancel,
    Close,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum CommandError {
    TooLong,
    Invalid,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum FinishStatus {
    Completed,
    Failed,
    Cancelled,
    InputClosed,
    OutputLimit,
    ProtocolError,
}

impl FinishStatus {
    pub(crate) fn name(self) -> &'static str {
        match self {
            Self::Completed => "completed",
            Self::Failed => "failed",
            Self::Cancelled => "cancelled",
            Self::InputClosed => "input_closed",
            Self::OutputLimit => "output_limit",
            Self::ProtocolError => "protocol_error",
        }
    }

    pub(crate) fn exit_code(self) -> i32 {
        i32::from(self != Self::Completed)
    }
}

pub(crate) fn parse_command(line: &str) -> Result<EditorCommand, CommandError> {
    if line.len() > MAXIMUM_COMMAND_BYTES {
        return Err(CommandError::TooLong);
    }
    let document: Value = serde_json::from_str(line).map_err(|_| CommandError::Invalid)?;
    match document.get("command").and_then(Value::as_str) {
        Some("input") => document
            .get("text")
            .and_then(Value::as_str)
            .map(|text| EditorCommand::Input(text.to_owned()))
            .ok_or(CommandError::Invalid),
        Some("cancel") => Ok(EditorCommand::Cancel),
        Some("close") => Ok(EditorCommand::Close),
        _ => Err(CommandError::Invalid),
    }
}

pub(crate) fn hello() -> Value {
    json!({
        "event": "hello",
        "schema": SCHEMA_VERSION,
        "capabilities": ["input", "cancel", "close"],
        "limits": {
            "command_bytes": MAXIMUM_COMMAND_BYTES,
            "output_bytes": MAXIMUM_OUTPUT_BYTES,
        },
    })
}

pub(crate) fn output(text: &str) -> Value {
    json!({"event": "output", "text": text})
}

pub(crate) fn awaiting_input() -> Value {
    json!({"event": "awaiting_input"})
}

pub(crate) fn protocol_error(error: CommandError) -> Value {
    let reason = match error {
        CommandError::TooLong => "command_too_long",
        CommandError::Invalid => "invalid_command",
    };
    json!({"event": "protocol_error", "reason": reason})
}

pub(crate) fn diagnostics(diagnostics: &Value, project_errors: &Value, sources: &Value) -> Value {
    json!({
        "event": "diagnostics",
        "diagnostics": diagnostics,
        "project_errors": project_errors,
        "sources": sources,
    })
}

pub(crate) fn finished(status: FinishStatus, termination: Option<&str>) -> Value {
    json!({
        "event": "finished",
        "status": status.name(),
        "termination": termination,
        "exit_code": status.exit_code(),
    })
}
