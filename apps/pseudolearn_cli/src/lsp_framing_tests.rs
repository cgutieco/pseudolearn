use crate::lsp_framing::{parse_lsp_message, read_next_payload};
use std::io::{BufReader, Cursor, ErrorKind};

#[test]
fn accepts_case_insensitive_content_length_and_json_body() {
    let mut reader = BufReader::new(Cursor::new(b"content-length: 2\r\n\r\n{}"));
    let frame = read_next_payload(&mut reader);
    assert!(frame.as_ref().is_ok_and(Option::is_some));
    if let Ok(Some(body_payload)) = frame {
        let message = parse_lsp_message(&body_payload);
        assert!(message.is_ok());
        assert!(message.is_ok_and(|value| value.is_object()));
    }
}

#[test]
fn rejects_duplicate_content_length_headers() {
    let mut reader = BufReader::new(Cursor::new(
        b"Content-Length: 2\r\ncontent-length: 2\r\n\r\n{}",
    ));
    let result = read_next_payload(&mut reader);
    assert_eq!(
        result.err().map(|error| error.kind()),
        Some(ErrorKind::InvalidData)
    );
}

#[test]
fn rejects_content_length_above_body_limit() {
    let mut reader = BufReader::new(Cursor::new(b"Content-Length: 8388609\r\n\r\n"));
    let result = read_next_payload(&mut reader);
    assert_eq!(
        result.err().map(|error| error.kind()),
        Some(ErrorKind::InvalidData)
    );
}

#[test]
fn rejects_headers_above_header_limit() {
    let mut bytes = b"Content-Length: 2\r\nX-Long: ".to_vec();
    bytes.extend(std::iter::repeat_n(b'a', 8192));
    let mut reader = BufReader::new(Cursor::new(bytes));
    let result = read_next_payload(&mut reader);
    assert_eq!(
        result.err().map(|error| error.kind()),
        Some(ErrorKind::InvalidData)
    );
}

#[test]
fn rejects_incomplete_bodies() {
    let mut reader = BufReader::new(Cursor::new(b"Content-Length: 3\r\n\r\n{}"));
    let result = read_next_payload(&mut reader);
    assert_eq!(
        result.err().map(|error| error.kind()),
        Some(ErrorKind::UnexpectedEof)
    );
}

#[test]
fn rejects_invalid_json_messages() {
    assert!(parse_lsp_message(b"{").is_err());
}
