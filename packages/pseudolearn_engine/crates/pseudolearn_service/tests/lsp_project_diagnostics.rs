use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";

fn initialized_server(capabilities: Value) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":capabilities}
    }));
    server
}

fn cycle_workspace_message() -> Value {
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":[
                {"path":"app/main","source_id":1,"text":"Importar geo.a;\nAlgoritmo Main\nFinAlgoritmo\n"},
                {"path":"geo/a","source_id":2,"text":"Importar geo.b;\n"},
                {"path":"geo/b","source_id":3,"text":"Importar geo.a;\n"}
            ]},
            "uris":{"app/main":APP_URI,"geo/a":"file:///geo/a.pseudo","geo/b":"file:///geo/b.pseudo"}
        }
    })
}

fn cycle_diagnostic(notifications: &[Value]) -> Option<&Value> {
    notifications
        .iter()
        .filter_map(|notification| {
            notification
                .pointer("/params/diagnostics")
                .and_then(Value::as_array)
        })
        .flatten()
        .find(|diagnostic| diagnostic.get("code") == Some(&json!("importCycle")))
}

#[test]
fn project_diagnostics_include_related_locations_only_when_negotiated() {
    let cycle = cycle_workspace_message();
    let mut supported = initialized_server(json!({
        "textDocument":{"publishDiagnostics":{"relatedInformation":true}}
    }));
    let supported_notifications = supported.handle_message(&cycle);
    let related = cycle_diagnostic(&supported_notifications)
        .and_then(|diagnostic| diagnostic.pointer("/relatedInformation"))
        .and_then(Value::as_array);
    assert!(related.is_some_and(|items| {
        items.iter().any(|candidate| {
            candidate.pointer("/location/uri") == Some(&json!("file:///geo/b.pseudo"))
        })
    }));

    let mut unsupported = initialized_server(json!({}));
    let unsupported_notifications = unsupported.handle_message(&cycle);
    let diagnostics = cycle_diagnostic(&unsupported_notifications);
    assert!(
        diagnostics.is_some_and(|diagnostic| { diagnostic.get("relatedInformation").is_none() })
    );
}
