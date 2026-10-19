use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const INHERITANCE: &str = "Clase Base\nMetodo valor() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nClase Hija Hereda De Base\nMetodo valor() Como Entero\nRetornar 2;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n";

fn document(session: &mut ApiSession, program: &str) -> Result<Value, String> {
    session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| "missing document".to_owned())
}

fn view(session: &mut ApiSession, document: &Value) -> Value {
    session.call("program_view", &json!({"resource":document}))
}

#[test]
fn view_lists_units_in_source_order_with_inheritance_and_overrides() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(&mut session, INHERITANCE)?;
    let result = view(&mut session, &document);
    assert_eq!(
        result.pointer("/value/units"),
        Some(&json!([
            {"kind":"class","name":"Base","order":0},
            {"kind":"class","name":"Hija","order":1},
            {"kind":"algorithm","name":"P","order":2}
        ]))
    );
    assert_eq!(
        result.pointer("/value/inheritance"),
        Some(&json!([{"class":"Hija","base":"Base"}]))
    );
    let methods = result.pointer("/value/methods").ok_or("missing methods")?;
    assert!(
        methods
            .as_array()
            .ok_or("methods")?
            .contains(&json!({"class":"Hija","name":"valor","overrides":"Base.valor"}))
    );
    Ok(())
}

#[test]
fn nodes_have_unique_identifiers_and_resolvable_references() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Algoritmo P\nDefinir total Como Entero;\ntotal <- 2 + 3;\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let identifiers: Vec<_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id"))
        .collect();
    let mut unique = identifiers.clone();
    unique.sort_by_key(|value| value.to_string());
    unique.dedup();
    assert_eq!(unique.len(), identifiers.len());
    for node in nodes {
        for child in node
            .get("child_node_ids")
            .and_then(Value::as_array)
            .ok_or("children")?
        {
            assert!(identifiers.contains(&child));
        }
        if let Some(parent) = node.get("parent_node_id") {
            assert!(identifiers.contains(&parent));
        }
    }
    for kind in ["declaration", "statement", "expression"] {
        assert!(
            nodes
                .iter()
                .any(|node| node.get("kind") == Some(&json!(kind)))
        );
    }
    Ok(())
}

#[test]
fn statement_span_uses_utf8_byte_offsets_and_codepoint_columns() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Algoritmo P\nEscribir \"🧩\";\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let expected = json!({
        "start_byte":"12","end_byte":"28",
        "start":{"line":2,"column":1},"end":{"line":2,"column":14}
    });
    assert!(nodes.iter().any(|node| {
        node.get("kind") == Some(&json!("statement")) && node.get("span") == Some(&expected)
    }));
    Ok(())
}

#[test]
fn released_document_and_foreign_revision_are_usage_errors() -> Result<(), String> {
    let mut session = ApiSession::default();
    let first = document(&mut session, INHERITANCE)?;
    let second = document(&mut session, "Algoritmo P\nFinAlgoritmo\n")?;
    let first_view = view(&mut session, &first);
    let identifier = first_view
        .pointer("/value/nodes/0/node_id")
        .cloned()
        .ok_or("missing node")?;
    let own = session.call(
        "query_node",
        &json!({"resource":first,"node_id":identifier}),
    );
    assert!(own.pointer("/value/node").is_some());
    let foreign = session.call(
        "query_node",
        &json!({"resource":second,"node_id":identifier}),
    );
    assert_eq!(foreign.pointer("/failure/family"), Some(&json!("usage")));
    session.call("release", &json!({"resource":first}));
    let released = session.call("program_view", &json!({"resource":first}));
    assert_eq!(released.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn programs_with_syntax_errors_have_no_view() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(&mut session, "Algoritmo P\nEscribir ;\n")?;
    let result = view(&mut session, &document);
    assert_eq!(result.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn empty_algorithm_has_a_single_unit_view() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(&mut session, "Algoritmo P\nFinAlgoritmo\n")?;
    let result = view(&mut session, &document);
    assert_eq!(
        result.pointer("/value/units"),
        Some(&json!([{"kind":"algorithm","name":"P","order":0}]))
    );
    Ok(())
}
