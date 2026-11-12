use crate::physical_console::{set_exit_code, write_error};
use crate::physical_request::{Argument, Request};
use serde_json::json;

fn request(operation: &str, arguments: Vec<Argument>) -> Request {
    Request {
        operation: operation.to_owned(),
        receiver: None,
        arguments,
        result_capability: None,
    }
}

#[test]
fn reports_the_byte_count_of_the_error_text() {
    let reply = write_error(&request(
        "console_write_error",
        vec![Argument::Text("é\n".to_owned())],
    ));
    assert_eq!(
        reply.map(|value| value.pointer("/value/value").cloned()),
        Ok(Some(json!(3)))
    );
}

#[test]
fn reports_zero_bytes_for_empty_text() {
    let reply = write_error(&request(
        "console_write_error",
        vec![Argument::Text(String::new())],
    ));
    assert_eq!(
        reply.map(|value| value.pointer("/value/value").cloned()),
        Ok(Some(json!(0)))
    );
}

#[test]
fn rejects_a_non_text_argument() {
    let reply = write_error(&request("console_write_error", vec![Argument::Integer(1)]));
    assert!(reply.is_err());
}

#[test]
fn accepts_exit_codes_from_zero_to_255() {
    for code in [0, 1, 7, 255] {
        let reply = set_exit_code(&request(
            "console_set_exit_code",
            vec![Argument::Integer(code)],
        ));
        assert!(reply.is_ok(), "{code}");
    }
}

#[test]
fn rejects_exit_codes_outside_the_range() {
    for code in [-1, 256, i64::MAX, i64::MIN] {
        let reply = set_exit_code(&request(
            "console_set_exit_code",
            vec![Argument::Integer(code)],
        ));
        assert!(reply.is_err(), "{code}");
    }
}
