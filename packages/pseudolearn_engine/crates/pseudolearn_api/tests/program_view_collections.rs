use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn collection_calls_project_resolved_operation_identities() -> Result<(), String> {
    let mut session = ApiSession::default();
    let source = "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.sort(); values.reverse();\nwrite values.contains(1);\ndefine position as optional<integer> <- values.indexOf(1);\ndefine entries as dictionary<string,integer> <- dictionary();\ndefine names as vector<string> <- entries.keys();\nendAlgorithm\n";
    let document = session.call("create_document", &json!({"program":source,"profile":"en"}));
    let resource = document
        .pointer("/value/resource")
        .ok_or("missing resource")?;
    let view = session.call("program_view", &json!({"resource":resource}));
    let nodes = view
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    for identity in [
        "vectorSort",
        "vectorReverse",
        "vectorContains",
        "vectorIndexOf",
        "dictionaryKeys",
    ] {
        assert!(
            nodes.iter().any(
                |node| node.get("collection_operation").and_then(Value::as_str) == Some(identity)
            ),
            "{identity}: {view}"
        );
    }
    Ok(())
}
