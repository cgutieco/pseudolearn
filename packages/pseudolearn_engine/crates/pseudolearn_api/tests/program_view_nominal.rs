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
