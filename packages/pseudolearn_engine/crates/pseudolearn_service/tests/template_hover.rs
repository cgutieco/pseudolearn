use pseudolearn_lexicon::Profile;
use pseudolearn_service::{DocumentSession, HoverCategory, HoverOutcome, LspServer, Position};
use serde_json::{Value, json};

const URI: &str = "file:///plantillas.pseudo";

const PROGRAM: &str = "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nSubProceso otro<T>(x Como T)\nFinSubProceso\nClase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nSubProceso sinUso<T>(a Como T)\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Nuevo Caja<Entero>(3);\nDefinir d Como Caja<Cadena> <- Nuevo Caja<Cadena>(\"z\");\nEscribir identidad(4), identidad(\"ab\"), c.actual(), d.actual();\notro(1);\nFinAlgoritmo\n";

fn position_of(needle: &str, occurrence: usize) -> (u32, u32) {
    let offset = PROGRAM
        .match_indices(needle)
        .nth(occurrence)
        .map_or(0, |(index, _)| index);
    let before = PROGRAM.get(..offset).unwrap_or("");
    let line = u32::try_from(before.matches('\n').count()).unwrap_or(0);
    let character = before
        .rsplit('\n')
        .next()
        .map_or(0, |last| u32::try_from(last.chars().count()).unwrap_or(0));
    (line, character)
}

fn hover(needle: &str, occurrence: usize) -> Option<HoverOutcome> {
    let (line, column) = position_of(needle, occurrence);
    DocumentSession::new(PROGRAM.to_owned(), Profile::Spanish)
        .queries()
        .hover(Position {
            line: line.saturating_add(1),
            column: column.saturating_add(1),
        })
}

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

fn call(
    server: &mut LspServer,
    method: &str,
    (needle, occurrence): (&str, usize),
    extra: Value,
) -> Value {
    let (line, character) = position_of(needle, occurrence);
    let mut payload =
        json!({"textDocument":{"uri":URI},"position":{"line":line,"character":character}});
    if let (Some(target), Some(source)) = (payload.as_object_mut(), extra.as_object()) {
        target.extend(source.clone());
    }
    server
        .handle_message(&json!({"jsonrpc":"2.0","id":5,"method":method,"params":payload}))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn lines_of(answer: &Value, pointer: &str) -> Vec<u64> {
    answer
        .pointer(pointer)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(|entry| {
            entry
                .pointer("/range/start/line")
                .or_else(|| entry.pointer("/start/line"))
                .and_then(Value::as_u64)
        })
        .collect()
}

fn references(server: &mut LspServer, needle: (&str, usize)) -> Vec<u64> {
    let answer = call(
        server,
        "textDocument/references",
        needle,
        json!({"context":{"includeDeclaration":true}}),
    );
    lines_of(&answer, "/result")
}

#[test]
fn hovering_the_template_declaration_shows_the_template_header() -> Result<(), String> {
    let outcome = hover("identidad<T>", 0).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::Template);
    let header = "SubProceso identidad<T>(valor Como T) Como T";
    assert_eq!(outcome.signature.as_deref(), Some(header));
    assert_eq!(outcome.template.as_deref(), Some(header));
    Ok(())
}

#[test]
fn hovering_an_instantiated_use_shows_the_instance_and_the_template() -> Result<(), String> {
    let outcome = hover("identidad(4)", 0).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::Function);
    assert_eq!(outcome.type_name, "Entero");
    assert_eq!(
        outcome.template.as_deref(),
        Some("SubProceso identidad<T>(valor Como T) Como T")
    );
    let text = hover("identidad(\"ab\")", 0).ok_or("expected hover")?;
    assert_eq!(text.type_name, "Cadena");
    Ok(())
}

#[test]
fn hovering_a_type_parameter_names_it_and_its_template() -> Result<(), String> {
    let outcome = hover("T)", 0).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::TypeParameter);
    assert_eq!(outcome.identifier, "T");
    assert!(
        outcome
            .template
            .is_some_and(|header| header.contains("identidad"))
    );
    Ok(())
}

#[test]
fn an_unused_template_still_has_a_symbol() -> Result<(), String> {
    let outcome = hover("sinUso", 0).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::Template);
    Ok(())
}

#[test]
fn references_from_the_template_include_every_instance_use() {
    let mut server = opened_server();
    assert_eq!(
        references(&mut server, ("identidad<T>", 0)),
        vec![0, 19, 19]
    );
    assert_eq!(
        references(&mut server, ("Caja<T>", 0)),
        vec![5, 17, 17, 18, 18]
    );
    assert_eq!(
        references(&mut server, ("identidad(4)", 0)),
        vec![0, 19, 19]
    );
}

#[test]
fn a_method_of_two_class_instances_is_one_symbol() {
    let mut server = opened_server();
    assert_eq!(
        references(&mut server, ("actual() Como", 0)),
        vec![10, 19, 19]
    );
}

#[test]
fn highlighting_the_template_marks_the_declaration_as_write_and_uses_as_read() {
    let mut server = opened_server();
    let answer = call(
        &mut server,
        "textDocument/documentHighlight",
        ("identidad(4)", 0),
        json!({}),
    );
    let kinds: Vec<u64> = answer
        .pointer("/result")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(|entry| entry.pointer("/kind").and_then(Value::as_u64))
        .collect();
    assert_eq!(kinds, vec![3, 2, 2]);
}

fn edit_lines(answer: &Value) -> Vec<u64> {
    lines_of(answer, "/result/documentChanges/0/edits")
}

#[test]
fn renaming_a_type_parameter_stays_inside_its_template() {
    let mut server = opened_server();
    let answer = call(
        &mut server,
        "textDocument/rename",
        ("T>(valor", 0),
        json!({"newName":"Elemento"}),
    );
    assert_eq!(edit_lines(&answer), vec![0, 0, 0], "{answer}");
}

#[test]
fn renaming_a_type_parameter_onto_its_sibling_is_rejected() {
    let source = PROGRAM.replace("identidad<T>(valor", "identidad<T, U>(valor");
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,"text":source}}
    }));
    let answer = server
        .handle_message(
            &json!({"jsonrpc":"2.0","id":5,"method":"textDocument/rename","params":{
            "textDocument":{"uri":URI},"position":{"line":0,"character":21},"newName":"U"}}),
        )
        .into_iter()
        .next()
        .unwrap_or(Value::Null);
    assert!(answer.get("error").is_some(), "{answer}");
}

#[test]
fn renaming_the_template_edits_the_declaration_and_every_use() {
    let mut server = opened_server();
    let answer = call(
        &mut server,
        "textDocument/rename",
        ("Caja<Entero> <-", 0),
        json!({"newName":"Cofre"}),
    );
    assert_eq!(edit_lines(&answer), vec![5, 17, 17, 18, 18], "{answer}");
}
