use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const INVALID_OVERRIDE: &str = "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n";

fn program_view(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let document = session
        .call(
            "create_document",
            &json!({"program":program,"profile":"en"}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    session
        .call("program_view", &json!({"resource":document}))
        .pointer("/value")
        .cloned()
        .ok_or_else(|| "missing program view".to_owned())
}

fn realization_for_class<'rows>(
    realizations: &'rows [Value],
    class_node_id: &str,
) -> Result<&'rows Value, String> {
    realizations
        .iter()
        .find(|realization| {
            realization.get("class_node_id").and_then(Value::as_str) == Some(class_node_id)
                && realization.get("origin") == Some(&json!("inherited"))
        })
        .ok_or_else(|| "missing inherited realization".to_owned())
}

fn class_node_id(view: &Value, class_name: &str) -> Result<String, String> {
    view.get("units")
        .and_then(Value::as_array)
        .and_then(|units| {
            units.iter().find(|unit| {
                unit.get("kind") == Some(&json!("class"))
                    && unit.get("name") == Some(&json!(class_name))
            })
        })
        .and_then(|unit| unit.get("node_id"))
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("missing class node for {class_name}"))
}

#[test]
fn incompatible_override_invalidates_inherited_realization() -> Result<(), String> {
    let view = program_view(INVALID_OVERRIDE)?;
    let nodes = view
        .get("nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    let child_id = class_node_id(&view, "Child")?;
    let method = nodes
        .iter()
        .find(|node| {
            node.get("syntax_kind") == Some(&json!("method_member"))
                && node.get("parent_node_id").and_then(Value::as_str) == Some(&child_id)
        })
        .ok_or("missing overriding method node")?;
    let method_id = method
        .get("node_id")
        .and_then(Value::as_str)
        .ok_or("missing overriding method node")?;
    let signature = method
        .get("method_signature_span")
        .ok_or("missing method signature span")?;
    assert_eq!(signature.pointer("/start/line"), Some(&json!(10)));
    assert_eq!(signature.pointer("/end/line"), Some(&json!(10)));
    assert_eq!(signature.pointer("/start/column"), Some(&json!(1)));
    assert_eq!(
        signature.pointer("/end/column"),
        Some(&json!(
            1 + "method readValue(extra as integer) as integer"
                .chars()
                .count()
        ))
    );
    let realizations = view
        .get("realizations")
        .and_then(Value::as_array)
        .ok_or("missing realizations")?;
    let realization = realization_for_class(realizations, &child_id)?;
    assert_eq!(realization.get("status"), Some(&json!("invalid")));
    assert_eq!(realization.get("origin_node_id"), Some(&json!(method_id)));
    assert_eq!(
        realization.get("diagnostics"),
        Some(&json!(["incompatibleMethodOverride"]))
    );
    assert!(
        realization
            .get("interface_node_id")
            .and_then(Value::as_str)
            .is_some_and(|identifier| nodes.iter().any(|node| {
                node.get("node_id").and_then(Value::as_str) == Some(identifier)
                    && node.get("syntax_kind") == Some(&json!("interface_unit"))
            }))
    );

    Ok(())
}

#[test]
fn incompatible_override_diagnostic_keeps_contract_related_span() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":INVALID_OVERRIDE,"profile":"en","strictness":"strict"}),
    );
    let resource = analysis
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis resource")?;
    let report = session.call("analysis", &json!({"resource":resource}));
    let diagnostic = report
        .pointer("/value/diagnostics")
        .and_then(Value::as_array)
        .and_then(|diagnostics| {
            diagnostics.iter().find(|diagnostic| {
                diagnostic.get("code") == Some(&json!("incompatibleMethodOverride"))
            })
        })
        .ok_or("missing incompatible override diagnostic")?;
    assert_eq!(diagnostic.pointer("/span/start/line"), Some(&json!(10)));
    assert!(
        diagnostic
            .get("related")
            .and_then(Value::as_array)
            .is_some_and(|related| related
                .iter()
                .any(|span| { span.pointer("/start/line") == Some(&json!(2)) }))
    );

    Ok(())
}

#[test]
fn compatible_override_keeps_inherited_realization_valid() -> Result<(), String> {
    let valid_program = INVALID_OVERRIDE.replace(
        "method readValue(extra as integer) as integer\nreturn extra;",
        "method readValue() as integer\nreturn 8;",
    );
    let valid_view = program_view(&valid_program)?;
    let valid_child_id = class_node_id(&valid_view, "Child")?;
    let valid_realization = realization_for_class(
        valid_view
            .get("realizations")
            .and_then(Value::as_array)
            .ok_or("missing valid realizations")?,
        &valid_child_id,
    )?;
    assert_eq!(valid_realization.get("status"), Some(&json!("valid")));
    assert_eq!(valid_realization.get("diagnostics"), Some(&json!([])));

    Ok(())
}

#[test]
fn unrelated_incompatible_override_keeps_realization_valid() -> Result<(), String> {
    let unrelated_program = "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nmethod format() as integer\nreturn 1;\nendMethod\nendClass\nclass Child extends Reader\nmethod format(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n";
    let unrelated_view = program_view(unrelated_program)?;
    let unrelated_child_id = class_node_id(&unrelated_view, "Child")?;
    let unrelated_realization = realization_for_class(
        unrelated_view
            .get("realizations")
            .and_then(Value::as_array)
            .ok_or("missing unrelated realizations")?,
        &unrelated_child_id,
    )?;
    assert_eq!(unrelated_realization.get("status"), Some(&json!("valid")));

    Ok(())
}

#[test]
fn grandchild_incompatible_override_invalidates_inherited_realization() -> Result<(), String> {
    let grandchild_program = "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child extends Reader\nmethod readValue() as integer\nreturn 8;\nendMethod\nendClass\nclass Grandchild extends Child\nmethod readValue(extra as integer) as integer\nreturn extra;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n";
    let grandchild_view = program_view(grandchild_program)?;
    let grandchild_id = class_node_id(&grandchild_view, "Grandchild")?;
    let grandchild_realization = realization_for_class(
        grandchild_view
            .get("realizations")
            .and_then(Value::as_array)
            .ok_or("missing grandchild realizations")?,
        &grandchild_id,
    )?;
    assert_eq!(
        grandchild_realization.get("status"),
        Some(&json!("invalid"))
    );
    assert_eq!(
        grandchild_realization.get("diagnostics"),
        Some(&json!(["incompatibleMethodOverride"]))
    );
    Ok(())
}
