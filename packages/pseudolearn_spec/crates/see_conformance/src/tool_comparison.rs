use serde_json::Value;

pub fn matches(name: &str, value: &Value, actual: &Value) -> bool {
    match name {
        "ri" => intermediate_representation(value, actual),
        "codigo_salida" => actual.get("exit_code") == Some(value),
        "salida_error" => actual.get("error_output") == Some(value),
        "json" => actual.get("json") == Some(value),
        "servicio" => service(value, actual),
        "aplicacion" => subset(value, actual.get("app")),
        "vista_programa" => program_view(value, actual.get("program_view")),
        "tokens_include" => includes_values(value, actual.get("tokens")),
        _ => false,
    }
}

fn includes_values(expected: &Value, actual: Option<&Value>) -> bool {
    let (Some(expected), Some(actual)) = (expected.as_array(), actual.and_then(Value::as_array))
    else {
        return false;
    };
    expected.iter().all(|expected_value| {
        actual
            .iter()
            .any(|actual_value| subset(expected_value, Some(actual_value)))
    })
}

fn includes_candidates(expected: &Value, actual: Option<&Value>) -> bool {
    let (Some(expected), Some(actual)) = (expected.as_array(), actual.and_then(Value::as_array))
    else {
        return false;
    };
    expected.iter().all(|candidate| actual.contains(candidate))
}

fn program_view(expected: &Value, actual: Option<&Value>) -> bool {
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
            "references_same_revision" => {
                value.as_bool() == Some(true) && references_same_revision(actual)
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

fn subset(expected: &Value, actual: Option<&Value>) -> bool {
    let Some(actual) = actual else {
        return false;
    };
    match (expected, actual) {
        (Value::Object(expected), Value::Object(actual)) => expected.iter().all(|(name, value)| {
            if name == "next_cursor" && value.as_str() == Some("opaque") {
                return actual
                    .get(name)
                    .and_then(Value::as_str)
                    .is_some_and(|cursor| !cursor.is_empty());
            }
            if name == "candidates_include" {
                return includes_candidates(value, actual.get(name));
            }
            subset(value, actual.get(name))
        }),
        (Value::Array(expected), Value::Array(actual)) => {
            expected.len() == actual.len()
                && expected
                    .iter()
                    .zip(actual)
                    .all(|(expected, actual)| subset(expected, Some(actual)))
        }
        _ => expected == actual,
    }
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
    collection_resolves(view, "units", &identifiers)
        && collection_resolves(view, "members", &identifiers)
        && nodes.iter().all(|node| node_resolves(node, &identifiers))
}

fn collection_resolves(view: &Value, name: &str, identifiers: &Identifiers<'_>) -> bool {
    view.get(name)
        .and_then(Value::as_array)
        .is_none_or(|entries| {
            entries.iter().all(|entry| {
                entry
                    .get("node_id")
                    .and_then(Value::as_str)
                    .is_some_and(|identifier| identifiers.contains(identifier))
            })
        })
}

fn node_resolves(node: &Value, identifiers: &Identifiers<'_>) -> bool {
    let children_resolve = node
        .get("child_node_ids")
        .and_then(Value::as_array)
        .is_none_or(|children| {
            children.iter().all(|child| {
                child
                    .as_str()
                    .is_some_and(|identifier| identifiers.contains(identifier))
            })
        });
    let roles_resolve = node
        .get("child_roles")
        .and_then(Value::as_array)
        .is_none_or(|roles| {
            roles.iter().all(|role| {
                role.get("node_id")
                    .and_then(Value::as_str)
                    .is_some_and(|identifier| identifiers.contains(identifier))
            })
        });
    let parent_resolves = node.get("parent_node_id").is_none_or(|parent| {
        parent
            .as_str()
            .is_some_and(|identifier| identifiers.contains(identifier))
    });
    children_resolve && roles_resolve && parent_resolves
}

fn intermediate_representation(expected: &Value, actual: &Value) -> bool {
    let Some(outcome) = actual.get("ir") else {
        return false;
    };
    if let Some(reprint) = expected.get("reimpresion") {
        return outcome.get("reprint") == Some(reprint);
    }
    outcome.get("accepted") == expected.get("aceptada")
        && expected
            .get("regla")
            .is_none_or(|rule| outcome.get("violated_rule") == Some(rule))
}

fn service(expected: &Value, actual: &Value) -> bool {
    let Some(outcome) = actual.get("service") else {
        return false;
    };
    outcome == expected
}

pub fn state_at(expected: &Value, actual: &Value) -> bool {
    let expected = expected.get("estado");
    let actual = actual.get("state_at");
    match expected {
        Some(value) if value.get("next_cursor").is_some() => subset(value, actual),
        _ => actual == expected,
    }
}
