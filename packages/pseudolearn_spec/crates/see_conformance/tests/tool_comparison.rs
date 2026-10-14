use see_conformance::comparison::compare;
use serde_json::json;

#[test]
fn compares_events_limits_state_and_tool_observables() {
    let actual = json!({
        "termination": {"kind": "limit_reached", "limit": "time"},
        "events": [{"class": "decision", "line": 3, "data": {"rama": "afirmativa"}}, {"class": "statement_entered", "line": 4}],
        "state_at": {"marcos": []},
        "exit_code": 1, "error_output": "", "json": {"diagnostics": []},
        "ir": {"accepted": true}
    });
    let expected = json!({
        "limite": "tiempo",
        "eventos": [{"clase": "decision", "linea": 3, "datos": {"rama": "afirmativa"}}, {"clase": "statement_entered", "linea": 4, "datos": {}}],
        "estado_en": {"evento": 1, "estado": {"marcos": []}},
        "codigo_salida": 1, "salida_error": "", "json": {"diagnostics": []},
        "ri": {"aceptada": true}
    });
    assert!(compare(&expected, &actual).is_empty());
}

#[test]
fn rejects_reordered_events_wrong_limits_and_missing_tool_fields() {
    let actual = json!({"termination": {"kind": "limit_reached", "limit": "statements"}, "events": [{"class": "call", "line": 1}, {"class": "return", "line": 1}]});
    for expected in [
        json!({"eventos": [{"clase": "return", "linea": 1}, {"clase": "call", "linea": 1}]}),
        json!({"eventos": [{"clase": "call", "linea": 1}]}),
        json!({"eventos": [{"clase": "call", "linea": 1, "datos": {"nombre": "f"}}, {"clase": "return", "linea": 1}]}),
        json!({"limite": "tiempo"}),
        json!({"limite": "micro_steps"}),
        json!({"estado_en": {"evento": 0, "estado": {}}}),
        json!({"codigo_salida": 0}),
        json!({"ri": {"reimpresion": ""}}),
    ] {
        assert!(!compare(&expected, &actual).is_empty(), "{expected}");
    }
}
