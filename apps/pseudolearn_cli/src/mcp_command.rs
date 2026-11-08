use crate::mcp_protocol::{
    INVALID_PARAMS, METHOD_NOT_FOUND, McpMessage, error, initialize_result, parse_line, success,
};
use serde_json::Value;
use std::io::{BufRead, Write};

pub(crate) fn execute_mcp() -> i32 {
    let input = std::io::stdin().lock();
    let mut output = std::io::stdout().lock();
    for line in input.lines() {
        let Ok(line) = line else {
            return 3;
        };
        if line.trim().is_empty() {
            continue;
        }
        if let Some(response) = respond(&line)
            && writeln!(output, "{response}")
                .and_then(|()| output.flush())
                .is_err()
        {
            return 3;
        }
    }
    0
}

pub(crate) fn respond(line: &str) -> Option<Value> {
    match parse_line(line) {
        McpMessage::Notification => None,
        McpMessage::Malformed(response) => Some(response),
        McpMessage::Request {
            identity,
            method,
            parameters,
        } => Some(answer(&identity, &method, &parameters)),
    }
}

fn answer(identity: &Value, method: &str, parameters: &Value) -> Value {
    match method {
        "initialize" => success(identity, &initialize_result()),
        "ping" => success(identity, &serde_json::json!({})),
        "tools/list" => success(identity, &crate::mcp_tools::tool_list()),
        "tools/call" => match crate::mcp_tools::call(parameters) {
            Some(result) => success(identity, &result),
            None => error(identity, INVALID_PARAMS, "Unknown tool"),
        },
        "resources/list" => success(identity, &crate::mcp_knowledge::resource_list()),
        "resources/read" => match crate::mcp_knowledge::read_resource(parameters) {
            Some(result) => success(identity, &result),
            None => error(identity, INVALID_PARAMS, "Unknown resource"),
        },
        _ => error(identity, METHOD_NOT_FOUND, "Method not found"),
    }
}
