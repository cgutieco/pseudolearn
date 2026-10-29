use crate::property_scenarios::Scenario;
use serde_json::json;

pub(crate) fn scenario(seed: u64, sample: u32, profile: &str, strictness: &str) -> Scenario {
    let number = seed.wrapping_add(u64::from(sample)) % 1_000_000;
    let source = format!("{{\"round\": {number}, \"label\": \"p\"}}");
    let canonical = format!("{{\"round\":{number},\"label\":\"p\"}}\n");
    let program = program(&source, profile);
    Scenario {
        request: json!({
            "kind": "execute",
            "program": program,
            "profile": profile,
            "strictness": strictness,
            "limits": {"max_json_depth": 64}
        }),
        expected: Some(json!({"salida": canonical, "terminacion": "completed"})),
        traced: false,
    }
}

fn program(source: &str, profile: &str) -> String {
    match profile {
        "es" => format!(
            "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{source}');\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n"
        ),
        _ => format!(
            "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{source}');\nswitch parsed do\nsuccess(document): write jsonText(document);\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
        ),
    }
}
