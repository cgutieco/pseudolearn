use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn run(program: &str, profile: &str, host: Value) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": {"program": program, "profile": profile, "host": host},
            "options": {"capture_states": false, "batch_size": 1000}}),
    )
}

fn output(response: &Value) -> Option<&str> {
    response.pointer("/value/output").and_then(Value::as_str)
}

const ENVIRONMENT_ES: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir env Como Entorno <- Propagar SolicitarEntorno();\nDefinir found Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_A\");\nSegun found Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir missing Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_B\");\nSegun missing Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const ENVIRONMENT_EN: &str = "subroutine Probe() as result<integer, IoError>\ndefine env as Environment <- propagate requestEnvironment();\ndefine found as optional<string> <- propagate env.get(\"PL_A\");\nswitch found do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n";

const DATE_ES: &str = "SubProceso Presentar(valor Como Opcional<FechaHora>)\nSegun valor Hacer\nNada: Escribir \"none\";\nAlgo(fecha): Escribir fecha.FormatoIsoPreciso();\nFinSegun\nFinSubProceso\nAlgoritmo P\nEscribir FechaHoraUtc(0).FormatoIso();\nPresentar(FechaHoraDe(2024, 2, 29, 12, 30, 45, 123456789, 19800));\nPresentar(FechaHoraDe(2023, 2, 29, 0, 0, 0, 0, 0));\nPresentar(AnalizarFechaHora(\"2026-06-15T12:30:45.5Z\"));\nEscribir FechaHoraUtc(0).DiaDeLaSemana();\nFinAlgoritmo\n";

#[test]
fn environment_variables_are_read_through_the_capability() {
    let host = json!({"environment": {"PL_A": "hola"}});
    let spanish = run(ENVIRONMENT_ES, "es", host.clone());
    assert_eq!(output(&spanish), Some("[hola]\nnone\n0\n"), "{spanish}");
    let english = run(ENVIRONMENT_EN, "en", host);
    assert_eq!(output(&english), Some("[hola]\n0\n"), "{english}");
}

#[test]
fn calendar_values_are_built_formatted_and_parsed() {
    let response = run(DATE_ES, "es", json!({}));
    let expected = "1970-01-01T00:00:00Z\n2024-02-29T12:30:45.123456789+05:30\nnone\n2026-06-15T12:30:45.500000000Z\n4\n";
    assert_eq!(output(&response), Some(expected), "{response}");
}

#[test]
fn analysis_of_the_probe_programs_has_no_errors() {
    for (program, profile) in [
        (ENVIRONMENT_ES, "es"),
        (ENVIRONMENT_EN, "en"),
        (DATE_ES, "es"),
    ] {
        let response = pseudolearn_api::execute_analyze(&pseudolearn_api::AnalyzeRequest {
            program: program.to_owned(),
            profile: profile.to_owned(),
            source: None,
        });
        let codes: Vec<_> = response
            .diagnostics
            .iter()
            .map(|diagnostic| format!("{}@{:?}", diagnostic.code, diagnostic.span))
            .collect();
        assert!(codes.is_empty(), "{profile}: {codes:?}");
    }
}
