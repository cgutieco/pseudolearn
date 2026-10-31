use serde_json::json;

fn frame(value: &serde_json::Value) -> String {
    let payload = value.to_string();
    format!("Content-Length: {}\r\n\r\n{payload}", payload.len())
}

#[test]
fn compares_dap_responses_without_losing_order_or_unicode() {
    let response = json!({"seq":42,"type":"response","command":"source","success":true,"body":{"content":"é🧩"}});
    let output = frame(&response);
    let expected =
        json!({"dap":{"responses":[{"command":"source","success":true,"body":{"content":"é🧩"}}]}});
    let actual = json!({"output":output});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({"dap":{"responses":[{"command":"source","body":{"content":"é🧩"}}]}});
    assert!(!see_conformance::comparison::compare(&wrong, &actual).is_empty());
}

#[test]
fn rejects_malformed_or_trailing_dap_frames() {
    let expected = json!({"dap":{"responses":[]}});
    for output in [
        "Content-Length: -1\r\n\r\n",
        "Content-Length: 9\r\n\r\n{}",
        "garbage",
    ] {
        let actual = json!({"output":output});
        assert!(!see_conformance::comparison::compare(&expected, &actual).is_empty());
    }
}

#[test]
fn rejects_duplicate_lengths_and_wrong_response_order() {
    let first = json!({"type":"response","command":"initialize","success":true});
    let second = json!({"type":"response","command":"disconnect","success":true});
    let expected = json!({"dap":{"responses":[{"command":"initialize"},{"command":"disconnect"}]}});
    let actual = json!({"output":format!("{}{}",frame(&second),frame(&first))});
    assert!(!see_conformance::comparison::compare(&expected, &actual).is_empty());
    let actual = json!({"output":"Content-Length: 2\r\nContent-Length: 2\r\n\r\n{}"});
    assert!(
        !see_conformance::comparison::compare(&json!({"dap":{"responses":[]}}), &actual).is_empty()
    );
}
