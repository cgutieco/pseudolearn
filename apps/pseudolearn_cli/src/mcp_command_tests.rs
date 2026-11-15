use crate::mcp_command::respond;
use serde_json::Value;

fn answer(line: &str) -> Value {
    respond(line).unwrap_or(Value::Null)
}

#[test]
fn notifications_and_blank_requests_get_no_answer() {
    assert!(respond(r#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#).is_none());
}

#[test]
fn malformed_lines_and_unknown_methods_are_protocol_errors() {
    assert_eq!(
        answer("{").pointer("/error/code"),
        Some(&Value::from(-32700))
    );
    assert_eq!(
        answer(r#"{"id":1}"#).pointer("/error/code"),
        Some(&Value::from(-32600))
    );
    let unknown = answer(r#"{"jsonrpc":"2.0","id":2,"method":"x"}"#);
    assert_eq!(unknown.pointer("/error/code"), Some(&Value::from(-32601)));
    assert_eq!(unknown.get("id"), Some(&Value::from(2)));
    let oversized = format!("\"{}\"", "a".repeat(1_048_577));
    assert_eq!(
        answer(&oversized).pointer("/error/code"),
        Some(&Value::from(-32600))
    );
}

#[test]
fn tools_list_announces_seven_tools_in_order() {
    let listed = answer(r#"{"jsonrpc":"2.0","id":3,"method":"tools/list"}"#);
    let names: Vec<&str> = listed
        .pointer("/result/tools")
        .and_then(Value::as_array)
        .map(|tools| {
            tools
                .iter()
                .filter_map(|tool| tool.get("name").and_then(Value::as_str))
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(
        names,
        [
            "check",
            "run",
            "format",
            "translate",
            "explain",
            "search_reference",
            "example"
        ]
    );
}

#[test]
fn reading_a_known_resource_returns_the_sheet() {
    let read = answer(
        r#"{"jsonrpc":"2.0","id":4,"method":"resources/read","params":{"uri":"pseudolearn://language-sheet/en"}}"#,
    );
    let text = read
        .pointer("/result/contents/0/text")
        .and_then(Value::as_str)
        .unwrap_or("");
    assert!(text.starts_with("# PseudoLearn: language sheet for agents"));
}
