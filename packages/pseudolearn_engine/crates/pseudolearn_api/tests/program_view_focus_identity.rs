use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn program_view(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| "missing document".to_owned())?;
    let response = session.call("program_view", &json!({"resource":document}));
    response
        .pointer("/value")
        .cloned()
        .ok_or_else(|| format!("missing view: {response}"))
}

fn nodes(view: &Value) -> Result<&Vec<Value>, String> {
    view.get("nodes")
        .and_then(Value::as_array)
        .ok_or_else(|| "missing nodes".to_owned())
}

fn create_document(
    session: &mut ApiSession,
    source: &str,
    previous: Option<&Value>,
) -> Result<Value, String> {
    let request = match previous {
        Some(previous) => json!({"program":source,"previous_document":previous}),
        None => json!({"program":source}),
    };
    session
        .call("create_document", &request)
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| "missing document".to_owned())
}

fn unit_named<'view>(view: &'view Value, name: &str) -> Option<&'view Value> {
    view.pointer("/value/units")
        .or_else(|| view.get("units"))?
        .as_array()?
        .iter()
        .find(|unit| unit.get("name").and_then(Value::as_str) == Some(name))
}

fn ancestor_with_kind<'nodes>(
    nodes: &'nodes [Value],
    node: &'nodes Value,
    kind: &str,
) -> Option<&'nodes Value> {
    let mut parent = node.get("parent_node_id")?.as_str()?;
    loop {
        let ancestor = nodes
            .iter()
            .find(|candidate| candidate.get("node_id").and_then(Value::as_str) == Some(parent))?;
        if ancestor.get("syntax_kind").and_then(Value::as_str) == Some(kind) {
            return Some(ancestor);
        }
        parent = ancestor.get("parent_node_id").and_then(Value::as_str)?;
    }
}

#[test]
fn one_character_symbols_keep_exact_ranges_and_distinct_identities() -> Result<(), String> {
    let source = "Algoritmo A\nDefinir x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n";
    let view = program_view(source)?;
    let nodes = nodes(&view)?;
    let symbols: Vec<_> = nodes
        .iter()
        .filter(|node| {
            node.get("kind") == Some(&json!("symbol"))
                && node.get("syntax_kind") == Some(&json!("identifier"))
        })
        .collect();

    assert_eq!(symbols.len(), 2);
    let algorithm_name = symbols
        .iter()
        .find(|node| node.pointer("/span/start/line") == Some(&json!(1)))
        .ok_or("missing algorithm name")?;
    let declaration = symbols
        .iter()
        .find(|node| node.pointer("/span/start/line") == Some(&json!(2)))
        .ok_or("missing declaration symbol")?;
    assert_eq!(
        algorithm_name.pointer("/span/start/column"),
        Some(&json!(11))
    );
    assert_eq!(algorithm_name.pointer("/span/end/column"), Some(&json!(12)));
    assert_eq!(declaration.pointer("/span/start/column"), Some(&json!(9)));
    assert_eq!(declaration.pointer("/span/end/column"), Some(&json!(10)));
    assert_ne!(algorithm_name.get("node_id"), declaration.get("node_id"));
    Ok(())
}

#[test]
fn statements_on_one_line_keep_distinct_ranges_and_identities() -> Result<(), String> {
    let source = "Algoritmo A\nEscribir 1; Escribir 2; Escribir 3;\nFinAlgoritmo\n";
    let view = program_view(source)?;
    let statements: Vec<_> = nodes(&view)?
        .iter()
        .filter(|node| {
            node.get("kind") == Some(&json!("statement"))
                && node.get("syntax_kind") == Some(&json!("output"))
                && node.pointer("/span/start/line") == Some(&json!(2))
        })
        .collect();

    assert_eq!(statements.len(), 3);
    let identifiers: Vec<_> = statements
        .iter()
        .filter_map(|node| node.get("node_id"))
        .collect();
    let mut unique = identifiers.clone();
    unique.sort_by_key(|value| value.to_string());
    unique.dedup();
    assert_eq!(unique.len(), 3);
    assert_eq!(
        statements
            .iter()
            .filter_map(|node| node.pointer("/span/start/column").and_then(Value::as_u64))
            .collect::<Vec<_>>(),
        [1, 13, 25]
    );
    Ok(())
}

#[test]
fn empty_source_has_no_view() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = create_document(&mut session, "", None)?;
    let response = session.call("program_view", &json!({"resource":resource}));

    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn inserting_a_unit_changes_public_order_and_rejects_old_node_identity() -> Result<(), String> {
    let mut session = ApiSession::default();
    let first = create_document(
        &mut session,
        "Clase Target\nFinClase\nAlgoritmo Main\nFinAlgoritmo\n",
        None,
    )?;
    let original = session.call("program_view", &json!({"resource":first}));
    let original_target = unit_named(&original, "Target").ok_or("missing original target")?;
    assert_eq!(original_target.get("name"), Some(&json!("Target")));
    assert_eq!(original_target.get("order"), Some(&json!(0)));
    let old_node = original_target
        .get("node_id")
        .cloned()
        .ok_or("missing original node identity")?;

    let successor = create_document(
        &mut session,
        "Clase Leading\nFinClase\nClase Target\nFinClase\nAlgoritmo Main\nFinAlgoritmo\n",
        Some(&first),
    )?;
    let stale = session.call(
        "query_node",
        &json!({"resource":successor,"node_id":old_node}),
    );
    assert_eq!(stale.pointer("/failure/family"), Some(&json!("usage")));

    let current = session.call("program_view", &json!({"resource":successor}));
    let current_target = unit_named(&current, "Target").ok_or("missing shifted target")?;
    assert_eq!(current_target.get("name"), Some(&json!("Target")));
    assert_eq!(current_target.get("order"), Some(&json!(1)));
    let current_node = current_target
        .get("node_id")
        .cloned()
        .ok_or("missing current node identity")?;
    assert!(
        session
            .call(
                "query_node",
                &json!({"resource":successor,"node_id":current_node})
            )
            .pointer("/value/node")
            .is_some()
    );
    Ok(())
}

#[test]
fn repeated_parameter_names_resolve_inside_distinct_subprogram_scopes() -> Result<(), String> {
    let source = "SubProceso first(value Como Entero)\nEscribir value;\nFinSubProceso\nSubProceso second(value Como Entero)\nEscribir value;\nFinSubProceso\nAlgoritmo A\nFinAlgoritmo\n";
    let view = program_view(source)?;
    let nodes = nodes(&view)?;
    let parameters: Vec<_> = nodes
        .iter()
        .filter(|node| node.get("syntax_kind") == Some(&json!("parameter")))
        .collect();

    assert_eq!(parameters.len(), 2);
    let first_parameter = parameters.first().ok_or("missing first parameter")?;
    let second_parameter = parameters.get(1).ok_or("missing second parameter")?;
    assert_ne!(
        first_parameter.get("node_id"),
        second_parameter.get("node_id")
    );
    let first_scope = ancestor_with_kind(nodes, first_parameter, "subroutine")
        .ok_or("missing first parameter scope")?;
    let second_scope = ancestor_with_kind(nodes, second_parameter, "subroutine")
        .ok_or("missing second parameter scope")?;
    assert_ne!(first_scope.get("node_id"), second_scope.get("node_id"));
    assert_eq!(first_parameter.pointer("/span/start/line"), Some(&json!(1)));
    assert_eq!(
        second_parameter.pointer("/span/start/line"),
        Some(&json!(4))
    );
    Ok(())
}
