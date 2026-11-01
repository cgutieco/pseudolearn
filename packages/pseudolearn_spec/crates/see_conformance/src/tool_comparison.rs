use serde_json::Value;

pub fn matches(name: &str, value: &Value, actual: &Value) -> bool {
    match name {
        "ri" => intermediate_representation(value, actual),
        "dap" => crate::dap_comparison::matches(value, actual),
        "codigo_salida" => actual.get("exit_code") == Some(value),
        "salida_error" => actual.get("error_output") == Some(value),
        "json" => actual.get("json") == Some(value),
        "servicio" => service(value, actual),
        "api" => api(value, actual),
        "aplicacion" => subset(value, actual.get("app")),
        "vista_programa" => {
            crate::program_view_comparison::program_view(value, actual.get("program_view"))
        }
        "tokens_include" => includes_values(value, actual.get("tokens")),
        _ => false,
    }
}

fn api(expected: &Value, actual: &Value) -> bool {
    if let Some(results) = expected.get("results") {
        return subset(results, actual.get("results"));
    }
    subset(expected, actual.get("result"))
}

pub(crate) fn includes_values(expected: &Value, actual: Option<&Value>) -> bool {
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

pub(crate) fn subset(expected: &Value, actual: Option<&Value>) -> bool {
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
