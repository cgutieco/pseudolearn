use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const LIBRARY: &str = "Publico Registro Punto\nDefinir x Como Entero;\nFinRegistro\nPublico Constante LIMITE Como Entero <- 3;\nPublico SubProceso Doble(v Como Entero) Como Entero\nRetornar v * 2;\nFinSubProceso\n";
const TYPE_IMPORT: &str = "Importar geo.formas.Punto;\nAlgoritmo Main\nDefinir p Como Punto <- Punto(1);\nEscribir p.x;\nFinAlgoritmo\n";
const CONSTANT_IMPORT: &str =
    "Importar geo.formas.LIMITE;\nAlgoritmo Main\nEscribir LIMITE;\nFinAlgoritmo\n";
const SUBPROGRAM_IMPORT: &str =
    "Importar geo.formas.Doble;\nAlgoritmo Main\nEscribir Doble(2);\nFinAlgoritmo\n";
const TYPE_TITLE: &str = "Importación de tipos y constantes";
const MODULE_TITLE: &str = "Importación de módulo o símbolo";

fn server_with_project(main: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(
        &json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}),
    );
    server.handle_message(&json!({"jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot","params":{
        "project":{"project_id":7,"revision_id":1,"packages":[
            {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
            {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}],
          "files":[{"path":"app/main","source_id":1,"text":main},{"path":"geo/formas","source_id":2,"text":LIBRARY}]},
        "uris":{"app/main":APP_URI,"geo/formas":"file:///geo/formas.pseudo"}}}));
    server
}

fn open(server: &mut LspServer, text: &str) {
    server.handle_message(&json!({"jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":APP_URI,"languageId":"pseudolearn","version":1,"text":text}}}));
}

fn help_on_import(server: &mut LspServer) -> String {
    server
        .handle_message(
            &json!({"jsonrpc":"2.0","id":2,"method":"textDocument/hover",
            "params":{"textDocument":{"uri":APP_URI},"position":{"line":0,"character":3}}}),
        )
        .into_iter()
        .next()
        .and_then(|reply| {
            reply
                .pointer("/result/contents/value")
                .and_then(Value::as_str)
                .map(str::to_owned)
        })
        .unwrap_or_default()
}

#[test]
fn importing_a_record_or_a_constant_selects_the_type_import_card() {
    for main in [TYPE_IMPORT, CONSTANT_IMPORT] {
        let mut server = server_with_project(main);
        open(&mut server, main);
        assert!(help_on_import(&mut server).contains(TYPE_TITLE), "{main}");
    }
}

#[test]
fn importing_a_subprogram_keeps_the_module_import_card() {
    let mut server = server_with_project(SUBPROGRAM_IMPORT);
    open(&mut server, SUBPROGRAM_IMPORT);
    let help = help_on_import(&mut server);
    assert!(help.contains(MODULE_TITLE));
    assert!(!help.contains(TYPE_TITLE));
}

#[test]
fn the_open_document_text_decides_over_the_snapshot_text() {
    let mut server = server_with_project(TYPE_IMPORT);
    open(&mut server, SUBPROGRAM_IMPORT);
    let help = help_on_import(&mut server);
    assert!(help.contains(MODULE_TITLE));
    assert!(!help.contains(TYPE_TITLE));
}

#[test]
fn a_document_outside_any_workspace_keeps_the_module_import_card() {
    let mut server = LspServer::new();
    server.handle_message(
        &json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}),
    );
    open(&mut server, TYPE_IMPORT);
    assert!(help_on_import(&mut server).contains(MODULE_TITLE));
}
