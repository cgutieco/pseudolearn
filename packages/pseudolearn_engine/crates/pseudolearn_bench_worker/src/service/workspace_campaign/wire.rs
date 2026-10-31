use crate::service::project_campaign::datasets::Dataset;
use serde_json::{Value, json};

pub const PROJECT_ID: u64 = 1;

pub fn uri_of(path: &str) -> String {
    format!("file:///workspace/{path}.pseudo")
}

pub fn initialize(id: u64) -> Value {
    json!({
        "jsonrpc": "2.0", "id": id, "method": "initialize",
        "params": {"locale": "es", "initializationOptions": {"profile": "es"}, "capabilities": {
            "textDocument": {"publishDiagnostics": {"relatedInformation": true}},
            "workspace": {"workspaceEdit": {"documentChanges": true, "failureHandling": "transactional"}}
        }}
    })
}

pub fn snapshot(dataset: &Dataset, revision: u64) -> Value {
    let files: Vec<Value> = dataset
        .files
        .iter()
        .enumerate()
        .map(|(index, file)| {
            json!({"path": file.path, "source_id": index.saturating_add(1), "text": file.text})
        })
        .collect();
    let uris: serde_json::Map<String, Value> = dataset
        .files
        .iter()
        .map(|file| (file.path.clone(), json!(uri_of(&file.path))))
        .collect();
    json!({
        "jsonrpc": "2.0", "method": "pseudolearn/workspaceSnapshot",
        "params": {
            "project": {
                "project_id": PROJECT_ID, "revision_id": revision,
                "packages": dataset.packages, "files": files,
            },
            "uris": uris,
        }
    })
}

pub fn open_document(path: &str, version: u64, text: &str) -> Value {
    json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": {"textDocument": {
            "uri": uri_of(path), "languageId": "pseudolearn", "version": version, "text": text
        }}
    })
}

pub fn change_document(path: &str, version: u64, text: &str) -> Value {
    json!({
        "jsonrpc": "2.0", "method": "textDocument/didChange",
        "params": {
            "textDocument": {"uri": uri_of(path), "version": version},
            "contentChanges": [{"text": text}],
        }
    })
}

pub fn workspace_symbols(id: u64) -> Value {
    json!({"jsonrpc": "2.0", "id": id, "method": "workspace/symbol", "params": {"query": ""}})
}

pub fn document_symbols(id: u64, path: &str) -> Value {
    json!({
        "jsonrpc": "2.0", "id": id, "method": "textDocument/documentSymbol",
        "params": {"textDocument": {"uri": uri_of(path)}}
    })
}

pub fn rename(id: u64, path: &str, position: (u64, u64), new_name: &str) -> Value {
    json!({
        "jsonrpc": "2.0", "id": id, "method": "textDocument/rename",
        "params": {
            "textDocument": {"uri": uri_of(path)},
            "position": {"line": position.0, "character": position.1},
            "newName": new_name,
        }
    })
}
