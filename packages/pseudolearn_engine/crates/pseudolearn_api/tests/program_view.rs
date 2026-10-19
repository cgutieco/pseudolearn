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
    let units = result
        .pointer("/value/units")
        .and_then(Value::as_array)
        .ok_or("missing units")?;
    assert_eq!(units.len(), 3);
    for (unit, expected) in units.iter().zip([
        json!({"kind":"class","name":"Base","order":0}),
        json!({"kind":"class","name":"Hija","order":1}),
        json!({"kind":"algorithm","name":"P","order":2}),
    ]) {
        for (field, value) in expected.as_object().ok_or("expected unit")? {
            assert_eq!(unit.get(field), Some(value));
        }
        assert!(unit.get("node_id").and_then(Value::as_str).is_some());
        assert!(unit.get("span").and_then(Value::as_object).is_some());
    }
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
    let members = result
        .pointer("/value/members")
        .and_then(Value::as_array)
        .ok_or("missing members")?;
    let method = members
        .iter()
        .find(|member| member.get("name") == Some(&json!("valor")))
        .ok_or("missing class method")?;
    assert_eq!(method.get("class"), Some(&json!("Base")));
    assert_eq!(method.get("kind"), Some(&json!("method")));
    assert_eq!(method.get("visibility"), Some(&json!("public")));
    assert_eq!(method.get("arity"), Some(&json!(0)));
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
    for kind in ["declaration", "statement", "expression", "symbol", "type"] {
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
fn subprogram_units_resolve_to_public_nodes() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "SubProceso vacia()\nEscribir 0;\nFinSubProceso\nSubProceso valor() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let units = result
        .pointer("/value/units")
        .and_then(Value::as_array)
        .ok_or("missing units")?;
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    for unit in units
        .iter()
        .filter(|unit| unit.get("kind") == Some(&json!("subprogram")))
    {
        let identifier = unit
            .get("node_id")
            .and_then(Value::as_str)
            .ok_or("subprogram node identifier is missing")?;
        assert!(nodes.iter().any(|node| {
            node.get("node_id") == Some(&json!(identifier))
                && node.get("syntax_kind") == Some(&json!("subroutine"))
        }));
        assert!(unit.get("span").and_then(Value::as_object).is_some());
    }
    assert_eq!(
        units
            .iter()
            .filter(|unit| unit.get("kind") == Some(&json!("subprogram")))
            .count(),
        2
    );
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
    let unit = result.pointer("/value/units/0").ok_or("missing unit")?;
    assert_eq!(unit.get("kind"), Some(&json!("algorithm")));
    assert_eq!(unit.get("name"), Some(&json!("P")));
    assert_eq!(unit.get("order"), Some(&json!(0)));
    assert!(unit.get("node_id").and_then(Value::as_str).is_some());
    assert!(unit.pointer("/span/start_byte").is_some());
    Ok(())
}

#[test]
fn class_members_expose_names_visibility_and_arity() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Clase Caja\nPrivado Definir saldo Como Entero;\nPrivado Dimension matriz[2, 3] Como Entero;\nPublico Metodo ajustar(monto[,,] Como Entero)\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let members = result
        .pointer("/value/members")
        .and_then(Value::as_array)
        .ok_or("missing members")?;
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let field = members
        .iter()
        .find(|member| member.get("name") == Some(&json!("saldo")))
        .ok_or("missing class field")?;
    assert_eq!(field.get("class"), Some(&json!("Caja")));
    assert_eq!(field.get("kind"), Some(&json!("field")));
    assert_eq!(field.get("visibility"), Some(&json!("private")));
    assert_eq!(field.get("type"), Some(&json!("Entero")));
    assert_eq!(field.get("dimensions"), Some(&json!(0)));
    assert!(field.get("node_id").and_then(Value::as_str).is_some());
    let array = members
        .iter()
        .find(|member| member.get("name") == Some(&json!("matriz")))
        .ok_or("missing class array")?;
    assert_eq!(array.get("type"), Some(&json!("Entero")));
    assert_eq!(array.get("dimensions"), Some(&json!(2)));
    let method = members
        .iter()
        .find(|member| member.get("name") == Some(&json!("ajustar")))
        .ok_or("missing method")?;
    for (field, value) in json!({
        "class":"Caja","name":"ajustar","kind":"method","visibility":"public","arity":1
    })
    .as_object()
    .ok_or("expected member")?
    {
        assert_eq!(method.get(field), Some(value));
    }
    let identifier = method
        .get("node_id")
        .and_then(Value::as_str)
        .ok_or("missing member node")?;
    assert!(nodes.iter().any(|node| {
        node.get("node_id") == Some(&json!(identifier))
            && node.get("syntax_kind") == Some(&json!("method_member"))
    }));
    let parameter = nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!("parameter")))
        .ok_or("missing method parameter")?;
    assert_eq!(parameter.get("dimensions"), Some(&json!(3)));
    Ok(())
}

#[test]
fn nodes_expose_stable_construct_kinds() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Algoritmo P\nSi verdadero Entonces\nMientras falso Hacer\nEscribir 1;\nFinMientras\nFinSi\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    for kind in ["conditional", "while_loop", "output"] {
        assert!(
            nodes
                .iter()
                .any(|node| { node.get("syntax_kind") == Some(&json!(kind)) })
        );
    }
    Ok(())
}

#[test]
fn conditional_children_expose_branch_roles() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Algoritmo P\nSi verdadero Entonces\nEscribir 1;\nSino\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let conditional = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .and_then(|nodes| {
            nodes
                .iter()
                .find(|node| node.get("syntax_kind") == Some(&json!("conditional")))
        })
        .ok_or("missing conditional")?;
    let roles = conditional
        .get("child_roles")
        .and_then(Value::as_array)
        .ok_or("missing child roles")?;
    assert!(
        roles
            .iter()
            .any(|role| role.get("role") == Some(&json!("then_body")))
    );
    assert!(
        roles
            .iter()
            .any(|role| role.get("role") == Some(&json!("else_body")))
    );
    Ok(())
}

#[test]
fn switch_and_class_children_expose_structural_roles() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = document(
        &mut session,
        "Clase C\nMetodo f() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir opcion Como Entero;\nopcion <- 1;\nSegun opcion Hacer\n1:\nopcion <- 1;\nDe Otro Modo:\nopcion <- 2;\nFinSegun\nFinAlgoritmo\n",
    )?;
    let result = view(&mut session, &document);
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let class = nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!("class_unit")))
        .ok_or("missing class")?;
    assert!(
        class
            .pointer("/child_roles")
            .and_then(Value::as_array)
            .is_some_and(|roles| roles
                .iter()
                .any(|role| role.get("role") == Some(&json!("member"))))
    );
    let switch = nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!("switch")))
        .ok_or("missing switch")?;
    let roles = switch
        .get("child_roles")
        .and_then(Value::as_array)
        .ok_or("missing switch roles")?;
    assert!(
        roles
            .iter()
            .any(|role| role.get("role") == Some(&json!("case")))
    );
    assert!(
        roles
            .iter()
            .any(|role| role.get("role") == Some(&json!("default_case")))
    );
    Ok(())
}
