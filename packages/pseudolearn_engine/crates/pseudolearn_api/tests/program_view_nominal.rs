use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn nominal_declarations_have_public_nodes_and_opaque_interface_identity() -> Result<(), String> {
    let program = "Interfaz Empty\nFinInterfaz\nClase Realizer Realiza Empty\nFinClase\nAlgoritmo Main\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    let view = session.call("program_view", &json!({"resource":document}));
    let nodes = view
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let interface = nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!("interface_unit")))
        .ok_or("missing interface")?;
    assert_eq!(
        interface.get("interface_identity"),
        interface.get("node_id")
    );
    let realization = nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!("class_unit")))
        .ok_or("missing class")?;
    assert_eq!(
        realization.get("realized_interfaces"),
        Some(&json!([interface.get("node_id")]))
    );
    Ok(())
}

fn view_nodes(program: &str) -> Result<Vec<Value>, String> {
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    let view = session.call("program_view", &json!({"resource":document}));
    view.pointer("/value/nodes")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing nodes".to_owned())
}

fn node_of_kind<'nodes>(nodes: &'nodes [Value], kind: &str) -> Result<&'nodes Value, String> {
    nodes
        .iter()
        .find(|node| node.get("syntax_kind") == Some(&json!(kind)))
        .ok_or_else(|| format!("missing {kind}"))
}

#[test]
fn enumerations_and_records_expose_identity_members_and_field_relations() -> Result<(), String> {
    let program = "Enumerado Color\nRojo, Verde\nFinEnumerado\nRegistro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo Main\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let enumeration = node_of_kind(&nodes, "enum_unit")?;
    assert_eq!(enumeration.get("enum_identity"), enumeration.get("node_id"));
    assert_eq!(
        enumeration.get("enum_members"),
        Some(&json!(["Rojo", "Verde"]))
    );
    let record = node_of_kind(&nodes, "record_unit")?;
    assert_eq!(record.get("record_identity"), record.get("node_id"));
    let fields = record
        .get("record_fields")
        .and_then(Value::as_array)
        .ok_or("missing fields")?;
    let field_ids: Vec<_> = nodes
        .iter()
        .filter(|node| node.get("syntax_kind") == Some(&json!("record_field")))
        .filter_map(|node| node.get("node_id"))
        .collect();
    assert!(!fields.is_empty());
    assert!(fields.iter().all(|field| field_ids.contains(&field)));
    Ok(())
}

#[test]
fn closures_relate_to_the_bindings_they_capture_and_no_other_source() -> Result<(), String> {
    let program = "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let closure = node_of_kind(&nodes, "function_literal")?;
    assert_eq!(closure.get("closure_identity"), closure.get("node_id"));
    let captured = closure
        .get("captured_bindings")
        .and_then(Value::as_array)
        .ok_or("missing captures")?;
    let own_ids: Vec<_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id"))
        .collect();
    assert_eq!(captured.len(), 1);
    assert!(captured.iter().all(|capture| own_ids.contains(&capture)));
    Ok(())
}

#[test]
fn programs_without_new_constructs_expose_no_value_attributes() -> Result<(), String> {
    let nodes = view_nodes("Algoritmo Main\nFinAlgoritmo\n")?;
    let forbidden = ["enum_identity", "record_identity", "closure_identity"];
    assert!(
        nodes
            .iter()
            .all(|node| forbidden.iter().all(|key| node.get(key).is_none()))
    );
    Ok(())
}
