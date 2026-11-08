use crate::mcp_protocol::tool_result;
use serde_json::{Value, json};

const TOOL_NAMES: [&str; 7] = [
    "check",
    "run",
    "format",
    "translate",
    "explain",
    "search_reference",
    "example",
];

pub(crate) fn tool_list() -> Value {
    let tools: Vec<Value> = TOOL_NAMES.iter().map(|name| definition(name)).collect();
    json!({ "tools": tools })
}

pub(crate) fn call(parameters: &Value) -> Option<Value> {
    let name = parameters.get("name").and_then(Value::as_str)?;
    let arguments = parameters
        .get("arguments")
        .cloned()
        .unwrap_or_else(|| json!({}));
    let (payload, failed) = match name {
        "check" => crate::mcp_program_tools::check(&arguments),
        "run" => crate::mcp_program_tools::run(&arguments),
        "format" => crate::mcp_program_tools::format(&arguments),
        "translate" => crate::mcp_program_tools::translate(&arguments),
        "explain" => crate::mcp_program_tools::explain(&arguments),
        "search_reference" => crate::mcp_knowledge::search_reference(&arguments),
        "example" => crate::mcp_knowledge::example(&arguments),
        _ => return None,
    };
    Some(tool_result(&payload, failed))
}

fn definition(name: &str) -> Value {
    let (description, properties, required) = contract(name);
    json!({
        "name": name,
        "description": description,
        "inputSchema": {"type": "object", "properties": properties, "required": required}
    })
}

fn contract(name: &str) -> (&'static str, Value, Value) {
    let source = json!({"type": "string", "description": "Complete PseudoLearn program."});
    let profile = json!({"type": "string", "enum": ["es", "en"]});
    match name {
        "check" | "format" => (
            if name == "check" {
                "Analyses a program and returns its diagnostics."
            } else {
                "Returns the canonical formatting of a valid program."
            },
            json!({"source": source, "profile": profile}),
            json!(["source"]),
        ),
        "run" => (
            "Runs a program without capabilities, feeding inputs in order.",
            json!({"source": source, "profile": profile, "inputs": {"type": "array", "items": {"type": "string"}}, "step_limit": {"type": "integer"}}),
            json!(["source"]),
        ),
        "translate" => (
            "Translates a valid program to the other syntax profile.",
            json!({"source": source, "target_profile": profile}),
            json!(["source", "target_profile"]),
        ),
        _ => knowledge_contract(name, &profile),
    }
}

fn knowledge_contract(name: &str, profile: &Value) -> (&'static str, Value, Value) {
    match name {
        "explain" => (
            "Explains a diagnostic code.",
            json!({"code": {"type": "string"}, "locale": profile}),
            json!(["code"]),
        ),
        "search_reference" => (
            "Searches the language sheet.",
            json!({"query": {"type": "string"}, "locale": profile}),
            json!(["query"]),
        ),
        _ => (
            "Lists the canonical examples or returns one by id.",
            json!({"id": {"type": "string"}, "locale": profile}),
            json!([]),
        ),
    }
}
