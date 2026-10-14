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
        "estado_en" => actual.get("state_at") == value.get("estado"),
        "limite" => termination_limit(value, actual),
        _ => crate::tool_comparison::matches(name, value, actual),
    }
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
    expected.len() == actual.len()
        && expected
            .iter()
            .zip(actual)
            .all(|(expected, actual)| event_matches(expected, actual))
}

fn event_matches(expected: &Value, actual: &Value) -> bool {
    let empty = Value::Object(serde_json::Map::new());
    expected.get("clase") == actual.get("class")
        && expected.get("linea") == actual.get("line")
        && expected.get("datos").unwrap_or(&empty) == actual.get("data").unwrap_or(&empty)
}
