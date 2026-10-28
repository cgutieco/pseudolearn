use serde_json::Value;

pub fn compare(expected: &Value, actual: &Value) -> Vec<String> {
    let mut differences = Vec::new();
    let Some(fields) = expected.as_object() else {
        return vec!["Expected observation is not an object".to_owned()];
    };
    for (name, value) in fields {
        let matches = matches(name, value, actual);
        if !matches {
            differences.push(format!("Mismatch: {name}"));
        }
    }
    differences
}

fn ordered_diagnostics(expected: &Value, actual: Option<&Value>) -> bool {
    let Some(expected) = expected.as_array() else {
        return false;
    };
    let Some(actual) = actual.and_then(Value::as_array) else {
        return false;
    };
    expected.len() == actual.len()
        && expected
            .iter()
            .zip(actual)
            .all(|(expected, actual)| diagnostic_matches(expected, actual))
}

fn diagnostics(expected: &Value, actual: Option<&Value>) -> bool {
    let Some(expected) = expected.as_array() else {
        return false;
    };
    let Some(actual) = actual.and_then(Value::as_array) else {
        return false;
    };
    if expected.len() != actual.len() {
        return false;
    }
    let mut remaining = actual.clone();
    for diagnostic in expected {
        let Some(offset) = remaining
            .iter()
            .position(|actual| diagnostic_matches(diagnostic, actual))
        else {
            return false;
        };
        remaining.remove(offset);
    }
    true
}

fn diagnostic_matches(expected: &Value, actual: &Value) -> bool {
    let Some(fields) = expected.as_object() else {
        return false;
    };
    fields.iter().all(|(name, value)| {
        let target = match name.as_str() {
            "codigo" => "code",
            "severidad" => "severity",
            "clase" => "class",
            "tramo" => "span",
            "relacionados" => "related",
            "argumentos" => "arguments",
            _ => name,
        };
        let translated = value.as_str().map(|text| match text {
            "advertencia" => "warning",
            "error" => "error",
            other => other,
        });
        if let Some(translated) = translated {
            actual.get(target).and_then(Value::as_str) == Some(translated)
        } else {
            actual.get(target) == Some(value)
        }
    })
}

fn matches(name: &str, value: &Value, actual: &Value) -> bool {
    match name {
        "salida" => actual.get("output") == Some(value),
        "terminacion" => {
            actual
                .get("termination")
                .and_then(|termination| termination.get("kind"))
                == Some(value)
        }
        "fallo" => {
            actual
                .get("termination")
                .and_then(|termination| termination.get("kind"))
                .and_then(Value::as_str)
                == Some("failed")
                && value.get("codigo")
                    == actual
                        .get("termination")
                        .and_then(|termination| termination.get("code"))
        }
        "arbol" => {
            actual.get("tree").and_then(Value::as_bool) == Some(value.as_str() == Some("presente"))
        }
        "diagnosticos" => diagnostics(value, actual.get("diagnostics")),
        "diagnosticos_ordenados" => ordered_diagnostics(value, actual.get("diagnostics")),
        "eventos" => events(value, actual.get("events")),
        "estado" => actual.get("states") == Some(value),
        "estado_en" => crate::tool_comparison::state_at(value, actual),
        "limite" => termination_limit(value, actual),
        "efecto_pendiente" => pending_effect_matches(value, actual.get("termination")),
        "anfitrion_observado" => host_observed(value, actual),
        _ => crate::tool_comparison::matches(name, value, actual),
    }
}

fn pending_effect_matches(expected: &Value, actual: Option<&Value>) -> bool {
    let (Some(expected), Some(actual)) = (expected.as_object(), actual) else {
        return false;
    };
    expected
        .iter()
        .all(|(key, value)| actual.get(key) == Some(value))
}

