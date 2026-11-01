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
    program_view(program)?
        .pointer("/nodes")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing nodes".to_owned())
}

fn program_view(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    session
        .call("program_view", &json!({"resource":document}))
        .pointer("/value")
        .cloned()
        .ok_or_else(|| "missing view".to_owned())
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

#[test]
fn explicit_inherited_and_generic_contracts_use_revision_node_ids() -> Result<(), String> {
    let program = "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nClase Writer Realiza Readable\nMetodo readValue() Como Entero\nRetornar 8;\nFinMetodo\nFinClase\nClase Child Hereda De Reader\nFinClase\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let view = program_view(program)?;
    let nodes = view
        .get("nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let identifiers: Vec<_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id").and_then(Value::as_str))
        .collect();
    let relations = view
        .get("realizations")
        .and_then(Value::as_array)
        .ok_or("missing realizations")?;
    assert!(relations.iter().any(|relation| {
        relation.get("origin") == Some(&json!("explicit"))
            && relation.get("status") == Some(&json!("valid"))
    }));
    assert!(relations.iter().any(|relation| {
        relation.get("origin") == Some(&json!("inherited"))
            && relation.get("status") == Some(&json!("valid"))
    }));
    assert_eq!(
        relations
            .iter()
            .filter(|relation| relation.get("origin") == Some(&json!("explicit")))
            .count(),
        2
    );
    assert!(relations.iter().all(|relation| {
        ["class_node_id", "interface_node_id", "origin_node_id"]
            .iter()
            .all(|field| {
                relation
                    .get(field)
                    .and_then(Value::as_str)
                    .is_some_and(|identifier| identifiers.contains(&identifier))
            })
    }));
    let parameter = node_of_kind(nodes, "type_parameter")?;
    assert!(
        parameter
            .pointer("/constraints/0/interface_node_id")
            .and_then(Value::as_str)
            .is_some_and(|identifier| identifiers.contains(&identifier))
    );
    Ok(())
}

#[test]
fn invalid_and_unknown_interface_contracts_remain_visible() -> Result<(), String> {
    let program = "Interfaz Needed\nMetodo run() Como Entero;\nFinInterfaz\nClase Broken Realiza Needed\nFinClase\nClase Missing Realiza Absent\nFinClase\nSubProceso use<T: Absent>(value Como T)\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let view = program_view(program)?;
    let relations = view
        .get("realizations")
        .and_then(Value::as_array)
        .ok_or("missing realizations")?;
    assert!(relations.iter().any(|relation| {
        relation.get("origin") == Some(&json!("explicit"))
            && relation.get("status") == Some(&json!("invalid"))
            && relation.get("diagnostics").is_some_and(|codes| {
                codes
                    .as_array()
                    .is_some_and(|values| values.contains(&json!("interfaceMethodMissing")))
            })
    }));
    assert!(relations.iter().any(|relation| {
        relation.get("interface_node_id") == Some(&Value::Null)
            && relation
                .get("target_node_id")
                .and_then(Value::as_str)
                .is_some()
            && relation.get("diagnostics").is_some_and(|codes| {
                codes
                    .as_array()
                    .is_some_and(|values| values.contains(&json!("unknownInterface")))
            })
    }));
    let nodes = view
        .get("nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let parameter = node_of_kind(nodes, "type_parameter")?;
    assert_eq!(
        parameter.pointer("/constraints/0/status"),
        Some(&json!("invalid"))
    );
    assert_eq!(
        parameter.pointer("/constraints/0/interface_node_id"),
        Some(&Value::Null)
    );
    assert!(
        parameter
            .pointer("/constraints/0/target_node_id")
            .and_then(Value::as_str)
            .is_some()
    );
    Ok(())
}

#[test]
fn captures_variants_and_nested_iteration_scopes_use_local_references() -> Result<(), String> {
    let program = "SubProceso make(value Como Entero) Como SubProceso() Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como SubProceso() Como Entero\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nPara Cada value En values Hacer\nPara Cada nested En values Hacer\nEscribir nested;\nFinPara\nFinPara\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito(1);\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let identifiers: Vec<_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id"))
        .collect();
    let closures = nodes
        .iter()
        .filter(|node| node.get("syntax_kind").and_then(Value::as_str) == Some("function_literal"))
        .collect::<Vec<_>>();
    assert_eq!(closures.len(), 2);
    let captures = closures
        .iter()
        .map(|closure| {
            closure
                .get("captures")
                .and_then(Value::as_array)
                .ok_or("missing capture links")
        })
        .collect::<Result<Vec<_>, _>>()?;
    assert!(captures.iter().all(|entries| entries.len() == 1));
    let first_capture = captures
        .first()
        .and_then(|entries| entries.first())
        .ok_or("missing first capture")?;
    let second_capture = captures
        .get(1)
        .and_then(|entries| entries.first())
        .ok_or("missing second capture")?;
    assert!(captures.iter().all(|entries| {
        entries
            .first()
            .is_some_and(|capture| capture.get("mode") == Some(&json!("value")))
    }));
    assert_eq!(
        first_capture.get("binding_node_id"),
        second_capture.get("binding_node_id")
    );
    assert!(
        first_capture
            .get("binding_node_id")
            .is_some_and(|binding| identifiers.contains(&binding))
    );
    let iterations: Vec<_> = nodes
        .iter()
        .filter(|node| node.get("syntax_kind") == Some(&json!("for_each_loop")))
        .collect();
    assert_eq!(iterations.len(), 2);
    assert!(iterations.iter().all(|node| {
        [
            "collection_node_id",
            "bindings_node_id",
            "body_node_id",
            "scope_owner_node_id",
        ]
        .iter()
        .all(|field| {
            node.pointer(&format!("/iteration/{field}"))
                .is_some_and(|identifier| identifiers.contains(&identifier))
        })
    }));
    assert!(
        node_of_kind(&nodes, "variant_construction")?
            .get("variant")
            .is_some()
    );
    Ok(())
}

