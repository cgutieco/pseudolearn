use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///tipos.pseudo";

const PROGRAM: &str = "Constante Limite Como Entero <- 7;\nEnumerado Color\nRojo, Verde\nFinEnumerado\nRegistro Punto\nDefinir x Como Entero;\nFinRegistro\nInterfaz Medible\nMetodo Medida() Como Entero;\nFinInterfaz\nClase Caja Realiza Medible\nMetodo Medida() Como Entero\nRetornar Limite;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Color <- Color.Rojo;\nDefinir p Como Punto <- Punto(Limite);\nEscribir c, p.x;\nFinAlgoritmo\n";

fn opened_server() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,"text":PROGRAM}}
    }));
    server
}

fn position_of(needle: &str, occurrence: usize) -> Value {
    let offset = PROGRAM
        .match_indices(needle)
        .nth(occurrence)
        .map_or(0, |(index, _)| index);
    let before = PROGRAM.get(..offset).unwrap_or("");
    let character = before
        .rsplit('\n')
        .next()
        .map_or(0, |last| last.chars().count());
    json!({"line":before.matches('\n').count(),"character":character})
}

fn call(server: &mut LspServer, method: &str, position: Value, extra: Value) -> Value {
    let mut payload = json!({"textDocument":{"uri":URI},"position":position});
    if let (Some(target), Some(source)) = (payload.as_object_mut(), extra.as_object()) {
        target.extend(source.clone());
    }
    server
        .handle_message(&json!({"jsonrpc":"2.0","id":5,"method":method,"params":payload}))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn reference_count(server: &mut LspServer, position: Value) -> usize {
    let answer = call(
        server,
        "textDocument/references",
        position,
        json!({"context":{"includeDeclaration":true}}),
    );
    answer
        .pointer("/result")
        .and_then(Value::as_array)
        .map_or(0, Vec::len)
}

fn edit_count(answer: &Value) -> usize {
    answer
        .pointer("/result/documentChanges/0/edits")
        .and_then(Value::as_array)
        .map_or(0, Vec::len)
}

#[test]
fn every_declaration_kind_lists_its_declaration_and_every_use() {
    let mut server = opened_server();
    assert_eq!(
        reference_count(&mut server, position_of("Limite Como", 0)),
        3
    );
    assert_eq!(
        reference_count(&mut server, position_of("Color\nRojo", 0)),
        3
    );
    assert_eq!(
        reference_count(&mut server, position_of("Punto\nDefinir", 0)),
        3
    );
    assert_eq!(
        reference_count(&mut server, position_of("Medible\nMetodo", 0)),
        2
    );
}

#[test]
fn definition_from_a_use_returns_the_declaration_line() {
    let mut server = opened_server();
    for (needle, occurrence, line) in [
        ("Limite;\nFinMetodo", 0, 0),
        ("Color.Rojo", 0, 1),
        ("Punto(Limite)", 0, 4),
    ] {
        let answer = call(
            &mut server,
            "textDocument/definition",
            position_of(needle, occurrence),
            json!({}),
        );
        let found = answer
            .pointer("/result/range/start/line")
            .and_then(Value::as_u64);
        assert_eq!(found, Some(line), "{needle}: {answer}");
    }
}

#[test]
fn renaming_each_declaration_kind_edits_all_its_occurrences() {
    let mut server = opened_server();
    for (needle, new_name, expected) in [
        ("Limite Como", "Tope", 3),
        ("Color\nRojo", "Paleta", 3),
        ("Punto\nDefinir", "Marco", 3),
        ("Medible\nMetodo", "Calculable", 2),
    ] {
        let answer = call(
            &mut server,
            "textDocument/rename",
            position_of(needle, 0),
            json!({"newName":new_name}),
        );
        assert_eq!(edit_count(&answer), expected, "{needle}: {answer}");
    }
}

#[test]
fn renaming_onto_another_declared_name_is_rejected() {
    let mut server = opened_server();
    for (needle, new_name) in [
        ("Punto\nDefinir", "Color"),
        ("Punto\nDefinir", "Caja"),
        ("Limite Como", "Medible"),
        ("Color\nRojo", "Punto"),
    ] {
        let answer = call(
            &mut server,
            "textDocument/rename",
            position_of(needle, 0),
            json!({"newName":new_name}),
        );
        assert!(
            answer.get("error").is_some(),
            "{needle} -> {new_name}: {answer}"
        );
    }
}

#[test]
fn a_member_of_an_enum_is_not_a_renameable_symbol_of_the_enum() {
    let mut server = opened_server();
    let answer = call(
        &mut server,
        "textDocument/rename",
        position_of("Rojo\nFinEnumerado", 0),
        json!({"newName":"Otro"}),
    );
    assert!(
        answer.get("error").is_some() || edit_count(&answer) == 0,
        "{answer}"
    );
}
