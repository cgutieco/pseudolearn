use crate::editor_command::forward_commands;
use crate::editor_protocol::{CommandError, EditorCommand, MAXIMUM_COMMAND_BYTES};
use crate::editor_session::Inbound;
use std::io::Cursor;
use std::sync::mpsc::channel;

fn collect(bytes: &[u8]) -> Vec<Inbound> {
    let (sender, receiver) = channel();
    forward_commands(Cursor::new(bytes.to_vec()), &sender);
    drop(sender);
    receiver.iter().collect()
}

#[test]
fn forwards_commands_then_closed_on_eof() {
    let messages = collect(b"{\"command\":\"input\",\"text\":\"a b\"}\n{\"command\":\"cancel\"}\n");
    assert!(matches!(
        messages.first(),
        Some(Inbound::Command(EditorCommand::Input(text))) if text == "a b"
    ));
    assert!(matches!(
        messages.get(1),
        Some(Inbound::Command(EditorCommand::Cancel))
    ));
    assert!(matches!(messages.get(2), Some(Inbound::Closed)));
}

#[test]
fn handles_crlf_and_unterminated_last_line() {
    let messages = collect(b"{\"command\":\"close\"}\r\n{\"command\":\"cancel\"}");
    assert!(matches!(
        messages.first(),
        Some(Inbound::Command(EditorCommand::Close))
    ));
    assert!(matches!(
        messages.get(1),
        Some(Inbound::Command(EditorCommand::Cancel))
    ));
}

#[test]
fn invalid_line_stops_the_reader_with_a_protocol_error() {
    let messages = collect(b"garbage\n{\"command\":\"cancel\"}\n");
    assert_eq!(messages.len(), 1);
    assert!(matches!(
        messages.first(),
        Some(Inbound::Invalid(CommandError::Invalid))
    ));
}

#[test]
fn oversized_line_is_rejected_without_reading_it_all() {
    let mut bytes = vec![b'x'; MAXIMUM_COMMAND_BYTES.saturating_add(10)];
    bytes.push(b'\n');
    let messages = collect(&bytes);
    assert!(matches!(
        messages.first(),
        Some(Inbound::Invalid(CommandError::TooLong))
    ));
}

#[test]
fn empty_stream_is_closed() {
    assert!(matches!(collect(b"").first(), Some(Inbound::Closed)));
}