#[test]
fn variants_without_payload_do_not_invent_payload_nodes() -> Result<(), String> {
    let nodes =
        view_nodes("Algoritmo Main\nDefinir maybe Como Opcional<Entero> <- Nada;\nFinAlgoritmo\n")?;
    let none = nodes
        .iter()
        .find(|node| node.get("variant") == Some(&json!("none")))
        .ok_or("missing none variant")?;
    let roles = none
        .get("child_roles")
        .and_then(Value::as_array)
        .ok_or("missing child roles")?;
    assert!(
        roles
            .iter()
            .all(|role| role.get("role") != Some(&json!("payload")))
    );
    Ok(())
}

#[test]
fn mutable_closure_capture_is_rejected_by_static_analysis() -> Result<(), String> {
    let program = "SubProceso make() Como SubProceso() Como Entero\nDefinir Mutable counter Como Entero <- 1;\nRetornar SubProceso() Como Entero\nRetornar counter;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":program,"profile":"es","strictness":"strict"}),
    );
    let resource = analysis
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let report = session.call("analysis", &json!({"resource":resource}));
    let diagnostics = report
        .pointer("/value/diagnostics")
        .and_then(Value::as_array)
        .ok_or("missing diagnostics")?;
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| { diagnostic.get("code") == Some(&json!("mutableClosureCapture")) })
    );
    let view = program_view(program)?;
    let nodes = view
        .get("nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let closure = node_of_kind(nodes, "function_literal")?;
    assert_eq!(closure.get("captures"), Some(&json!([])));
    Ok(())
}

#[test]
fn static_relations_keep_the_document_source_identity() -> Result<(), String> {
    let program = "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nSubProceso use<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let document = session
        .call(
            "create_document",
            &json!({
                "program":program,
                "source":{"project_id":"7","revision_id":"11","source_id":2}
            }),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    let view = session
        .call("program_view", &json!({"resource":document}))
        .pointer("/value")
        .cloned()
        .ok_or("missing view")?;
    let nodes = view
        .get("nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let identifiers: Vec<_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id").and_then(Value::as_str))
        .collect();
    let relations = view
        .get("realizations")
        .and_then(Value::as_array)
        .ok_or("missing realizations")?;
    assert!(relations.iter().all(|relation| {
        ["class_node_id", "interface_node_id", "origin_node_id"]
            .iter()
            .all(|field| {
                relation
                    .get(field)
                    .and_then(Value::as_str)
                    .is_some_and(|identifier| identifiers.contains(&identifier))
            })
    }));
    let unit = view
        .pointer("/units/0/node_id")
        .and_then(Value::as_str)
        .ok_or("missing unit identity")?;
    assert!(unit.starts_with("p7.rb.f2.n"));
    let member = view
        .get("members")
        .and_then(Value::as_array)
        .and_then(|members| members.first())
        .and_then(|member| member.get("node_id"))
        .and_then(Value::as_str)
        .ok_or("missing member identity")?;
    assert!(member.starts_with("p7.rb.f2.n"));
    assert!(
        identifiers
            .iter()
            .all(|identifier| identifier.starts_with("p7.rb.f2.n"))
    );
    Ok(())
}
