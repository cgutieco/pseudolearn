use serde_json::Value;

use crate::tool_comparison::{includes_values, subset};

pub(crate) fn program_view(expected: &Value, actual: Option<&Value>) -> bool {
    let Some(actual) = actual else {
        return false;
    };
    let Some(expectations) = expected.as_object() else {
        return false;
    };
    expectations
        .iter()
        .all(|(name, value)| match name.as_str() {
            "node_kinds_include" => includes_node_kinds(value, actual),
            "syntax_kinds_include" => includes_syntax_kinds(value, actual),
            "child_roles_include" => includes_child_roles(value, actual),
            "node_ids_unique" => value.as_bool() == Some(true) && node_ids_unique(actual),
            "references_same_revision" | "relations_same_revision_and_source" => {
                value.as_bool() == Some(true) && references_same_revision(actual)
            }
            "realizations_include" => includes_values(value, actual.get("realizations")),
            "constraints_include" => includes_static_rows(value, actual, "constraints"),
            "captures_include" => includes_static_rows(value, actual, "captures"),
            "iterations_include" => includes_iteration_fields(value, actual),
            "variants_include_payload_roles" => {
                value.as_bool() == Some(true) && variants_include_payload_roles(actual)
            }
            "variants_without_payload" => {
                value.as_bool() == Some(true) && variants_without_payload(actual)
            }
            "closures_without_captures" => {
                value.as_bool() == Some(true) && closures_without_captures(actual)
            }
            "nodes_include" => includes_nodes(value, actual),
            "child_order" => actual.get("child_order") == Some(value),
            _ => subset(value, actual.get(name)),
        })
}

fn includes_child_roles(expected: &Value, view: &Value) -> bool {
    let Some(expected_roles) = expected.as_array() else {
        return false;
    };
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    expected_roles.iter().all(|expected_role| {
        let expected_syntax = expected_role.get("syntax_kind");
        let expected_role_name = expected_role.get("role");
        nodes.iter().any(|node| {
            node.get("syntax_kind") == expected_syntax
                && node
                    .get("child_roles")
                    .and_then(Value::as_array)
                    .is_some_and(|roles| {
                        roles
                            .iter()
                            .any(|role| role.get("role") == expected_role_name)
                    })
        })
    })
}

fn includes_node_kinds(expected: &Value, view: &Value) -> bool {
    let Some(expected_kinds) = expected.as_array() else {
        return false;
    };
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    expected_kinds.iter().all(|expected_kind| {
        nodes
            .iter()
            .any(|node| node.get("kind") == Some(expected_kind))
    })
}

fn includes_syntax_kinds(expected: &Value, view: &Value) -> bool {
    let Some(expected_kinds) = expected.as_array() else {
        return false;
    };
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    expected_kinds.iter().all(|expected_kind| {
        nodes
            .iter()
            .any(|node| node.get("syntax_kind") == Some(expected_kind))
    })
}

fn includes_nodes(expected: &Value, view: &Value) -> bool {
    let Some(expected_nodes) = expected.as_array() else {
        return false;
    };
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    expected_nodes.iter().all(|expected_node| {
        nodes
            .iter()
            .any(|actual_node| subset(expected_node, Some(actual_node)))
    })
}

fn node_ids_unique(view: &Value) -> bool {
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    let mut identifiers = std::collections::BTreeSet::new();
    nodes.iter().all(|node| {
        node.get("node_id")
            .and_then(Value::as_str)
            .is_some_and(|identifier| !identifier.is_empty() && identifiers.insert(identifier))
    })
}

type Identifiers<'view> = std::collections::BTreeSet<&'view str>;

fn references_same_revision(view: &Value) -> bool {
    if !view
        .get("revision_id")
        .and_then(Value::as_str)
        .is_some_and(|revision| !revision.is_empty())
    {
        return false;
    }
    let Some(nodes) = view.get("nodes").and_then(Value::as_array) else {
        return false;
    };
    let identifiers: Identifiers<'_> = nodes
        .iter()
        .filter_map(|node| node.get("node_id").and_then(Value::as_str))
        .collect();
    references_resolve(view, &identifiers)
}

fn references_resolve(value: &Value, identifiers: &Identifiers<'_>) -> bool {
    match value {
        Value::Object(fields) => fields.iter().all(|(name, field)| {
            if name == "node_id" || name.ends_with("_node_id") {
                return field.is_null()
                    || field
                        .as_str()
                        .is_some_and(|identifier| identifiers.contains(identifier));
            }
            if matches!(
                name.as_str(),
                "realized_interfaces" | "record_fields" | "captured_bindings"
            ) {
                return field.as_array().is_some_and(|relations| {
                    relations.iter().all(|relation| {
                        relation
                            .as_str()
                            .is_some_and(|identifier| identifiers.contains(identifier))
                    })
                });
            }
            references_resolve(field, identifiers)
        }),
        Value::Array(values) => values
            .iter()
            .all(|value| references_resolve(value, identifiers)),
        _ => true,
    }
}

fn includes_static_rows(expected: &Value, view: &Value, field: &str) -> bool {
    let (Some(expected_rows), Some(nodes)) = (
        expected.as_array(),
        view.get("nodes").and_then(Value::as_array),
    ) else {
        return false;
    };
    let actual_rows = nodes
        .iter()
        .filter_map(|node| node.get(field).and_then(Value::as_array))
        .flatten()
        .collect::<Vec<_>>();
    expected_rows.iter().all(|expected_row| {
        actual_rows
            .iter()
            .any(|actual_row| subset(expected_row, Some(actual_row)))
    })
}

fn includes_iteration_fields(expected: &Value, view: &Value) -> bool {
    let (Some(fields), Some(nodes)) = (
        expected.as_array(),
        view.get("nodes").and_then(Value::as_array),
    ) else {
        return false;
    };
    nodes.iter().any(|node| {
        node.get("iteration").is_some_and(|iteration| {
            fields.iter().all(|field| {
                field
                    .as_str()
                    .and_then(|name| iteration.get(name))
                    .and_then(Value::as_str)
                    .is_some_and(|identifier| !identifier.is_empty())
            })
        })
    })
}

fn variants_include_payload_roles(view: &Value) -> bool {
    view.get("nodes")
        .and_then(Value::as_array)
        .is_some_and(|nodes| {
            nodes.iter().any(|node| {
                matches!(
                    node.get("syntax_kind").and_then(Value::as_str),
                    Some("variant_construction" | "variant_pattern")
                ) && node
                    .get("child_roles")
                    .and_then(Value::as_array)
                    .is_some_and(|roles| {
                        roles
                            .iter()
                            .any(|role| role.get("role").and_then(Value::as_str) == Some("payload"))
                    })
            })
        })
}

fn variants_without_payload(view: &Value) -> bool {
    view.get("nodes")
        .and_then(Value::as_array)
        .is_some_and(|nodes| {
            nodes.iter().any(|node| {
                node.get("variant").and_then(Value::as_str) == Some("none")
                    && node
                        .get("child_roles")
                        .and_then(Value::as_array)
                        .is_some_and(|roles| {
                            roles.iter().all(|role| {
                                role.get("role").and_then(Value::as_str) != Some("payload")
                            })
                        })
            })
        })
}

fn closures_without_captures(view: &Value) -> bool {
    view.get("nodes")
        .and_then(Value::as_array)
        .is_some_and(|nodes| {
            nodes.iter().any(|node| {
                node.get("syntax_kind").and_then(Value::as_str) == Some("function_literal")
                    && node
                        .get("captures")
                        .and_then(Value::as_array)
                        .is_some_and(Vec::is_empty)
            })
        })
}