fn host_observed(expected: &Value, actual: &Value) -> bool {
    let Some(fields) = expected.as_object() else {
        return false;
    };
    let observation = actual.get("host_observation");
    fields.iter().all(|(name, value)| match name.as_str() {
        "llamadas" => observation.and_then(|found| found.get("calls")) == Some(value),
        "recursos_abiertos" => {
            observation.and_then(|found| found.get("open_resources")) == Some(value)
        }
        "estado_cinta" => actual.pointer("/effect_tape/status") == Some(value),
        "efectos" => tape_effects_match(value, actual.pointer("/effect_tape/entries")),
        "reproduccion_fallo" => value.as_str().is_some(),
        _ => false,
    })
}

fn tape_effects_match(expected: &Value, actual: Option<&Value>) -> bool {
    let (Some(expected), Some(actual)) = (expected.as_array(), actual.and_then(Value::as_array))
    else {
        return false;
    };
    let include_console = expected
        .iter()
        .any(|entry| entry.get("capability_kind").and_then(Value::as_str) == Some("console"));
    let filtered: Vec<&Value> = actual
        .iter()
        .filter(|entry| {
            include_console
                || entry.get("capability_kind").and_then(Value::as_str) != Some("console")
        })
        .collect();
    expected.len() == filtered.len()
        && expected
            .iter()
            .zip(filtered)
            .all(|(expected_entry, actual_entry)| tape_entry_matches(expected_entry, actual_entry))
}

fn tape_entry_matches(expected: &Value, actual: &Value) -> bool {
    for field in ["effect_seq", "capability_kind", "operation", "outcome"] {
        if expected.get(field) != actual.get(field) {
            return false;
        }
    }
    for field in ["task_id", "delivery_seq"] {
        if expected.get(field).is_some() && expected.get(field) != actual.get(field) {
            return false;
        }
    }
    let Some(key_id) = expected.get("secret_key_id").and_then(Value::as_str) else {
        return true;
    };
    let prefix = format!("secret:{key_id}:");
    let redacted = actual
        .get("payload_bytes")
        .and_then(Value::as_array)
        .is_some_and(Vec::is_empty);
    redacted
        && actual
            .get("secret_reference")
            .and_then(Value::as_str)
            .is_some_and(|reference| {
                reference.starts_with(&prefix) && reference.len() > prefix.len()
            })
}

fn termination_limit(value: &Value, actual: &Value) -> bool {
    let wire = match value.as_str() {
        Some("sentencias") => "statements",
        Some("tiempo") => "time",
        _ => return false,
    };
    actual
        .get("termination")
        .and_then(|termination| termination.get("limit"))
        .and_then(Value::as_str)
        == Some(wire)
}

fn events(expected: &Value, actual: Option<&Value>) -> bool {
    let (Some(expected), Some(actual)) = (expected.as_array(), actual.and_then(Value::as_array))
    else {
        return false;
    };
    if expected.len() != actual.len() {
        return false;
    }
    let mut sources = std::collections::BTreeMap::new();
    expected
        .iter()
        .zip(actual)
        .all(|(expected, actual)| event_matches(expected, actual, &mut sources))
}

fn event_matches(
    expected: &Value,
    actual: &Value,
    sources: &mut std::collections::BTreeMap<String, (Value, Value, Value)>,
) -> bool {
    let empty = Value::Object(serde_json::Map::new());
    let source_matches = expected.get("fuente").is_none_or(|source| {
        let Some(marker) = source.as_str() else {
            return false;
        };
        let Some(actual_source) = actual.get("source") else {
            return false;
        };
        let Some(revision) = actual_source.get("revision_id") else {
            return false;
        };
        let Some(node) = actual_source.get("node_id") else {
            return false;
        };
        let Some(span) = actual_source.get("span") else {
            return false;
        };
        let identity = (revision.clone(), node.clone(), span.clone());
        if let Some(previous) = sources.get(marker) {
            previous == &identity
        } else {
            sources.insert(marker.to_owned(), identity);
            true
        }
    });
    expected.get("clase") == actual.get("class")
        && expected.get("linea") == actual.get("line")
        && expected.get("datos").unwrap_or(&empty) == actual.get("data").unwrap_or(&empty)
        && source_matches
}
