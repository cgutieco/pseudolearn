use crate::editor_protocol::{
    CommandError, EditorCommand, FinishStatus, MAXIMUM_COMMAND_BYTES, parse_command,
};

#[test]
fn parses_input_cancel_and_close() {
    assert_eq!(
        parse_command(r#"{"command":"input","text":"7"}"#),
        Ok(EditorCommand::Input("7".to_owned()))
    );
    assert_eq!(
        parse_command(r#"{"command":"cancel"}"#),
        Ok(EditorCommand::Cancel)
    );
    assert_eq!(
        parse_command(r#"{"command":"close"}"#),
        Ok(EditorCommand::Close)
    );
}

#[test]
fn empty_input_is_a_valid_line() {
    assert_eq!(
        parse_command(r#"{"command":"input","text":""}"#),
        Ok(EditorCommand::Input(String::new()))
    );
}

#[test]
fn rejects_invalid_json_unknown_command_and_missing_text() {
    assert_eq!(parse_command("not json"), Err(CommandError::Invalid));
    assert_eq!(
        parse_command(r#"{"command":"explode"}"#),
        Err(CommandError::Invalid)
    );
    assert_eq!(
        parse_command(r#"{"command":"input"}"#),
        Err(CommandError::Invalid)
    );
    assert_eq!(
        parse_command(r#"{"command":"input","text":1}"#),
        Err(CommandError::Invalid)
    );
    assert_eq!(parse_command(""), Err(CommandError::Invalid));
}

#[test]
fn rejects_oversized_commands() {
    let long = "x".repeat(MAXIMUM_COMMAND_BYTES.saturating_add(1));
    assert_eq!(parse_command(&long), Err(CommandError::TooLong));
}

#[test]
fn only_completed_has_a_zero_exit_code() {
    assert_eq!(FinishStatus::Completed.exit_code(), 0);
    for status in [
        FinishStatus::Failed,
        FinishStatus::Cancelled,
        FinishStatus::InputClosed,
        FinishStatus::OutputLimit,
        FinishStatus::ProtocolError,
    ] {
        assert_eq!(status.exit_code(), 1);
    }
}
