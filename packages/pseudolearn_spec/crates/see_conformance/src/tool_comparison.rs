use serde_json::Value;

pub fn matches(name: &str, value: &Value, actual: &Value) -> bool {
    match name {
        "ri" => intermediate_representation(value, actual),
        "codigo_salida" => actual.get("exit_code") == Some(value),
        "salida_error" => actual.get("error_output") == Some(value),
        "json" => actual.get("json") == Some(value),
        "servicio" => service(value, actual),
        _ => false,
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
